///|
/// Build a fresh report after the core validates and settles the ledger.
pub fn build_report(ledger : Ledger) -> Result[SettlementReport, String] {
  let settlement = match settle_ledger(ledger) {
    Ok(value) => value
    Err(message) => return Err(message)
  }
  let payments : Array[PaymentReport] = []
  for payment in ledger.payments {
    payments.push({
      payer: payment.payer,
      amount_cents: payment.amount_cents,
      split_mode: payment.split_mode,
      shares: allocate_validated(ledger.people, payment),
      description: payment.description,
      date: payment.date,
    })
  }
  Ok({
    total_cents: settlement.total_cents,
    payments,
    balances: settlement.balances,
    transfers: settlement.transfers,
  })
}

///|
pub fn report_from_text(text : String) -> Result[SettlementReport, String] {
  match parse_text(text) {
    Ok(ledger) => build_report(ledger)
    Err(message) => Err(message)
  }
}

///|
pub fn render_report(
  report : SettlementReport,
  format : ReportFormat,
) -> String {
  match format {
    Markdown => render_markdown(report)
    Html => render_html_document(report)
    Json => render_json(report)
  }
}

///|
pub fn solve_ledger(
  ledger : Ledger,
  format : ReportFormat,
) -> Result[String, String] {
  match build_report(ledger) {
    Ok(report) => Ok(render_report(report, format))
    Err(message) => Err(message)
  }
}

///|
pub fn solve_text(
  text : String,
  format : ReportFormat,
) -> Result[String, String] {
  match report_from_text(text) {
    Ok(report) => Ok(render_report(report, format))
    Err(message) => Err(message)
  }
}

///|
/// A safe fragment for a future DOM adapter, including line-numbered errors.
pub fn render_text_html(text : String) -> String {
  match report_from_text(text) {
    Ok(report) => render_html(report)
    Err(message) => render_error_html(message)
  }
}

///|
fn mode_label(mode : SplitMode) -> String {
  match mode {
    Equal => "平均分摊"
    Exact => "按实际金额分摊"
  }
}
