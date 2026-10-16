///|
pub(all) struct Form {
  mut description : String
  mut amount : String
  mut date : String
  mut payer : Int32
  mut exact : Bool
  selected : Array[Bool]
  amounts : Array[String]
  mut changed : Bool
}

///|
pub(all) struct Desktop {
  session : @shared.Session
  mut page : Int32
  mut edit_index : Int32
  mut form : Form
  mut path : String
  mut saved_revision : Int32
  mut status : String
  mut draft : String
  mut autosave : Bool
  testing : Bool
  mut ai_config : @ai.Config
  mut ai_text : String
  mut ai_preview : String
  mut flow : @ai.Flow
  mut waiting : Bool
  mut advanced_text : String
  mut member_text : String
  mut member_index : Int32
}

///|
fn new_form(count : Int32) -> Form {
  {
    description: "",
    amount: "",
    date: "",
    payer: 0,
    exact: false,
    selected: Array::make(count, true),
    amounts: Array::make(count, "0"),
    changed: false,
  }
}

///|
pub fn Desktop::new(testing : Bool) -> Desktop {
  {
    session: @shared.Session::new(),
    page: 0,
    edit_index: -1,
    form: new_form(0),
    path: "",
    saved_revision: 0,
    status: "添加人员后即可记账。",
    draft: if testing {
      ""
    } else {
      @win32.draft_path()
    },
    autosave: true,
    testing,
    ai_config: { base_url: "", api_key: "", model: "", },
    ai_text: "",
    ai_preview: "",
    flow: @ai.Flow::new(),
    waiting: false,
    advanced_text: "",
    member_text: "",
    member_index: -1,
  }
}

///|
fn crlf(text : String) -> String {
  text.replace_all(old="\r\n", new="\n").replace_all(old="\n", new="\r\n")
}

///|
fn confirm(ui : Desktop, text : String) -> Bool {
  ui.testing || @win32.ask(text) == 6
}

///|
fn control(
  kind : Int32,
  id : Int32,
  text : String,
  x : Int32,
  y : Int32,
  w : Int32,
  h : Int32,
) -> Unit {
  @win32.control(kind, id, crlf(text), x, y, w, h)
}

///|
fn Desktop::capture(self : Desktop) -> Unit {
  if self.page != 1 {
    return
  }
  self.form.description = @win32.get_text(52)
  self.form.amount = @win32.get_text(53)
  self.form.date = @win32.get_text(54)
  self.form.payer = @win32.flag(51, 2, 0)
  for i = 0; i < self.session.ledger.people.length(); i = i + 1 {
    if self.form.exact {
      self.form.amounts[i] = @win32.get_text(2000 + i)
    } else {
      self.form.selected[i] = @win32.flag(1000 + i, 0, 0) == 1
    }
  }
}

///|
fn Desktop::payment(self : Desktop) -> @shared.Payment raise @shared.BillError {
  let people = self.session.ledger.people
  if self.form.payer < 0 || self.form.payer >= people.length() {
    @shared.invalid("请选择付款人")
  }
  let participants : Array[String] = []
  let shares : Array[@shared.Share] = []
  for i = 0; i < people.length(); i = i + 1 {
    if self.form.exact {
      let amount = @shared.parse_money(self.form.amounts[i].trim().to_owned())
      // A zero means non-participation in the form; core still accepts explicit zero shares.
      if amount > 0L {
        shares.push({ person: people[i], amount_cents: amount, })
      }
    } else if self.form.selected[i] {
      participants.push(people[i])
    }
  }
  let p : @shared.Payment = {
    payer: people[self.form.payer],
    amount_cents: @shared.parse_money(self.form.amount.trim().to_owned()),
    split_mode: if self.form.exact {
      @shared.Exact
    } else {
      @shared.Equal
    },
    participants,
    shares,
    description: self.form.description.trim().to_owned(),
    date: self.form.date.trim().to_owned(),
  }
  @shared.validate_payment(people, p)
  p
}

///|
fn Desktop::preview(self : Desktop) -> Unit {
  let text = try {
    let amount = @shared.parse_money(self.form.amount.trim().to_owned())
    if self.form.exact {
      let mut allocated = 0L
      for s in self.form.amounts {
        allocated = @shared.add_money(
          allocated,
          @shared.parse_money(s.trim().to_owned()),
        )
      }
      let diff = amount - allocated
      "已分配 " +
      @shared.money(allocated) +
      " 元；" +
      (if diff == 0L {
        "金额一致"
      } else if diff > 0L {
        "还差 " + @shared.money(diff) + " 元"
      } else {
        "多分配 " + @shared.money(-diff) + " 元"
      })
    } else {
      let p = self.payment()
      let preview = @shared.shares_for(self.session.ledger.people, p)
      for i = 0; i < self.session.ledger.people.length(); i = i + 1 {
        let name = self.session.ledger.people[i]
        let mut due = 0L
        for share in preview {
          if share.person == name {
            due = share.amount_cents
          }
        }
        ignore(
          @win32.set_text(1000 + i, name + "：" + @shared.money(due) + " 元"),
        )
      }
      "按名单顺序分配尾差；付款人可以不参与。"
    }
  } catch {
    e => @shared.error_message(e)
  }
  ignore(@win32.set_text(60, text))
  let ok = try {
    ignore(self.payment())
    true
  } catch {
    _ => false
  }
  ignore(@win32.flag(56, 4, if ok { 1 } else { 0 }))
}

///|
pub fn Desktop::render(self : Desktop) -> Unit {
  self.render_view()
}

///|
fn Desktop::capture_page(self : Desktop) -> Unit {
  self.capture()
  if self.page == 0 || self.page == 5 {
    self.member_text = @win32.get_text(11)
    self.member_index = @win32.flag(10, 2, 0)
  } else if self.page == 2 {
    self.advanced_text = @win32.get_text(70)
  } else if self.page == 3 {
    self.ai_config = {
      base_url: @win32.get_text(80),
      api_key: @win32.get_text(81),
      model: @win32.get_text(83),
    }
    self.ai_text = @win32.get_text(82)
  }
}

///|
fn Desktop::navigate(self : Desktop, target : Int32) -> Unit {
  if self.waiting || self.page == 4 {
    return
  }
  self.capture_page()
  if self.page == 1 &&
    self.form.changed &&
    !confirm(self, "放弃尚未保存的消费表单？") {
    return
  }
  if target == 3 && self.ai_config.base_url.is_empty() {
    self.ai_config = {
      base_url: @sys.environment("MOONBIT_BASE_URL"),
      api_key: @sys.environment("MOONBIT_API_KEY"),
      model: @sys.environment("MOONBIT_MODEL"),
    }
  }
  self.page = target
  self.render()
}

///|
fn Desktop::member_details(self : Desktop, index : Int32) -> String {
  if index < 0 || index >= self.session.ledger.people.length() {
    return "新增：输入姓名后点「添加成员」。\n\n修改：先选中左侧成员，再改名或删除。\n\n改名会同步更新付款人和所有分摊引用。\n有关联消费的成员不能直接删除，请先处理消费。"
  }
  let name = self.session.ledger.people[index]
  let mut count = 0
  for p in self.session.ledger.payments {
    if p.payer == name ||
      p.participants.contains(name) ||
      p.shares.any(s => s.person == name) {
      count = count + 1
    }
  }
  name +
  "\n\n关联消费：" +
  count.to_string() +
  " 笔\n\n" +
  (if count == 0 {
    "没有关联消费，可以删除。"
  } else {
    "如需删除，请先编辑或删除关联消费。改名会同步更新所有引用。"
  })
}

///|
fn Desktop::persist(self : Desktop) -> Unit {
  if !self.autosave || self.draft.is_empty() {
    return
  }
  try {
    @sys.write_file(self.draft, @shared.encode_ledger(self.session.ledger))
    self.status = "草稿已自动保存（正式账单请点击保存）。"
  } catch {
    e => {
      self.status = @shared.error_message(e)
      if !self.testing {
        @win32.notify(self.status)
      }
    }
  }
}

///|
fn Desktop::save(self : Desktop) -> Bool raise @shared.BillError {
  let path = if self.path.is_empty() {
    @win32.file_dialog(true)
  } else {
    self.path
  }
  if path.is_empty() {
    return false
  }
  @sys.write_file(path, @shared.encode_ledger(self.session.ledger))
  self.path = path
  self.saved_revision = self.session.revision
  self.status = "已保存：" + path
  true
}

///|
fn Desktop::can_leave(self : Desktop) -> Bool raise @shared.BillError {
  if self.testing || self.saved_revision == self.session.revision {
    return true
  }
  let answer = @win32.ask(
    "账单有未保存更改。是：保存；否：放弃；取消：返回。",
  )
  if answer == 6 {
    self.save()
  } else {
    answer == 7
  }
}

///|
fn Desktop::editor(
  self : Desktop,
  index : Int32,
) -> Unit raise @shared.BillError {
  let people = self.session.ledger.people
  if people.is_empty() {
    @shared.invalid("请先添加人员")
  }
  self.edit_index = index
  self.form = new_form(people.length())
  if index >= 0 {
    if index >= self.session.ledger.payments.length() {
      @shared.invalid("请选择消费")
    }
    let p = self.session.ledger.payments[index]
    self.form.description = p.description
    self.form.amount = @shared.money(p.amount_cents)
    self.form.date = p.date
    self.form.exact = p.split_mode == @shared.Exact
    for i = 0; i < people.length(); i = i + 1 {
      if people[i] == p.payer {
        self.form.payer = i
      }
      self.form.selected[i] = p.participants.contains(people[i])
      for s in p.shares {
        if s.person == people[i] {
          self.form.amounts[i] = @shared.money(s.amount_cents)
        }
      }
    }
  }
  self.page = 1
  self.render()
}

///|
pub fn Desktop::handle(
  self : Desktop,
  event : Int32,
) -> Unit raise @shared.BillError {
  if self.page == 0 || self.page == 5 {
    self.capture_page()
  }
  if event == 100 || event == 101 || event == 33 || event == 38 {
    self.navigate(
      if event == 100 {
        0
      } else if event == 101 {
        5
      } else if event == 33 {
        2
      } else {
        3
      },
    )
    return
  }
  if event == 9100 {
    if @http.state() == 1 {
      return
    }
    @win32.timer(false)
    if !self.waiting {
      return
    }
    self.waiting = false
    errdefer {
      self.status = "AI 请求或解析未完成，请检查错误后重试。"
      self.page = 3
      self.render()
    }
    let ledger = self.flow.receive(@http.result())
    self.ai_preview = @ai.preview(ledger)
    self.page = 4
    self.render()
    return
  }
  if self.page == 3 && event != 9002 && event != 9000 {
    self.ai_config = {
      base_url: @win32.get_text(80),
      api_key: @win32.get_text(81),
      model: @win32.get_text(83),
    }
    self.ai_text = @win32.get_text(82)
    if event == 85 {
      if self.waiting {
        @http.cancel()
        self.flow.cancel()
        self.waiting = false
        self.status = "已取消；已发出的请求可能仍在服务端处理。"
      }
      self.page = 0
      self.render()
    } else if event == 84 {
      let url = @ai.endpoint(self.ai_config)
      let body = @ai.request_body(self.ai_config, self.ai_text)
      self.flow = @ai.Flow::new()
      let consent = confirm(
        self,
        "将把上方输入框的完整账单发送到：\n" +
        url +
        "\n模型：" +
        self.ai_config.model +
        "\n数据将离开设备。确认发送？",
      )
      if !self.flow.send(consent) {
        return
      }
      @http.start(url, self.ai_config.api_key, body)
      self.waiting = true
      self.status = "请求进行中，完成后展示预览；可取消。"
      @win32.timer(true)
      self.render()
    }
    return
  }
  if self.page == 4 && event != 9002 && event != 9000 {
    if event == 87 {
      self.flow.cancel()
      self.page = 3
      self.render()
    } else if event == 86 {
      if !self.can_leave() {
        return
      }
      let report = self.flow.confirm(true)
      self.session.replace(report.ledger)
      self.member_text = ""
      self.member_index = -1
      self.session.report = Some(report)
      self.path = ""
      self.page = 0
      self.persist()
      self.status = "已确认 AI 账单，由 MoonBit 完成结算。"
      self.render()
    }
    return
  }
  if event == 9000 {
    let member_page = self.page == 0 || self.page == 5
    let member_text = if member_page { @win32.get_text(11) } else { "" }
    let person = if member_page { @win32.flag(10, 2, 0) } else { -1 }
    let payment = if self.page == 0 { @win32.flag(20, 2, 0) } else { -1 }
    self.capture_page()
    self.render()
    if member_page {
      ignore(@win32.set_text(11, member_text))
      ignore(@win32.flag(10, 3, person))
      if self.page == 5 {
        ignore(@win32.set_text(16, crlf(self.member_details(person))))
      }
    }
    if self.page == 0 {
      ignore(@win32.flag(20, 3, payment))
    }
    return
  }
  if event == 9002 {
    if self.page == 1 &&
      self.form.changed &&
      !confirm(self, "放弃尚未保存的消费表单？") {
      return
    }
    if self.can_leave() {
      @win32.close()
    }
    return
  }
  if self.page == 1 {
    self.capture()
    if event == 56 {
      self.session.put_payment(self.edit_index, self.payment())
      self.form.changed = false
      self.page = 0
      self.persist()
      self.render()
    } else if event == 57 {
      if !self.form.changed ||
        confirm(self, "放弃尚未保存的消费表单？") {
        self.page = 0
        self.render()
      }
    } else if event == 55 {
      self.form.exact = @win32.flag(55, 2, 0) == 1
      self.form.changed = true
      self.render()
    } else {
      self.form.changed = true
      self.preview()
    }
    return
  }
  if self.page == 2 {
    self.advanced_text = @win32.get_text(70)
    if event == 57 {
      self.navigate(0)
    } else if event == 72 || event == 73 || event == 74 {
      let example = if event == 72 {
        import_text_example()
      } else if event == 73 {
        import_json_example()
      } else {
        @shared.encode_ledger(self.session.ledger)
      }
      if self.advanced_text.trim().is_empty() ||
        confirm(
          self, "用示例或当前账单替换编辑框内容？当前账单不会改变。",
        ) {
        self.advanced_text = example
        ignore(@win32.set_text(70, crlf(example)))
      }
    } else if event == 71 {
      let ledger = import_ledger(self.advanced_text)
      let preview = ledger_preview(ledger)
      if confirm(self, preview + "\n确认替换当前账单？") &&
        self.can_leave() {
        self.session.replace(ledger)
        self.member_text = ""
        self.member_index = -1
        self.path = ""
        self.page = 0
        self.persist()
        self.status = "已导入账单；可继续编辑或统一结算。"
        self.render()
      }
    }
    return
  }
  if event == 10 {
    let i = @win32.flag(10, 2, 0)
    if i >= 0 && i < self.session.ledger.people.length() {
      self.member_text = self.session.ledger.people[i]
      self.member_index = i
      ignore(@win32.set_text(11, self.session.ledger.people[i]))
    }
    if self.page == 5 {
      ignore(@win32.set_text(16, crlf(self.member_details(i))))
      for id in [13, 14] {
        ignore(@win32.flag(id, 4, if i >= 0 { 1 } else { 0 }))
      }
    }
    return
  }
  if event == 15 && self.page == 5 {
    self.member_text = ""
    self.member_index = -1
    ignore(@win32.flag(10, 3, -1))
    ignore(@win32.set_text(11, ""))
    ignore(@win32.set_text(16, crlf(self.member_details(-1))))
    for id in [13, 14] {
      ignore(@win32.flag(id, 4, 0))
    }
    ignore(@win32.flag(11, 7, 0))
    return
  }
  if event == 12 || event == 13 || event == 14 {
    let i = @win32.flag(10, 2, 0)
    let name = @win32.get_text(11).trim().to_owned()
    if event == 12 {
      self.session.add_person(name)
      self.member_index = self.session.ledger.people.length() - 1
      self.member_text = name
    } else {
      if i < 0 || i >= self.session.ledger.people.length() {
        @shared.invalid("请先选择人员")
      }
      let old = self.session.ledger.people[i]
      if event == 13 {
        self.session.rename(old, name)
        self.member_text = name
      } else {
        if !confirm(self, "删除人员 " + old + "？") {
          return
        }
        self.session.remove_person(old)
        self.member_index = -1
        self.member_text = ""
      }
    }
    self.persist()
    self.render()
    return
  }
  if event == 21 {
    self.editor(-1)
  } else if event == 22 {
    let i = @win32.flag(20, 2, 0)
    if i < 0 {
      @shared.invalid("请选择消费")
    }
    self.editor(i)
  } else if event == 23 {
    let i = @win32.flag(20, 2, 0)
    if i < 0 {
      @shared.invalid("请选择消费")
    }
    if confirm(self, "删除选中的消费？") {
      self.session.remove_payment(i)
      self.persist()
      self.status = "已删除消费，请重新结算。"
      self.render()
    }
  } else if event == 30 {
    if self.can_leave() &&
      confirm(self, "新建空账单？旧草稿将由新账单替换。") {
      self.session.replace({ people: [], payments: [], ambiguous: [], })
      self.member_text = ""
      self.member_index = -1
      self.path = ""
      self.saved_revision = self.session.revision
      self.autosave = true
      self.persist()
      self.render()
    }
  } else if event == 31 {
    if !self.can_leave() {
      return
    }
    let path = @win32.file_dialog(false)
    if path.is_empty() {
      return
    }
    let ledger = @shared.decode_ledger(@sys.read_file(path), allow_empty=true)
    let preview = if ledger.people.is_empty() {
      "空账单"
    } else {
      @shared.render_text(@shared.settle(ledger))
    }
    if confirm(self, preview + "\n确认打开？") {
      self.session.replace(ledger)
      self.member_text = ""
      self.member_index = -1
      self.path = path
      self.saved_revision = self.session.revision
      self.persist()
      self.render()
    }
  } else if event == 32 {
    ignore(self.save())
    self.render()
  } else if event == 34 {
    ignore(self.session.solve())
    self.status = "已生成当前账单结算。"
    self.render()
  } else if event == 35 {
    match self.session.report {
      None => @shared.invalid("请先统一结算")
      Some(r) =>
        if @win32.clipboard(crlf(@shared.render_text(r))) {
          self.status = "结算单已复制。"
          self.render()
        } else {
          @shared.invalid(
            "复制失败，请在结算文本框中全选并手动复制",
          )
        }
    }
  } else if event == 36 {
    match self.session.report {
      None => @shared.invalid("请先统一结算")
      Some(r) => {
        let path = @win32.file_dialog(true)
        if !path.is_empty() {
          @sys.write_file(
            path,
            if path.has_suffix(".json") {
              @shared.render_report_json(r)
            } else if path.has_suffix(".md") {
              @shared.render_markdown(r)
            } else {
              @shared.render_text(r)
            },
          )
          self.status = "报表已导出：" + path
          self.render()
        }
      }
    }
  } else if event == 37 {
    if self.can_leave() &&
      confirm(self, "载入五人混合示例并替换当前账单？") {
      self.session.replace(@shared.sample_mixed())
      self.member_text = ""
      self.member_index = -1
      self.path = ""
      self.persist()
      self.render()
    }
  }
}

///|
pub fn run(demo~ : Bool = false, demo_page~ : Int32 = 0) -> Unit {
  if !@win32.supported() || !@win32.create(@shared.app_title(), true) {
    @win32.exit(1)
  }
  let ui = Desktop::new(false)
  if demo {
    try {
      ui.session.replace(@shared.sample_mixed())
      ignore(ui.session.solve())
    } catch {
      _ => @win32.exit(1)
    }
    ui.draft = ""
    ui.autosave = false
    ui.saved_revision = ui.session.revision
    ui.status = "演示模式：不恢复或自动写入草稿。正式账单请手动保存。"
    if demo_page == 1 {
      ui.editor(1) catch {
        _ => @win32.exit(1)
      }
    } else if demo_page == 3 {
      ui.ai_text = "我们是小明、小红、小刚、小美、小李。小明付了 200 元晚餐，五人平摊。小红付了 75 元奶茶，个人分别承担 12、15、18、14、16 元。"
      ui.page = 3
    } else if demo_page == 2 {
      ui.page = 2
      ui.advanced_text = import_text_example()
    } else if demo_page == 5 {
      ui.page = 5
    }
  }
  if !demo && !ui.draft.is_empty() && @sys.exists(ui.draft) {
    try {
      ui.session.replace(
        @shared.decode_ledger(@sys.read_file(ui.draft), allow_empty=true),
      )
      ui.status = "已恢复本地草稿。"
    } catch {
      e => {
        ui.autosave = false
        @win32.notify(
          "草稿未恢复，原文件保留；自动保存暂时关闭。\n" +
          @shared.error_message(e),
        )
      }
    }
  }
  ui.render()
  while true {
    let event = @win32.next_event()
    if event == 0 {
      break
    }
    if event < 0 {
      @win32.close()
      @win32.exit(1)
    }
    ui.handle(event) catch {
      e => @win32.notify(@shared.error_message(e))
    }
  }
}
