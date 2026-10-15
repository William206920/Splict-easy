///|
/// Escape every user string; never place user input into attributes or CSS.
pub fn escape_html(text : String) -> String {
  let out = StringBuilder()
  for ch in text.iter() {
    match ch {
      '&' => out.write_string("&amp;")
      '<' => out.write_string("&lt;")
      '>' => out.write_string("&gt;")
      '"' => out.write_string("&quot;")
      '\'' => out.write_string("&#39;")
      _ => out.write_char(ch)
    }
  }
  out.to_string()
}

///|
pub fn render_error_html(message : String) -> String {
  "<div class=\"spliteasy-error\" role=\"alert\"><strong>无法结算：</strong>" +
  escape_html(message) +
  "</div>"
}

///|
/// HTML fragment for embedding; all text fields, including dates, are escaped.
pub fn render_html(report : SettlementReport) -> String {
  let out = StringBuilder()
  out.write_string(
    "<section class=\"spliteasy-report\" aria-label=\"SplitEasy 结算单\">\n<h1>SplitEasy 结算单</h1>\n",
  )
  out.write_string(
    "<p>总消费：<strong>" +
    format_money(report.total_cents) +
    " 元</strong></p>\n<h2>消费明细</h2>\n",
  )
  if report.payments.is_empty() {
    out.write_string("<p>暂无消费记录。</p>\n")
  }
  for i, payment in report.payments {
    out.write_string(
      "<article><h3>第 \{i + 1} 笔：" +
      escape_html(payment.description) +
      "</h3>\n",
    )
    out.write_string(
      "<p>付款人：" +
      escape_html(payment.payer) +
      "；金额：" +
      format_money(payment.amount_cents) +
      " 元；分摊方式：" +
      mode_label(payment.split_mode) +
      "</p>\n",
    )
    out.write_string(
      "<p>日期：" +
      (if payment.date.is_empty() {
        "未填写"
      } else {
        escape_html(payment.date)
      }) +
      "</p>\n<ul>\n",
    )
    for share in payment.shares {
      out.write_string(
        "<li>" +
        escape_html(share.person) +
        "：" +
        format_money(share.amount_cents) +
        " 元</li>\n",
      )
    }
    out.write_string("</ul></article>\n")
  }
  out.write_string(
    "<h2>每人净额</h2>\n<div class=\"table-scroll\"><table><thead><tr><th>人员</th><th>已付（元）</th><th>应付（元）</th><th>净额（元）</th></tr></thead><tbody>\n",
  )
  for balance in report.balances {
    let (color, label) = if balance.balance_cents > 0L {
      ("#15803d", "应收")
    } else if balance.balance_cents < 0L {
      ("#b91c1c", "应付")
    } else {
      ("#475569", "已平账")
    }
    out.write_string(
      "<tr><td>" +
      escape_html(balance.person) +
      "</td><td>" +
      format_money(balance.paid_cents) +
      "</td><td>" +
      format_money(balance.owed_cents) +
      "</td><td style=\"color:" +
      color +
      "\">" +
      label +
      " " +
      format_signed_money(balance.balance_cents) +
      "</td></tr>\n",
    )
  }
  out.write_string("</tbody></table></div>\n<h2>转账清单</h2>\n")
  if report.transfers.is_empty() {
    out.write_string("<p>无需转账，所有人已平账。</p>\n")
  } else {
    out.write_string("<ol>\n")
    for transfer in report.transfers {
      out.write_string(
        "<li>" +
        escape_html(transfer.from) +
        " → " +
        escape_html(transfer.to) +
        "：" +
        format_money(transfer.amount_cents) +
        " 元</li>\n",
      )
    }
    out.write_string("</ol>\n")
  }
  out.write_string(
    "<p>结算计算完成。转账清单仅为建议，不代表已经完成付款。</p>\n</section>\n",
  )
  out.to_string()
}

///|
/// Standalone offline document; no scripts, external fonts, or CDN resources.
pub fn render_html_document(report : SettlementReport) -> String {
  "<!doctype html>\n<html lang=\"zh-CN\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><title>SplitEasy 结算单</title>\n<style>body{margin:0;background:#f4f7f8;color:#182b31;font:16px/1.6 system-ui,sans-serif}main{max-width:640px;margin:auto;padding:20px}article{background:white;border-radius:12px;padding:16px;margin:12px 0}h1,h2,h3,p,li,td,th{overflow-wrap:anywhere}table{width:100%;border-collapse:collapse;background:white}td,th{padding:8px;text-align:left;border-bottom:1px solid #dce5e8;vertical-align:top}th{white-space:nowrap}td:first-child,th:first-child{min-width:3em;white-space:pre-wrap}td:nth-child(2),td:nth-child(3){white-space:nowrap}td:last-child{overflow-wrap:normal}.table-scroll{overflow-x:auto}article h3,article p,li{white-space:pre-wrap}</style></head><body><main>\n" +
  render_html(report) +
  "</main></body></html>\n"
}
