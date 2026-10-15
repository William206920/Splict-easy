///|
fn[T] rejected(f : () -> T raise BillError) -> Bool {
  try {
    ignore(f())
    false
  } catch {
    _ => true
  }
}

///|
test "money precision and max" {
  assert_eq(parse_money("0.29"), 29L)
  assert_eq(parse_money("12.3"), 1230L)
  assert_eq(parse_money("0"), 0L)
  assert_eq(parse_money("92233720368547758.07"), 9223372036854775807L)
  assert_eq(money(9223372036854775807L), "92233720368547758.07")
  assert_eq(money(-29L), "-0.29")
}

///|
test "reject malformed amounts and overflow" {
  for
    bad in [
      "", "-1", "+1", "1e2", "1,000", ".2", "2.", "1.001", " 2", "2 ", "92233720368547758.08",
    ] {
    assert_true(rejected(() => parse_money(bad)))
  }
  assert_true(rejected(() => add_money(9223372036854775807L, 1L)))
}

///|
test "names and calendar" {
  for bad in ["", " ", "　", "小 明", "A:B", "A@"] {
    assert_true(!valid_name(bad))
  }
  assert_true(rejected(() => validate_people(["A", "A"])))
  validate_date("2024-02-29")
  for
    bad in ["2023-02-29", "1900-02-29", "2026-04-31", "0000-01-01", "2026-1-01"] {
    assert_true(rejected(() => validate_date(bad)))
  }
}

///|
test "mode sum zero excluded payer and total overflow" {
  let p : Payment = {
    payer: "A",
    amount_cents: 29L,
    split_mode: Exact,
    participants: [],
    shares: [
      { person: "A", amount_cents: 0L, },
      { person: "B", amount_cents: 29L, },
    ],
    description: "奶茶",
    date: "",
  }
  validate({ people: ["A", "B"], payments: [p], ambiguous: [], })
  assert_true(
    rejected(() => validate_payment(["A", "B"], { ..p, amount_cents: 30L, })),
  )
  assert_true(
    rejected(() => validate_payment(["A", "B"], { ..p, participants: ["A"], })),
  )
  assert_true(rejected(() => validate_payment(["B"], p)))
  assert_true(
    rejected(() => {
      validate({ people: ["A", "B"], payments: [p], ambiguous: ["谁付款"], })
    }),
  )
  let large : Payment = {
    ..p,
    amount_cents: 9223372036854775807L,
    shares: [{ person: "B", amount_cents: 9223372036854775807L, }],
  }
  assert_true(
    rejected(() => {
      validate({ people: ["A", "B"], payments: [large, p], ambiguous: [], })
    }),
  )
}
