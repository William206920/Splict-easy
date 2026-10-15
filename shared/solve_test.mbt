///|
test "report includes allocated payment details and source snapshots" {
  let people = ["A", "B"]
  let participants = ["B", "A"]
  let ledger = stage3_ledger(people, [equal_bill("A", 1L, participants)])
  let report = match @shared.build_report(ledger) {
    Ok(value) => value
    Err(message) => fail(message)
  }
  people.clear()
  participants.clear()
  ledger.payments.clear()
  assert_eq(report.total_cents, 1L)
  assert_eq(report.payments.length(), 1)
  check_shares(report.payments[0].shares, ["A", "B"], [0L, 1L])
  assert_eq(report.balances[0].person, "A")
  assert_eq(report.transfers[0].from, "B")
}

///|
test "solve text and ledger match for all formats" {
  let text = "人：A B\nA 1 茶"
  for format in [@shared.Markdown, @shared.Html, @shared.Json] {
    let from_text = match @shared.solve_text(text, format) {
      Ok(value) => value
      Err(message) => fail(message)
    }
    let from_ledger = match @shared.solve_ledger(must_parse(text), format) {
      Ok(value) => value
      Err(message) => fail(message)
    }
    assert_eq(from_text, from_ledger)
  }
}

///|
test "solve rejects invalid input before rendering every format" {
  for format in [@shared.Markdown, @shared.Html, @shared.Json] {
    match @shared.solve_text("人：A\nA 0 茶", format) {
      Err(message) =>
        assert_eq(message, "第 2 行：消费总金额必须大于零")
      Ok(_) => fail("invalid text rendered")
    }
    match
      @shared.solve_ledger(
        stage3_ledger(["A"], [equal_bill("A", 0L, ["A"])]),
        format,
      ) {
      Err(message) =>
        assert_eq(message, "第 1 笔消费：消费总金额必须大于零")
      Ok(_) => fail("invalid ledger rendered")
    }
  }
}

///|
test "report refuses ambiguity" {
  match
    @shared.build_report({
      ..stage3_ledger(["A"], []),
      ambiguous: ["不确定"],
    }) {
    Err(message) => assert_eq(message, "账单存在歧义：不确定")
    Ok(_) => fail("ambiguous report accepted")
  }
}

///|
test "HTML solve emits document and DOM helper emits fragment" {
  match @shared.solve_text("人：A B\nA 1 茶", @shared.Html) {
    Ok(value) => assert_true(value.has_prefix("<!doctype html>"))
    Err(message) => fail(message)
  }
  assert_true(@shared.render_text_html("人：A").has_prefix("<section"))
}
