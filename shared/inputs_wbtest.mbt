///|
test "UTF8 BOM ledger JSON preserves the canonical bill" {
  let original = sample_mixed()
  assert_true(decode_ledger("\u{FEFF}" + encode_ledger(original)) == original)
  let malformed = try {
    ignore(decode_ledger("\u{FEFF}{\"schema_version\":1.0}"))
    false
  } catch {
    _ => true
  }
  assert_true(malformed)
}

///|
test "text golden dinner and mixed" {
  assert_true(
    settle(
      parse_text(
        "人：小明 小红 小刚 小美\n小明 300 晚餐\n小红 120 加菜\n小刚 40 饮料 !小红",
      ),
    ) ==
    settle(dinner_fixture()),
  )
  assert_true(
    parse_text(
      "\u{FEFF}人：小明 小红 小刚 小美 小李\r\n\r\n小明 200 晚餐\r\n小红 75 奶茶 =小明:12 小红:15 小刚:18 小美:14 小李:16",
    ) ==
    sample_mixed(),
  )
}

///|
test "text errors preserve original line and markers" {
  try {
    ignore(parse_text("人：A B\n\n\nA 1 x @A !B"))
    fail("expected error")
  } catch {
    Invalid(text) => assert_true(text.has_prefix("第 4 行"))
    _ => fail("expected a line-numbered BillError")
  }
  for
    text in [
      "人：A B\nA 1 x !C", "人：A B\nA 1 x @A A", "人：A B\nA 1 x =A:0.50 B:0.40",
      "人：A B\nA 1 x !A B", "A 1 x",
    ] {
    assert_true(rejected(() => parse_text(text)))
  }
  let ledger = parse_text("人：A B C\nA 1 午餐 有 空格 @C B")
  assert_true(
    shares_for(ledger.people, ledger.payments[0]).map(s => s.person) ==
    ["B", "C"],
  )
}

///|
test "json roundtrip and large integer raw literal" {
  let ledger = sample_mixed()
  assert_true(decode_ledger(encode_ledger(ledger)) == ledger)
  let large : Ledger = {
    people: ["A", "B"],
    ambiguous: [],
    payments: [
      {
        payer: "A",
        amount_cents: 9223372036854775807L,
        split_mode: Equal,
        participants: ["B"],
        shares: [],
        description: "\"\\\n奶茶",
        date: "",
      },
    ],
  }
  assert_true(decode_ledger(encode_ledger(large)) == large)
  assert_eq(
    settle(decode_ledger(encode_ledger(large))).transfers[0].amount_cents,
    9223372036854775807L,
  )
  assert_true(rejected(() => decode_ledger("{\"schema_version\":2}")))
  assert_true(rejected(() => decode_ledger("bad")))
}

///|
test "json rejects duplicated keys fractions exponents and overflowing cents" {
  for
    bad in [
      "{\"schema_version\":1,\"schema_version\":1}", "{\"schema_version\":1.0}",
      "{\"schema_version\":1e0}", "{\"schema_version\":01}", "[] trailing",
    ] {
    assert_true(rejected(() => decode_ledger(bad)))
  }
  let json = encode_ledger(sample_mixed())
  assert_true(
    rejected(() => {
      decode_ledger(json.replace(old="20000", new="9223372036854775808"))
    }),
  )
}
