///|
/// Escape user text for GFM tables/list text, including raw HTML and line breaks.
pub fn escape_markdown(text : String) -> String {
  let out = StringBuilder()
  let normalized = text
    .replace_all(old="\r\n", new="\n")
    .replace_all(old="\r", new="\n")
  for ch in normalized.iter() {
    match ch {
      '&' => out.write_string("&amp;")
      '<' => out.write_string("&lt;")
      '>' => out.write_string("&gt;")
      '\n' => out.write_string("<br>")
      '\t' => out.write_char(' ')
      '\\'
      | '|'
      | '*'
      | '_'
      | '['
      | ']'
      | '('
      | ')'
      | '`'
      | '#'
      | '+'
      | '-'
      | '!'
      | '~' => {
        out.write_char('\\')
        out.write_char(ch)
      }
      _ => out.write_char(ch)
    }
  }
  out.to_string()
}

///|
pub fn render_markdown(report : SettlementReport) -> String {
  let out = StringBuilder()
  out.write_string(
    "# SplitEasy 结算单\n\n总消费：" +
    format_money(report.total_cents) +
    " 元\n\n## 消费明细\n\n",
  )
  out.write_string(
    "| 序号 | 消费 | 付款人 | 金额（元） | 分摊方式 | 日期 |\n|---|---|---|---:|---|---|\n",
  )
  for i, payment in report.payments {
    out.write_string(
      "| \{i + 1} | " +
      escape_markdown(payment.description) +
      " | " +
      escape_markdown(payment.payer) +
      " | " +
      format_money(payment.amount_cents) +
      " | " +
      mode_label(payment.split_mode) +
      " | " +
      escape_markdown(payment.date) +
      " |\n",
    )
  }
  if report.payments.is_empty() {
    out.write_string("\n暂无消费记录。\n")
  }
  for i, payment in report.payments {
    out.write_string("\n第 \{i + 1} 笔分摊：")
    for j, share in payment.shares {
      if j > 0 {
        out.write_string("；")
      }
      out.write_string(
        escape_markdown(share.person) +
        " " +
        format_money(share.amount_cents) +
        " 元",
      )
    }
    out.write_string("\n")
  }
  out.write_string(
    "\n## 每人净额\n\n| 人员 | 已付（元） | 应付（元） | 净额（元） |\n|---|---:|---:|---:|\n",
  )
  for balance in report.balances {
    out.write_string(
      "| " +
      escape_markdown(balance.person) +
      " | " +
      format_money(balance.paid_cents) +
      " | " +
      format_money(balance.owed_cents) +
      " | " +
      format_signed_money(balance.balance_cents) +
      " |\n",
    )
  }
  out.write_string("\n## 转账清单\n\n")
  if report.transfers.is_empty() {
    out.write_string("无需转账，所有人已平账。\n")
  } else {
    for i, transfer in report.transfers {
      out.write_string(
        "\{i + 1}. " +
        escape_markdown(transfer.from) +
        " → " +
        escape_markdown(transfer.to) +
        "：" +
        format_money(transfer.amount_cents) +
        " 元\n",
      )
    }
  }
  out.write_string(
    "\n结算计算完成。转账清单仅为建议，不代表已经完成付款。\n",
  )
  out.to_string()
}
