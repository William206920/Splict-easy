///|
fn response(content : String) -> String {
  "{\"choices\":[{\"message\":{\"content\":" +
  @shared.quote_json(content) +
  "}}]}"
}

///|
test "AI consent boundaries and golden response" {
  let flow = Flow::new()
  let raw = response(@shared.encode_ledger(@shared.sample_mixed()))
  let blocked = try {
    ignore(flow.receive(raw))
    false
  } catch {
    _ => true
  }
  assert_true(blocked)
  assert_true(flow.send(true))
  let ledger = flow.receive(raw)
  assert_true(preview(ledger).contains("奶茶"))
  let report = flow.confirm(true)
  assert_eq(report.transfers[3].amount_cents, 2000L)
  let cancelled = Flow::new()
  assert_true(!cancelled.send(false))
  assert_eq(cancelled.stage, 4)
  let after = Flow::new()
  ignore(after.send(true))
  ignore(after.receive(raw))
  let no_report = try {
    ignore(after.confirm(false))
    false
  } catch {
    _ => true
  }
  assert_true(no_report && after.stage == 4)
}

///|
test "AI ambiguity malformed and amount failures block" {
  let ledger = @shared.sample_mixed()
  let ambiguous = @shared.encode_ledger({
    ..ledger,
    ambiguous: ["未说明谁付款"],
  })
  for
    raw in [
      "bad",
      "{}",
      response(ambiguous),
      response(@shared.encode_ledger(ledger).replace(old="7500", new="7400")),
    ] {
    let blocked = try {
      ignore(parse_response(raw))
      false
    } catch {
      _ => true
    }
    assert_true(blocked)
  }
  let config : Config = {
    base_url: "https://example.invalid/v1/",
    api_key: "key",
    model: "model",
  }
  assert_eq(endpoint(config), "https://example.invalid/v1/chat/completions")
  assert_true(request_body(config, "账单").contains("\"stream\":false"))
}
