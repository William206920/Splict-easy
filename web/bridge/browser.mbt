///|
priv struct BrowserApp {
  state : WebState
  mut editing : Int32
  mut timer : Int32
  mut request : WebRequest?
  mut started : Bool
}

///|
let browser : BrowserApp = {
  state: WebState::new(),
  editing: -1,
  timer: 0,
  request: None,
  started: false,
}

///|
let web_storage : String = "spliteasy.online.ledger.v1"

///|
fn web_notice(message : String, error~ : Bool = false) -> Unit {
  io_clear_timer(browser.timer)
  io_text("notice", message)
  io_class("notice", if error { "toast error" } else { "toast" })
  io_hidden("notice", false)
  browser.timer = io_later(if error { 10000 } else { 4000 }, () => {
    io_hidden("notice", true)
  })
}

///|
fn web_safe(action : () -> Unit raise @shared.BillError) -> Unit {
  action() catch {
    error => web_notice(@shared.error_message(error), error=true)
  }
}

///|
fn browser_render() -> Unit raise @shared.BillError {
  let ledger = browser.state.ledger
  let page = web_present(ledger)
  io_text("stat-total", "¥ " + page.total)
  io_html("stat-people", ledger.people.length().to_string() + " <em>人</em>")
  io_html(
    "stat-payments",
    ledger.payments.length().to_string() + " <em>笔</em>",
  )
  io_html("expense-list", page.expenses)
  io_html("transfer-list", page.transfers)
  io_html("balance-rows", page.balances)
  io_html("member-list", page.members)
  io_text("ai-context", web_bill_context(ledger))
}

///|
fn browser_writable() -> Unit raise @shared.BillError {
  if browser.state.busy {
    @shared.invalid("AI 正在解析，请先取消请求再修改账单。")
  }
  match browser.state.corrupt {
    Some(source) => {
      if !io_confirm(
          "发现无法读取的旧草稿。继续将下载旧草稿备份，再保存新的账单。是否继续？",
        ) {
        @shared.invalid("已保留旧草稿")
      }
      io_download("SplitEasy-草稿恢复备份.txt", source, "text/plain")
      browser.state.corrupt = None
    }
    None => ()
  }
  let current = web_json(io_storage_read(web_storage))
  browser.state.writable(field(current, "value"), web_bool(current, "ok"))
}

///|
fn browser_persist() -> Unit raise @shared.BillError {
  let source = browser.state.source()
  if io_storage_write(web_storage, source) {
    browser.state.saved = source
  } else {
    web_notice(
      "当前账单可继续使用，但浏览器未能保存。请及时导出备份。",
      error=true,
    )
  }
  browser_render()
}

///|
fn browser_change(
  action : String,
  data : String,
) -> Unit raise @shared.BillError {
  browser_writable()
  browser.state.change(action, data)
  browser_persist()
}

///|
fn browser_navigate() -> Unit {
  io_route(web_route(io_hash()))
}

///|
fn browser_split() -> Unit {
  let exact = io_value("expense-mode") == "exact"
  io_hide_selector(".share-input", !exact)
  io_text(
    "split-hint",
    if exact {
      "勾选参与成员，并逐人填写金额（元）。合计必须等于实付。"
    } else {
      "选中的成员平摊，尾差按名单顺序给靠后者。"
    },
  )
}

///|
fn browser_expense(index : Int32) -> Unit raise @shared.BillError {
  browser_writable()
  let ledger = browser.state.ledger
  if ledger.people.is_empty() {
    io_set_hash("members")
    io_focus("member-name")
    @shared.invalid("先添加一起分账的成员吧。")
  }
  browser.editing = index
  let payment = ledger.payments.get(index)
  io_text(
    "expense-title",
    if payment is Some(_) {
      "编辑消费"
    } else {
      "添加消费"
    },
  )
  io_html("expense-payer", web_options(ledger.people))
  match payment {
    Some(p) => {
      io_set_value("expense-description", p.description)
      io_set_value("expense-amount", @shared.money(p.amount_cents))
      io_set_value("expense-payer", p.payer)
      io_set_value(
        "expense-mode",
        if p.split_mode == @shared.Equal {
          "equal"
        } else {
          "exact"
        },
      )
      io_set_value("expense-date", p.date)
    }
    None => {
      io_set_value("expense-description", "")
      io_set_value("expense-amount", "")
      io_set_value("expense-mode", "equal")
      io_set_value("expense-date", "")
    }
  }
  io_text("expense-error", "")
  io_html("participants", web_participants(ledger, payment))
  browser_split()
  io_dialog("expense-dialog", true)
  io_focus("expense-description")
}

///|
fn browser_save_expense() -> Unit {
  try {
    let payload = web_payment_payload(
      browser.editing,
      io_value("expense-payer"),
      io_value("expense-amount"),
      io_value("expense-description"),
      io_value("expense-date"),
      io_value("expense-mode"),
      io_selection(),
    )
    browser_change("put_payment", payload)
    io_dialog("expense-dialog", false)
    web_notice("消费已保存")
  } catch {
    error => io_text("expense-error", @shared.error_message(error))
  }
}

///|
fn browser_preview() -> Unit {
  match browser.state.preview {
    Some(preview) => {
      io_set_checked("preview-merge", preview.merge)
      io_set_checked("preview-replace", !preview.merge)
      io_set_checked("preview-duplicates", false)
      io_set_checked("preview-replace-consent", false)
      io_text("preview-source", preview.text)
      browser_preview_update()
      io_dialog("preview-dialog", true)
    }
    None => ()
  }
}

///|
fn browser_preview_update() -> Unit {
  match browser.state.preview {
    Some(p) => {
      let merge = io_checked("preview-merge")
      browser.state.preview = Some({ ..p, merge, })
      io_text("preview-error", "")
      io_hidden(
        "replace-consent-row",
        merge || browser.state.ledger.people.is_empty(),
      )
      let duplicates = browser.state.preview_duplicates()
      io_hidden("duplicate-consent-row", duplicates == 0)
      io_text(
        "duplicate-message",
        "发现 " +
        duplicates.to_string() +
        " 笔与已有记录或本次其他记录完全一致。它们不会被自动删除；我已核对，仍要记入。",
      )
      io_text(
        "apply-preview",
        if merge {
          "确认追加到账本"
        } else {
          "确认替换账单"
        },
      )
      io_class(
        "apply-preview",
        if merge {
          "primary"
        } else {
          "primary destructive"
        },
      )
      try {
        let result = browser.state.preview_result()
        io_html(
          "preview-content",
          web_preview_markup(browser.state.ledger, p.ledger, result, merge),
        )
        io_disabled("apply-preview", false)
      } catch {
        error => {
          io_html("preview-content", "")
          io_text("preview-error", @shared.error_message(error))
          io_disabled("apply-preview", true)
        }
      }
    }
    None => ()
  }
}

///|
fn browser_import(text : String) -> Unit raise @shared.BillError {
  browser_writable()
  browser.state.stage_import(text)
  browser_preview()
}

///|
fn browser_member(
  action : String,
  index : String,
) -> Unit raise @shared.BillError {
  let i = payment_index(index)
  match browser.state.ledger.people.get(i) {
    None => @shared.invalid("未知人员")
    Some(name) =>
      if action == "rename" {
        let input = web_json(
          io_prompt("修改成员姓名（会同步更新相关消费）", name),
        )
        if !web_bool(input, "cancelled") {
          browser_change(
            "rename",
            "{\"old\":" +
            @shared.quote_json(name) +
            ",\"name\":" +
            @shared.quote_json(field(input, "value").trim().to_owned()) +
            "}",
          )
        }
      } else if action == "remove" &&
        io_confirm("删除成员「" + name + "」？") {
        browser_change(
          "remove_person",
          "{\"name\":" + @shared.quote_json(name) + "}",
        )
      }
  }
}

///|
fn browser_file() -> Unit {
  let size = io_file_size("import-file")
  if size < 0 {
    return
  }
  if size > 2000000 {
    web_notice("文件不得超过 2 MB", error=true)
    io_set_value("import-file", "")
    return
  }
  if !io_value("import-text").is_empty() &&
    !io_confirm("用文件内容替换输入框？") {
    io_set_value("import-file", "")
    return
  }
  io_file_read("import-file", fn(ok, text) {
    if ok {
      io_set_value("import-text", text)
    } else {
      web_notice("无法读取文件", error=true)
    }
    io_set_value("import-file", "")
  })
}

///|
fn browser_ai_buttons() -> Unit {
  let enabled = match browser.state.service {
    Some(s) => s.enabled
    None => false
  }
  io_disabled("send-ai", browser.state.busy || !enabled)
  io_hidden("cancel-ai", !browser.state.busy)
  io_text(
    "send-ai",
    if browser.state.busy {
      "正在整理账单…"
    } else {
      "✧ 发送并解析"
    },
  )
}

///|
fn browser_service(status : Int32, text : String) -> Unit {
  try {
    if status < 200 || status >= 300 {
      @shared.invalid(
        "暂时无法连接 AI 服务。你仍可使用文本导入和普通记账。",
      )
    }
    let service = web_service(text)
    browser.state.service = Some(service)
    io_hidden("invite-field", !service.invite)
    io_text("ai-status", service.status())
  } catch {
    _ => {
      browser.state.service = None
      io_text(
        "ai-status", "暂时无法连接 AI 服务。你仍可使用文本导入和普通记账。",
      )
    }
  }
  browser_ai_buttons()
}

///|
fn browser_ai_complete(serial : Int32, status : Int32, text : String) -> Unit {
  if serial != browser.state.serial {
    return
  }
  web_safe(() => {
    if browser.state.finish_request(serial, status, text) {
      browser_preview()
      io_set_checked("ai-consent", false)
    }
  })
  browser.request = None
  browser_ai_buttons()
}

///|
fn browser_send_ai() -> Unit raise @shared.BillError {
  browser_writable()
  let text = io_value("ai-text").trim().to_owned()
  let code = io_value("invite-code")
  let confirmation = browser.state.prepare_ai(
    text,
    io_checked("ai-consent"),
    code,
  )
  if !io_confirm(confirmation) {
    return
  }
  let serial = browser.state.begin_request()
  browser_ai_buttons()
  let body = "{\"consent\":true,\"text\":" + @shared.quote_json(text) + "}"
  browser.request = Some(
    io_fetch(web_api_endpoint(io_api_config()), body, code, fn(
      status,
      response,
    ) {
      browser_ai_complete(serial, status, response)
    }),
  )
}

///|
fn browser_cancel_ai() -> Unit {
  browser.state.cancel_request()
  match browser.request {
    Some(request) => io_abort(request)
    None => ()
  }
  browser.request = None
  browser_ai_buttons()
  web_notice(
    "已取消，响应不会记入账单。已发出的模型请求仍可能产生费用。",
  )
}

///|
fn browser_report(markdown : Bool) -> Unit raise @shared.BillError {
  if browser.state.ledger.payments.is_empty() {
    web_notice("先添加消费后再导出结算单")
    return
  }
  let page = web_present(browser.state.ledger)
  if markdown {
    io_download("SplitEasy-结算单.md", page.markdown, "text/markdown")
  } else {
    io_copy(page.text, fn(ok) {
      if ok {
        web_notice("已复制结算单")
      } else {
        io_download("SplitEasy-结算单.txt", page.text, "text/plain")
        web_notice("无法访问剪贴板，已下载文本结算单")
      }
    })
  }
}

///|
pub fn browser_start() -> Unit {
  if browser.started {
    return
  }
  browser.started = true
  try {
    let stored = web_json(io_storage_read(web_storage))
    if web_bool(stored, "ok") {
      browser.state.load(field(stored, "value"))
    }
  } catch {
    _ =>
      web_notice(
        "旧草稿无法读取，已保留原内容。请先导出备份后再记账。",
        error=true,
      )
  }
  web_safe(browser_render)
  browser_navigate()
  io_hash_change(browser_navigate)
  io_storage_change(web_storage, () => {
    web_notice(
      "另一个标签页更新了账单。请导出当前记录后刷新，避免覆盖。",
      error=true,
    )
  })
  io_on("new-expense", "click", () => web_safe(() => browser_expense(-1)))
  io_on("expense-mode", "change", browser_split)
  io_on("close-expense", "click", () => io_dialog("expense-dialog", false))
  io_on("cancel-expense", "click", () => io_dialog("expense-dialog", false))
  io_on("expense-form", "submit", browser_save_expense)
  io_delegate("expense-list", "edit,delete", fn(action, index) {
    web_safe(() => {
      if action == "edit" {
        browser_expense(payment_index(index))
      } else if action == "delete" && io_confirm("删除这笔消费？") {
        browser_change(
          "remove_payment",
          "{\"index\":" + @shared.quote_json(index) + "}",
        )
        web_notice("消费已删除")
      }
    })
  })
  io_on("member-form", "submit", () => {
    web_safe(() => {
      browser_change(
        "add_person",
        "{\"name\":" +
        @shared.quote_json(io_value("member-name").trim().to_owned()) +
        "}",
      )
      io_set_value("member-name", "")
      io_focus("member-name")
      web_notice("成员已添加")
    })
  })
  io_delegate("member-list", "rename,remove", fn(action, index) {
    web_safe(() => browser_member(action, index))
  })
  io_on("load-sample", "click", () => web_safe(() => browser_import(web_sample)))
  io_on("text-sample", "click", () => {
    if io_value("import-text").is_empty() ||
      io_confirm("用文本示例替换输入框内容？") {
      io_set_value("import-text", web_sample)
    }
  })
  io_on("json-sample", "click", () => {
    web_safe(() => {
      if io_value("import-text").is_empty() ||
        io_confirm("用 JSON 示例替换输入框内容？") {
        io_set_value(
          "import-text",
          @shared.encode_ledger(
            mutate(
              "import",
              browser.state.source(),
              "{\"text\":" + @shared.quote_json(web_sample) + "}",
            ),
          ),
        )
      }
    })
  })
  io_on("preview-import", "click", () => {
    web_safe(() => browser_import(io_value("import-text")))
  })
  io_on("import-file", "change", browser_file)
  io_on("cancel-preview", "click", () => {
    browser.state.preview = None
    io_dialog("preview-dialog", false)
  })
  io_on("preview-dialog", "cancel", () => browser.state.preview = None)
  for id in ["preview-merge", "preview-replace"] {
    io_on(id, "change", () => {
      io_set_checked("preview-duplicates", false)
      io_set_checked("preview-replace-consent", false)
      browser_preview_update()
    })
  }
  io_on("apply-preview", "click", () => {
    try {
      browser_writable()
      let merge = io_checked("preview-merge")
      browser.state.apply_preview(
        duplicates_confirmed=io_checked("preview-duplicates"),
        replacement_confirmed=io_checked("preview-replace-consent"),
      )
      browser_persist()
      io_dialog("preview-dialog", false)
      io_set_hash("overview")
      web_notice(
        if merge {
          "已追加到账本，原有记录已保留"
        } else {
          "已确认并替换账单"
        },
      )
    } catch {
      error => io_text("preview-error", @shared.error_message(error))
    }
  })
  io_on("clear-ledger", "click", () => {
    web_safe(() => {
      if io_confirm(
          "新建空账本会替换当前账单。需要保留时请先导出。是否继续？",
        ) {
        browser_writable()
        browser.state.replace(mutate("view", web_empty, "{}"))
        browser_persist()
        web_notice("已新建空账本")
      }
    })
  })
  io_on("export-json", "click", () => {
    io_download(
      "SplitEasy-账单.json",
      browser.state.source(),
      "application/json",
    )
  })
  io_on("export-md", "click", () => web_safe(() => browser_report(true)))
  io_on("copy-report", "click", () => web_safe(() => browser_report(false)))
  io_on("ai-sample", "click", () => {
    if io_value("ai-text").is_empty() ||
      io_confirm("用示例替换输入文字？") {
      io_set_value("ai-text", web_free_sample)
    }
  })
  io_on("send-ai", "click", () => web_safe(browser_send_ai))
  io_on("cancel-ai", "click", browser_cancel_ai)
  io_before_unload(() => browser.state.busy || io_dialog_open("expense-dialog"))
  browser_ai_buttons()
  ignore(io_fetch(web_api_endpoint(io_api_config()), "", "", browser_service))
}
