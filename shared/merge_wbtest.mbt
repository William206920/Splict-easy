///|
test "merge retains old order and payments and appends new members once" {
  let original = parse_text("人：甲 乙\n甲 0.29 晚餐")
  let incoming = parse_text("人：乙 丙 甲\n乙 3.00 车费 @丙 乙")
  let before = encode_ledger(original)
  let added_before = encode_ledger(incoming)
  let result = merge_ledgers(original, incoming)
  assert_eq(result.people, ["甲", "乙", "丙"])
  assert_eq(result.payments.length(), 2)
  assert_eq(result.payments[0], original.payments[0])
  assert_eq(result.payments[1], incoming.payments[0])
  assert_eq(
    shares_for(result.people, result.payments[0]),
    shares_for(original.people, original.payments[0]),
  )
  assert_eq(encode_ledger(original), before)
  assert_eq(encode_ledger(incoming), added_before)
  assert_eq(settle(result).total_cents, 329L)
}

///|
test "new members do not join old equal or exact payments" {
  let original = parse_text(
    "人：甲 乙\n甲 1.01 茶\n乙 2 餐 =甲:0.75 乙:1.25",
  )
  let result = merge_ledgers(original, parse_text("人：丙\n丙 3 车费"))
  assert_eq(result.payments[0].participants, ["甲", "乙"])
  assert_eq(result.payments[1].shares, original.payments[1].shares)
  assert_eq(shares_for(result.people, result.payments[0]), [
    { person: "甲", amount_cents: 50L, },
    { person: "乙", amount_cents: 51L, },
  ])
  assert_eq(settle(result).total_cents, 601L)
}

///|
test "incoming equal tail cents use final member order shown in merge preview" {
  let result = merge_ledgers(
    parse_text("人：甲 乙"),
    parse_text("人：乙 甲\n甲 0.29 茶"),
  )
  assert_eq(result.people, ["甲", "乙"])
  assert_eq(shares_for(result.people, result.payments[0]), [
    { person: "甲", amount_cents: 14L, },
    { person: "乙", amount_cents: 15L, },
  ])
}

///|
test "merge handles empty ledgers and preserves cents beyond JS exact integers" {
  let empty : Ledger = { people: [], payments: [], ambiguous: [], }
  let large = parse_text("人：甲\n甲 90071992547409.93 大额")
  assert_eq(merge_ledgers(empty, large), large)
  assert_eq(merge_ledgers(large, empty), large)
  assert_eq(merge_ledgers(empty, empty), empty)
  assert_eq(
    settle(merge_ledgers(large, parse_text("人：甲\n甲 0.01 茶"))).total_cents,
    9007199254740994L,
  )
}

///|
test "merge rejects ambiguity overflow and combined limits without changing inputs" {
  let original = parse_text("人：甲\n甲 92233720368547758.07 大额")
  let before = encode_ledger(original)
  assert_true(
    rejected(() => {
      merge_ledgers(original, parse_text("人：甲\n甲 0.01 茶"))
    }),
  )
  let ambiguous : Ledger = {
    people: ["甲"],
    payments: [],
    ambiguous: ["付款人不明"],
  }
  assert_true(rejected(() => merge_ledgers(original, ambiguous)))
  let small = parse_text("人：甲\n甲 0.01 茶")
  let full : Ledger = {
    ..small,
    payments: Array::make(5000, small.payments[0]),
  }
  assert_true(rejected(() => merge_ledgers(full, small)))
  let people = Array::makei(200, i => "成员" + i.to_string())
  assert_true(
    rejected(() => {
      merge_ledgers(
        { people, payments: [], ambiguous: [], },
        parse_text("人：新成员"),
      )
    }),
  )
  assert_eq(encode_ledger(original), before)
}

///|
test "duplicate warnings preserve intentional repeated payments and detect within batch" {
  let one = parse_text("人：甲 乙\n甲 20 奶茶")
  let twice = merge_ledgers(one, one)
  assert_eq(duplicate_payments(one, one), 1)
  assert_eq(twice.payments.length(), 2)
  assert_eq(settle(twice).total_cents, 4000L)
  assert_eq(
    duplicate_payments({ people: [], payments: [], ambiguous: [], }, twice),
    1,
  )
  assert_eq(
    duplicate_payments(one, parse_text("人：甲 乙\n甲 21 奶茶")),
    0,
  )
}
