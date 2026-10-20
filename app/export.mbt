///|
fn Desktop::export_report(
  self : Desktop,
  path : String,
) -> Unit raise @shared.BillError {
  let lower = path
    .iter()
    .map(c => c.to_ascii_lowercase().to_string())
    .to_array()
    .join("")
  if lower.has_suffix(".xlsx") {
    @sys.write_bytes(path, @shared.export_xlsx(self.session.ledger))
  } else {
    let text = if lower.has_suffix(".html") || lower.has_suffix(".htm") {
      @shared.export_html(self.session.ledger)
    } else if lower.has_suffix(".csv") {
      @shared.export_csv(self.session.ledger)
    } else {
      let report = @shared.settle(self.session.ledger)
      if lower.has_suffix(".json") {
        @shared.render_report_json(report)
      } else if lower.has_suffix(".md") {
        @shared.render_markdown(report)
      } else if lower.has_suffix(".txt") {
        @shared.render_text(report)
      } else {
        @shared.invalid(
          "请选择 HTML、Excel (.xlsx)、CSV、Markdown、JSON 或 TXT 扩展名",
        )
        ""
      }
    }
    @sys.write_file(path, text)
  }
  self.status = "结算快照已导出：" + path
}
