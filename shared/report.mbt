///|
fn md_cell(text : String) -> String {
  text
  .replace(old="\\", new="\\\\")
  .replace(old="|", new="\\|")
  .replace(old="\r", new=" ")
  .replace(old="\n", new=" ")
  .replace(old="<", new="&lt;")
  .replace(old=">", new="&gt;")
}

///|
pub fn render_markdown(report : Report) -> String {
  let rows : Array[String] = [
    "# SplitEasy 结算单",
    "",
    "总消费：" + money(report.total_cents) + " 元",
    "",
    "## 消费明细",
    "",
    "| 消费 | 付款人 | 实付 | 分摊方式 | 日期 |",
    "| --- | --- | ---: | --- | --- |",
  ]
  for p in report.ledger.payments {
    rows.push(
      "| " +
      md_cell(p.description) +
      " | " +
      md_cell(p.payer) +
      " | " +
      money(p.amount_cents) +
      " | " +
      (if p.split_mode == Equal { "平均" } else { "实际金额" }) +
      " | " +
      md_cell(p.date) +
      " |",
    )
    rows.push("")
    rows.push("承担明细：" + shares_for_render(report.ledger.people, p))
  }
  rows.push("")
  rows.push("## 人员汇总")
  rows.push("")
  rows.push(
    "| 人员 | 已付 | 应承担 | 净额（正应收，负应付） |",
  )
  rows.push("| --- | ---: | ---: | ---: |")
  for b in report.balances {
    rows.push(
      "| " +
      md_cell(b.person) +
      " | " +
      money(b.paid_cents) +
      " | " +
      money(b.due_cents) +
      " | " +
      money(b.balance_cents) +
      " |",
    )
  }
  rows.push("")
  rows.push("## 转账清单")
  rows.push("")
  if report.transfers.is_empty() {
    rows.push("无需转账。")
  } else {
    for i = 0; i < report.transfers.length(); i = i + 1 {
      let t = report.transfers[i]
      rows.push(
        (i + 1).to_string() +
        ". " +
        md_cell(t.from) +
        " → " +
        md_cell(t.to) +
        "：" +
        money(t.amount_cents) +
        " 元。",
      )
    }
  }
  rows.push("")
  rows.push(
    "按确定性贪心尽量减少转账，不保证全局最少笔数。",
  )
  rows.join("\n") + "\n"
}

///|
fn shares_for_render(people : Array[String], p : Payment) -> String {
  shares_for(people, p)
  .map(s => md_cell(s.person) + " " + money(s.amount_cents) + " 元")
  .join("；") catch {
    _ => "无效份额"
  }
}

///|
pub fn render_text(report : Report) -> String {
  let lines : Array[String] = [
    "SplitEasy 结算单",
    "总消费：" + money(report.total_cents) + " 元",
    "",
  ]
  for p in report.ledger.payments {
    lines.push(
      p.description +
      " | " +
      p.payer +
      " 付款 " +
      money(p.amount_cents) +
      " 元 | " +
      (if p.split_mode == Equal { "平均" } else { "实际金额" }),
    )
    try {
      for s in shares_for(report.ledger.people, p) {
        lines.push("  " + s.person + "：" + money(s.amount_cents) + " 元")
      }
    } catch {
      _ => ()
    }
  }
  lines.push("")
  for b in report.balances {
    lines.push(
      b.person +
      "：已付 " +
      money(b.paid_cents) +
      "，应承担 " +
      money(b.due_cents) +
      "，" +
      (if b.balance_cents > 0L {
        "应收 "
      } else if b.balance_cents < 0L {
        "应付 "
      } else {
        "已平衡 "
      }) +
      money(
        if b.balance_cents < 0L {
          -b.balance_cents
        } else {
          b.balance_cents
        },
      ) +
      " 元",
    )
  }
  lines.push("")
  lines.push("转账清单：")
  if report.transfers.is_empty() {
    lines.push("无需转账。")
  }
  for t in report.transfers {
    lines.push(t.from + " → " + t.to + "：" + money(t.amount_cents) + " 元")
  }
  lines.join("\n") + "\n"
}

///|
pub fn render_report_json(report : Report) -> String {
  let balances = report.balances.map(b => {
    "{\"person\":" +
    quote_json(b.person) +
    ",\"paid_cents\":" +
    b.paid_cents.to_string() +
    ",\"due_cents\":" +
    b.due_cents.to_string() +
    ",\"balance_cents\":" +
    b.balance_cents.to_string() +
    "}"
  })
  let transfers = report.transfers.map(t => {
    "{\"from\":" +
    quote_json(t.from) +
    ",\"to\":" +
    quote_json(t.to) +
    ",\"amount_cents\":" +
    t.amount_cents.to_string() +
    "}"
  })
  "{\"report_version\":1,\"total_cents\":" +
  report.total_cents.to_string() +
  ",\"ledger\":" +
  encode_ledger(report.ledger) +
  ",\"balances\":[" +
  balances.join(",") +
  "],\"transfers\":[" +
  transfers.join(",") +
  "]}\n"
}
