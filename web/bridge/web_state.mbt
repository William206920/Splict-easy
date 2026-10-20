///|
let web_empty : String = "{\"schema_version\":1,\"people\":[],\"payments\":[],\"ambiguous\":[]}"

///|
let web_sample : String = "人：小明 小红 小刚\n小明 90 晚餐\n小红 30 奶茶 =小明:10 小红:20\n小刚 20 车费 @小明 小刚"

///|
let web_free_sample : String = "我们三人：小明、小红、小刚。小明付了90元晚餐，三人平摊。小红付了30元奶茶，小明喝10元、小红喝20元，小刚没喝。小刚付20元车费，由小明和小刚平摊。"

///|
priv struct WebService {
  enabled : Bool
  provider : String
  model : String
  invite : Bool
}

///|
fn web_json(text : String) -> Json raise @shared.BillError {
  @json.parse(text) catch {
    _ => {
      @shared.invalid("服务返回的内容不是有效 JSON")
      Json::null()
    }
  }
}

///|
fn web_bool(value : Json, name : String) -> Bool {
  match value {
    Object(fields) =>
      match fields.get(name) {
        Some(True) => true
        _ => false
      }
    _ => false
  }
}

///|
fn web_service(text : String) -> WebService raise @shared.BillError {
  let value = web_json(text)
  let enabled = web_bool(value, "enabled")
  {
    enabled,
    provider: if enabled {
      field(value, "provider")
    } else {
      ""
    },
    model: if enabled {
      field(value, "model")
    } else {
      ""
    },
    invite: web_bool(value, "invitationRequired"),
  }
}

///|
fn WebService::status(self : WebService) -> String {
  if !self.enabled {
    return "共享 AI 尚未配置完成。你仍可使用文本导入和普通记账。"
  }
  "服务：" +
  self.provider +
  " · " +
  self.model +
  "。" +
  (if self.invite { "需要邀请码，" } else { "向所有访客开放，" }) +
  "每次最多 8000 字符。"
}

///|
priv struct WebPreview {
  ledger : @shared.Ledger
  text : String
  revision : Int32
  merge : Bool
}

///|
// Mutable application state belongs to MoonBit. The browser supplies only IO.
priv struct WebState {
  mut ledger : @shared.Ledger
  mut saved : String
  mut corrupt : String?
  mut revision : Int32
  mut preview : WebPreview?
  mut busy : Bool
  mut serial : Int32
  mut request_revision : Int32
  mut service : WebService?
}

///|
fn WebState::new() -> WebState {
  {
    ledger: { people: [], payments: [], ambiguous: [], },
    saved: "",
    corrupt: None,
    revision: 0,
    preview: None,
    busy: false,
    serial: 0,
    request_revision: 0,
    service: None,
  }
}

///|
fn WebState::source(self : WebState) -> String {
  @shared.encode_ledger(self.ledger)
}

///|
fn WebState::load(
  self : WebState,
  source : String,
) -> Unit raise @shared.BillError {
  self.saved = source
  if source.is_empty() {
    return
  }
  errdefer {
    self.corrupt = Some(source)
  }
  self.ledger = mutate("view", source, "{}")
}

///|
fn WebState::writable(
  self : WebState,
  current : String,
  storage_available : Bool,
) -> Unit raise @shared.BillError {
  if self.busy {
    @shared.invalid("AI 正在解析，请先取消请求再修改账单。")
  }
  if self.corrupt is Some(_) {
    @shared.invalid("请先备份无法读取的旧草稿。")
  }
  if storage_available && current != self.saved {
    @shared.invalid(
      "另一个标签页已修改账单。请先导出当前账单备份，再刷新页面载入最新内容。",
    )
  }
}

///|
fn WebState::replace(
  self : WebState,
  ledger : @shared.Ledger,
) -> Unit raise @shared.BillError {
  if self.busy {
    @shared.invalid("AI 正在解析，请先取消请求再修改账单。")
  }
  let session = @shared.Session::new()
  session.replace(ledger)
  self.ledger = session.ledger
  self.revision = self.revision + 1
}

///|
fn WebState::change(
  self : WebState,
  action : String,
  data : String,
) -> Unit raise @shared.BillError {
  self.replace(mutate(action, self.source(), data))
}

///|
fn WebState::stage(
  self : WebState,
  ledger : @shared.Ledger,
  text : String,
  merge~ : Bool = false,
) -> Unit raise @shared.BillError {
  let session = @shared.Session::new()
  session.replace(ledger)
  self.preview = Some({
    ledger: session.ledger,
    text,
    revision: self.revision,
    merge,
  })
}

///|
fn WebState::stage_import(
  self : WebState,
  text : String,
) -> Unit raise @shared.BillError {
  let ledger = mutate(
    "import",
    self.source(),
    "{\"text\":" + @shared.quote_json(text) + "}",
  )
  let report = if ledger.payments.is_empty() {
    "尚无消费，添加后即可结算。"
  } else {
    @shared.render_text(@shared.settle(ledger))
  }
  self.stage(
    ledger,
    if ledger.people.is_empty() {
      "空账单，确认后清空当前账本。"
    } else {
      "成员：" + ledger.people.join("、") + "\n\n" + report
    },
  )
}

///|
fn WebState::preview_result(
  self : WebState,
) -> @shared.Ledger raise @shared.BillError {
  match self.preview {
    Some(preview) => {
      if preview.revision != self.revision {
        @shared.invalid("账单已改变，请重新预览。")
      }
      if preview.merge {
        @shared.merge_ledgers(self.ledger, preview.ledger)
      } else {
        preview.ledger
      }
    }
    None => {
      @shared.invalid("账单已改变，请重新预览。")
      self.ledger
    }
  }
}

///|
fn WebState::preview_duplicates(self : WebState) -> Int32 {
  match self.preview {
    Some(p) =>
      @shared.duplicate_payments(
        if p.merge {
          self.ledger
        } else {
          { people: [], payments: [], ambiguous: [], }
        },
        p.ledger,
      )
    None => 0
  }
}

///|
fn WebState::apply_preview(
  self : WebState,
  duplicates_confirmed~ : Bool = false,
  replacement_confirmed~ : Bool = false,
) -> Unit raise @shared.BillError {
  let result = self.preview_result()
  if self.preview_duplicates() > 0 && !duplicates_confirmed {
    @shared.invalid("请核对疑似重复记录，并确认仍要记入。")
  }
  match self.preview {
    Some(p) =>
      if !p.merge && !self.ledger.people.is_empty() && !replacement_confirmed {
        @shared.invalid("请确认替换当前账单，或选择追加。")
      }
    None => ()
  }
  self.replace(result)
  self.preview = None
}

///|
fn WebState::prepare_ai(
  self : WebState,
  text : String,
  consent : Bool,
  code : String,
) -> String raise @shared.BillError {
  if self.busy {
    @shared.invalid("AI 正在解析，请先取消请求再修改账单。")
  }
  if !consent {
    @shared.invalid("请先勾选同意外发文字。")
  }
  let trimmed = text.trim().to_owned()
  if trimmed.is_empty() || trimmed.length() > 8000 {
    @shared.invalid("请输入 1–8000 字符的账单描述。")
  }
  match self.service {
    Some(service) => {
      if !service.enabled {
        @shared.invalid("共享 AI 尚未配置完成。")
      }
      if service.invite && code.is_empty() {
        @shared.invalid("请输入站点邀请码。")
      }
      "将把输入框中的账单文字发送至 " +
      service.provider +
      "，使用 " +
      service.model +
      " 解析。是否发送？"
    }
    None => {
      @shared.invalid(
        "暂时无法连接 AI 服务。你仍可使用文本导入和普通记账。",
      )
      ""
    }
  }
}

///|
fn WebState::begin_request(self : WebState) -> Int32 {
  self.serial = self.serial + 1
  self.request_revision = self.revision
  self.busy = true
  self.serial
}

///|
fn WebState::cancel_request(self : WebState) -> Unit {
  self.busy = false
  self.serial = self.serial + 1
}

///|
fn WebState::finish_request(
  self : WebState,
  serial : Int32,
  status : Int32,
  text : String,
) -> Bool raise @shared.BillError {
  if !self.busy || serial != self.serial {
    return false
  }
  self.busy = false
  if status == 0 {
    return false
  }
  if status < 0 {
    @shared.invalid("请求失败，请检查网络后重试。")
  }
  let result = web_json(text)
  if status < 200 || status >= 300 {
    @shared.invalid(field(result, "error"))
  }
  if self.request_revision != self.revision {
    @shared.invalid("账单已改变，请重新解析。")
  }
  // Revalidate the opaque ledger in MoonBit even after server validation.
  let ledger = mutate("view", field(result, "ledger"), "{}")
  self.stage(ledger, field(result, "preview"), merge=true)
  true
}

///|
fn web_route(hash : String) -> String {
  match hash {
    "#overview" => "overview"
    "#members" => "members"
    "#import" => "import"
    "#ai" => "ai"
    _ => "overview"
  }
}
