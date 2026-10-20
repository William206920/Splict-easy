///|
pub fn export_document(source : String, format : String) -> String {
  try {
    let ledger = @shared.decode_ledger(source)
    let data = if format == "xlsx" {
      @base64.encode(@shared.export_xlsx(ledger))
    } else if format == "html" {
      @shared.export_html(ledger)
    } else if format == "csv" {
      @shared.export_csv(ledger)
    } else {
      @shared.invalid("不支持的导出格式")
      ""
    }
    "{\"ok\":true,\"encoding\":" +
    @shared.quote_json(if format == "xlsx" { "base64" } else { "utf8" }) +
    ",\"data\":" +
    @shared.quote_json(data) +
    "}"
  } catch {
    error => error_result(error)
  }
}
