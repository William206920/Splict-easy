///|
fn web_total(ledger : @shared.Ledger) -> Int64 raise @shared.BillError {
  let mut total = 0L
  for p in ledger.payments {
    total = @shared.add_money(total, p.amount_cents)
  }
  total
}

///|
fn web_bill_context(ledger : @shared.Ledger) -> String raise @shared.BillError {
  if ledger.payments.is_empty() {
    "从第一笔开始 · 解析后先预览，确认才记入账本。"
  } else {
    "当前账本 " +
    ledger.payments.length().to_string() +
    " 笔 · ¥ " +
    @shared.money(web_total(ledger)) +
    "。解析后默认追加，请只描述这次新增的消费。"
  }
}

///|
fn web_preview_stat(label : String, value : String) -> String {
  "<div><span>" +
  web_escape(label) +
  "</span><strong>" +
  web_escape(value) +
  "</strong></div>"
}

///|
fn web_preview_markup(
  current : @shared.Ledger,
  incoming : @shared.Ledger,
  result : @shared.Ledger,
  merge : Bool,
) -> String raise @shared.BillError {
  let rows : Array[String] = []
  let new_people = incoming.people.filter(name => !current.people.contains(name))
  let impact = if merge {
    "保留原有 " +
    current.payments.length().to_string() +
    " 笔，追加 " +
    incoming.payments.length().to_string() +
    " 笔，合计 " +
    result.payments.length().to_string() +
    " 笔。"
  } else {
    "用本次 " +
    incoming.payments.length().to_string() +
    " 笔替换原有 " +
    current.payments.length().to_string() +
    " 笔。"
  }
  rows.push(
    "<section class=\"preview-impact\" aria-label=\"确认后的变化\"><p class=\"impact-label\">" +
    (if merge {
      "追加后，你的账本会是这样"
    } else {
      "替换后，你的账本会是这样"
    }) +
    "</p><div class=\"preview-stats\">" +
    web_preview_stat("当前账本", "¥ " + @shared.money(web_total(current))) +
    web_preview_stat("本次解析", "¥ " + @shared.money(web_total(incoming))) +
    web_preview_stat(
      "确认后总额",
      "¥ " + @shared.money(web_total(result)),
    ) +
    "</div><p>" +
    web_escape(impact) +
    "</p></section>",
  )
  if merge {
    rows.push(
      "<p class=\"preview-members\">同名成员沿用当前名单，新成员追加到末尾；原有消费的参与人不变。" +
      (if new_people.is_empty() {
        ""
      } else {
        "新增成员：" + web_escape(new_people.join("、")) + "。"
      }) +
      "</p>",
    )
  } else {
    rows.push(
      "<p class=\"preview-members\">替换会移除原有成员与消费；需要保留时请先取消并导出账单。</p>",
    )
  }
  rows.push(
    "<h3 class=\"preview-list-title\">逐笔核对本次记录 <span>" +
    incoming.payments.length().to_string() +
    " 笔</span></h3><ol class=\"preview-payments\">",
  )
  for i = 0; i < incoming.payments.length(); i = i + 1 {
    let p = incoming.payments[i]
    let shares = @shared.shares_for(result.people, p)
    let details : Array[String] = []
    for share in shares {
      details.push(
        "<span>" +
        web_escape(share.person) +
        " <b>¥ " +
        @shared.money(share.amount_cents) +
        "</b></span>",
      )
    }
    rows.push(
      "<li><div class=\"preview-payment-heading\"><span class=\"preview-number\">" +
      (i + 1).to_string() +
      "</span><div><strong>" +
      web_escape(p.description) +
      "</strong><p>" +
      web_escape(p.payer) +
      " 付款 · " +
      (if p.split_mode == @shared.Equal {
        "平均分摊"
      } else {
        "按实际金额"
      }) +
      (if p.date.is_empty() { "" } else { " · " + web_escape(p.date) }) +
      "</p></div><strong class=\"preview-amount\">¥ " +
      @shared.money(p.amount_cents) +
      "</strong></div><div class=\"preview-shares\">" +
      details.join("") +
      "</div></li>",
    )
  }
  if incoming.payments.is_empty() {
    rows.push(
      "<li class=\"empty\">本次没有消费记录，仅包含成员名单。</li>",
    )
  }
  rows.push(
    "</ol><p class=\"preview-members\">份额按最终成员顺序计算尾差。AI 可能理解错误，请核对付款人、金额和参与成员。</p>",
  )
  rows.join("")
}
