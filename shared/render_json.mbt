///|
/// JSON string escaping; numeric serialization below never converts through Double.
pub fn quote_json(text : String) -> String {
  let out = StringBuilder()
  out.write_char('"')
  let hex = "0123456789abcdef"
  for ch in text.iter() {
    match ch {
      '"' => out.write_string("\\\"")
      '\\' => out.write_string("\\\\")
      '\n' => out.write_string("\\n")
      '\r' => out.write_string("\\r")
      '\t' => out.write_string("\\t")
      '\u{0008}' => out.write_string("\\b")
      '\u{000C}' => out.write_string("\\f")
      '<' => out.write_string("\\u003c")
      '>' => out.write_string("\\u003e")
      '&' => out.write_string("\\u0026")
      '\u{2028}' => out.write_string("\\u2028")
      '\u{2029}' => out.write_string("\\u2029")
      _ => {
        let code = ch.to_int()
        if code < 32 {
          out.write_string("\\u00")
          out.write_char(hex[code / 16].to_char().unwrap())
          out.write_char(hex[code % 16].to_char().unwrap())
        } else {
          out.write_char(ch)
        }
      }
    }
  }
  out.write_char('"')
  out.to_string()
}

///|
/// Stable schema/field order and integer tokens, including the full Int64 range.
/// Consumers must parse 64-bit integer tokens losslessly, not through JS Number.
pub fn render_json(report : SettlementReport) -> String {
  let out = StringBuilder()
  out.write_string(
    "{\"schema_version\":1,\"total_cents\":\{report.total_cents},\"balances\":[",
  )
  for i, balance in report.balances {
    if i > 0 {
      out.write_char(',')
    }
    out.write_string(
      "{\"person\":" +
      quote_json(balance.person) +
      ",\"paid_cents\":\{balance.paid_cents},\"owed_cents\":\{balance.owed_cents},\"balance_cents\":\{balance.balance_cents}}",
    )
  }
  out.write_string("],\"transfers\":[")
  for i, transfer in report.transfers {
    if i > 0 {
      out.write_char(',')
    }
    out.write_string(
      "{\"from\":" +
      quote_json(transfer.from) +
      ",\"to\":" +
      quote_json(transfer.to) +
      ",\"amount_cents\":\{transfer.amount_cents}}",
    )
  }
  out.write_string("],\"payments\":[")
  for i, payment in report.payments {
    if i > 0 {
      out.write_char(',')
    }
    let mode = match payment.split_mode {
      Equal => "equal"
      Exact => "exact"
    }
    out.write_string(
      "{\"payer\":" +
      quote_json(payment.payer) +
      ",\"amount_cents\":\{payment.amount_cents},\"split_mode\":" +
      quote_json(mode) +
      ",\"description\":" +
      quote_json(payment.description) +
      ",\"date\":" +
      quote_json(payment.date) +
      ",\"shares\":[",
    )
    for j, share in payment.shares {
      if j > 0 {
        out.write_char(',')
      }
      out.write_string(
        "{\"person\":" +
        quote_json(share.person) +
        ",\"amount_cents\":\{share.amount_cents}}",
      )
    }
    out.write_string("]}")
  }
  out.write_string("]}\n")
  out.to_string()
}
