///|
fn export_escape(text : String) -> String {
  text
  .replace_all(old="&", new="&amp;")
  .replace_all(old="<", new="&lt;")
  .replace_all(old=">", new="&gt;")
  .replace_all(old="\"", new="&quot;")
  .replace_all(old="'", new="&#39;")
}

///|
pub fn export_html(ledger : Ledger) -> String raise BillError {
  let tables = export_tables(ledger)
  let out = [
    "<!doctype html><html lang=\"zh-CN\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\"><title>SplitEasy 结算单</title><style>",
    "*{box-sizing:border-box}body{margin:0;background:#eef2f8;color:#172b46;font:15px/1.7 system-ui,'Microsoft YaHei',sans-serif}main{max-width:1100px;margin:32px auto;padding:32px;background:white;border:1px solid #dbe3ee;border-radius:16px}header{border-bottom:3px solid #4263eb;padding-bottom:20px;margin-bottom:28px}h1{font-size:30px;margin:0 0 8px}h2{font-size:21px;margin:0 0 8px}p{margin:8px 0;color:#50627a}.brand{font-size:13px;letter-spacing:.08em;color:#4263eb;font-weight:700}.table-wrap{overflow:auto;border:1px solid #dbe3ee;border-radius:10px}table{width:100%;border-collapse:collapse;text-align:left}th{background:#203653;color:white;font-size:14px;padding:12px;white-space:nowrap}td{padding:12px;border-top:1px solid #e4eaf2;vertical-align:top;overflow-wrap:anywhere;white-space:pre-wrap}tbody tr:nth-child(even){background:#f6f8fc}.amount{text-align:right;white-space:nowrap;font-variant-numeric:tabular-nums;font-weight:600}section{margin:28px 0}.note{font-size:13px;margin:12px 0 18px}button{float:right;background:#4263eb;border:0;border-radius:8px;padding:11px 18px;color:white;font:inherit;cursor:pointer}footer{border-top:1px solid #dbe3ee;padding-top:16px;color:#50627a;font-size:12px}@media(max-width:640px){main{margin:0;padding:18px;border:0;border-radius:0}h1{font-size:24px}button{float:none;margin-bottom:12px}th,td{padding:9px;min-width:88px}.table-wrap{border-radius:6px}}@media print{@page{size:A4 landscape;margin:14mm}body{background:white;font-size:10pt}main{padding:0;margin:0;max-width:none;border:0}button{display:none}.table-wrap{overflow:visible;border-radius:0}table{table-layout:fixed}th,td{padding:7px;min-width:0}th{background:#e7edf7;color:#172b46}thead{display:table-header-group}tr{break-inside:avoid}h2{break-after:avoid}footer{font-size:9pt}.amount{white-space:normal}}",
    "</style></head><body><main><header><button type=\"button\" onclick=\"window.print()\">打印 / 保存为 PDF</button><div class=\"brand\">SPLITEASY · 结算快照</div><h1>把账算清，安心相聚</h1><p>所有金额单位为人民币元；以下是待执行的转账建议，不代表付款已经完成。</p></header>",
  ]
  for table in tables {
    out.push(
      "<section><h2>" +
      export_escape(table.name) +
      "</h2><p class=\"note\">" +
      export_escape(table.note) +
      "</p><div class=\"table-wrap\"><table><thead><tr>",
    )
    for heading in table.headers {
      out.push("<th scope=\"col\">" + export_escape(heading) + "</th>")
    }
    out.push("</tr></thead><tbody>")
    for row in table.rows {
      out.push("<tr>")
      for cell in row {
        out.push(
          match cell {
            Text(s) => "<td>" + export_escape(s) + "</td>"
            Amount(v) => "<td class=\"amount\">" + money(v) + "</td>"
          },
        )
      }
      out.push("</tr>")
    }
    out.push("</tbody></table></div></section>")
  }
  out.push(
    "<footer>由当前账单重新结算生成。无需账号、网络或外部资源即可查看；姓名、付款人与分摊范围请共同核对。此文件是导出快照，后续修改不会自动同步。</footer></main></body></html>",
  )
  out.join("")
}
