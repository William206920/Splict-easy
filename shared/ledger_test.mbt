///|
test "public models preserve all fields" {
  let share : @shared.Share = { person: "小明", amount_cents: 29L, }
  let payment : @shared.Payment = {
    payer: "小红",
    amount_cents: 29L,
    split_mode: Exact,
    participants: [],
    shares: [share],
    description: "奶茶",
    date: "2026-10-15",
  }
  let ledger : @shared.Ledger = {
    people: ["小明", "小红"],
    payments: [payment],
    ambiguous: [],
  }
  assert_eq(ledger.payments[0].shares[0].amount_cents, 29L)
  assert_eq(ledger.payments[0].shares[0].person, "小明")
  assert_eq(payment.amount_cents, 29L)
  assert_eq(payment.payer, "小红")
  assert_true(payment.split_mode == @shared.Exact)
  assert_true(payment.participants.is_empty())
  assert_eq(payment.description, "奶茶")
  assert_eq(payment.date, "2026-10-15")
  assert_eq(ledger.people[0], "小明")
  assert_true(ledger.ambiguous.is_empty())
}

///|
test "transfer model is integer cents" {
  let transfer : @shared.Transfer = {
    from: "小明",
    to: "小红",
    amount_cents: 9007199254740993L,
  }
  assert_eq(transfer.from, "小明")
  assert_eq(transfer.to, "小红")
  assert_eq(transfer.amount_cents, 9007199254740993L)
}
