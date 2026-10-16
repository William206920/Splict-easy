///|
test "editable text and JSON examples describe the same mixed bill" {
  let text = import_ledger(import_text_example())
  let json = import_ledger(import_json_example())
  assert_true(text == json)
  let report = @shared.settle(json)
  assert_eq(report.total_cents, 14000L)
  assert_true(
    report.balances.map(b => b.balance_cents) == [4000L, -2000L, -2000L],
  )
}

///|
test "import accepts BOM and membership-only ledgers without inventing payments" {
  assert_true(
    import_ledger("\u{FEFF}" + import_json_example()) ==
    import_ledger(import_text_example()),
  )
  let ledger = import_ledger("人：小明 小红")
  assert_true(ledger.payments.is_empty())
  assert_true(ledger_preview(ledger).contains("尚无消费"))
  let empty = import_ledger(
    "{\"schema_version\":1,\"people\":[],\"payments\":[],\"ambiguous\":[]}",
  )
  assert_true(empty.people.is_empty())
  assert_true(ledger_preview(empty).contains("无"))
  let failed = try {
    ignore(import_ledger(" \r\n"))
    false
  } catch {
    _ => true
  }
  assert_true(failed)
}
