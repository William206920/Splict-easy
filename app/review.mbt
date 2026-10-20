///|
fn ledger_total(ledger : @shared.Ledger) -> Int64 raise @shared.BillError {
  let mut total = 0L
  for payment in ledger.payments {
    total = @shared.add_money(total, payment.amount_cents)
  }
  total
}

///|
fn Desktop::begin_review(
  self : Desktop,
  incoming : @shared.Ledger,
  from_ai : Bool,
) -> Unit raise @shared.BillError {
  let validated = @shared.Session::new()
  validated.replace(incoming)
  self.pending = Some(validated.ledger)
  self.review_revision = self.session.revision
  self.review_ai = from_ai
  self.review_append = from_ai
  self.review_duplicates_ok = false
  self.review_replace_ok = false
  self.page = 4
  self.refresh_review()
}

///|
fn Desktop::review_incoming(
  self : Desktop,
) -> @shared.Ledger raise @shared.BillError {
  if self.page != 4 || self.review_revision != self.session.revision {
    @shared.invalid("账本已变化，请取消并重新生成预览")
  }
  match self.pending {
    Some(ledger) => ledger
    None => {
      @shared.invalid("没有待确认的账单")
      self.session.ledger
    }
  }
}

///|
fn Desktop::review_result(
  self : Desktop,
) -> @shared.Ledger raise @shared.BillError {
  let incoming = self.review_incoming()
  if self.review_append {
    @shared.merge_ledgers(self.session.ledger, incoming)
  } else {
    incoming
  }
}

///|
fn Desktop::review_duplicates(self : Desktop) -> Int32 raise @shared.BillError {
  @shared.duplicate_payments(
    if self.review_append {
      self.session.ledger
    } else {
      { people: [], payments: [], ambiguous: [], }
    },
    self.review_incoming(),
  )
}

///|
fn Desktop::refresh_review(self : Desktop) -> Unit raise @shared.BillError {
  let incoming = self.review_incoming()
  // A failed append (for example a size limit) must still allow replacement.
  self.ai_preview = try {
    let result = self.review_result()
    let lines = [
      "当前 " +
      self.session.ledger.payments.length().to_string() +
      " 笔 / " +
      @shared.money(ledger_total(self.session.ledger)) +
      " 元",
      "本次 " +
      incoming.payments.length().to_string() +
      " 笔 / " +
      @shared.money(ledger_total(incoming)) +
      " 元",
      "确认后 " +
      result.payments.length().to_string() +
      " 笔 / " +
      @shared.money(ledger_total(result)) +
      " 元",
      "",
      "本次消费明细（按最终名单计算份额）",
      "",
    ]
    for payment in incoming.payments {
      lines.push(
        payment.description +
        " · " +
        payment.payer +
        " 支付 " +
        @shared.money(payment.amount_cents) +
        " 元",
      )
      for share in @shared.shares_for(result.people, payment) {
        lines.push(
          "    " +
          share.person +
          "：" +
          @shared.money(share.amount_cents) +
          " 元",
        )
      }
      lines.push("")
    }
    let added = incoming.people.filter(name => {
      !self.session.ledger.people.contains(name)
    })
    if incoming.payments.is_empty() {
      lines.push(ledger_preview(incoming))
    }
    lines.push(
      "新增成员：" +
      (if added.is_empty() { "无" } else { added.join("、") }),
    )
    lines.push("同名成员合并；新增成员不参与以前的消费。")
    lines.join("\n")
  } catch {
    error =>
      "暂时无法记入：" +
      @shared.error_message(error) +
      "\n可以取消，或取消勾选追加后核对替换。"
  }
}

///|
fn Desktop::apply_review(self : Desktop) -> Unit raise @shared.BillError {
  let result = self.review_result()
  if self.review_duplicates() > 0 && !self.review_duplicates_ok {
    @shared.invalid(
      "存在完全相同的消费，请勾选重复记录核对确认",
    )
  }
  if !self.review_append &&
    (
      !self.session.ledger.people.is_empty() ||
      !self.session.ledger.payments.is_empty()
    ) &&
    !self.review_replace_ok {
    @shared.invalid("替换会移除当前账单，请勾选替换确认")
  }
  // Compute everything before touching the current session or consuming preview.
  let report = if result.payments.is_empty() {
    None
  } else {
    Some(@shared.settle(result))
  }
  if !self.review_append && !self.can_leave() {
    return
  }
  self.session.replace(result)
  self.session.report = report
  self.pending = None
  self.flow.cancel()
  self.member_text = ""
  self.member_index = -1
  if !self.review_append {
    self.path = ""
  }
  self.page = 0
  self.persist()
  self.status = if self.review_append {
    "已追加到账本，原有消费完整保留。"
  } else {
    "已确认替换账单。"
  }
}

///|
fn Desktop::review_view(self : Desktop, x : Int32, w : Int32) -> Unit {
  self.shell(
    "核对并记入账本", "先查看金额变化和逐笔份额，确认后才写入。",
    960,
  )
  panel(600, x, 136, w, 118)
  control(19, 601, "选择记入方式", x + 24, 151, w - 48, 30)
  control(
    4,
    90,
    "追加到当前账单（保留原记录）",
    x + 24,
    193,
    w - 48,
    32,
  )
  ignore(@win32.flag(90, 1, if self.review_append { 1 } else { 0 }))
  panel(602, x, 270, w, 390)
  control(7, 88, self.ai_preview, x + 24, 290, w - 48, 348)
  control(4, 91, "我确认替换，移除当前成员和消费", x, 680, w, 32)
  ignore(@win32.flag(91, 1, if self.review_replace_ok { 1 } else { 0 }))
  ignore(@win32.flag(91, 4, if self.review_append { 0 } else { 1 }))
  let duplicates = self.review_duplicates() catch { _ => 0 }
  control(
    4,
    92,
    if duplicates > 0 {
      "发现 " +
      duplicates.to_string() +
      " 笔可能重复；我已核对，仍需记入"
    } else {
      "未发现完全相同的消费记录"
    },
    x,
    726,
    w,
    32,
  )
  ignore(@win32.flag(92, 1, if self.review_duplicates_ok { 1 } else { 0 }))
  ignore(@win32.flag(92, 4, if duplicates > 0 { 1 } else { 0 }))
  control(
    14,
    86,
    if self.review_append {
      "确认追加并结算"
    } else {
      "确认替换并结算"
    },
    x,
    790,
    220,
    42,
  )
  control(1, 87, "取消，返回修改", x + 236, 790, 160, 42)
  control(
    28, 89, "取消不会修改原账本；相似消费仍请人工核对。", x,
    852, w, 48,
  )
  ignore(@win32.flag(100, 4, 0))
}
