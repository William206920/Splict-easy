///|
fn expect_money(input : String, expected : Int64) -> Unit raise {
  match @shared.parse_money(input) {
    Ok(value) => assert_eq(value, expected)
    Err(message) => fail("unexpected error for \{input}: \{message}")
  }
}

///|
fn expect_money_error(input : String, expected : String) -> Unit raise {
  match @shared.parse_money(input) {
    Err(message) => assert_eq(message, expected)
    Ok(_) => fail("invalid money accepted: \{input}")
  }
}

///|
test "money whole yuan" {
  expect_money("300", 30000L)
  expect_money("0012", 1200L)
}

///|
test "money decimal precision" {
  expect_money("300.50", 30050L)
  expect_money("0.29", 29L)
  expect_money("0.01", 1L)
  expect_money("12.3", 1230L)
}

///|
test "money zero valid for shares" {
  expect_money("0", 0L)
  expect_money("0.0", 0L)
  expect_money("0.00", 0L)
}

///|
test "money beyond JS safe integer stays exact" {
  expect_money("90071992547409.93", 9007199254740993L)
}

///|
test "money Int64 cent maximum" {
  expect_money("92233720368547758.07", 9223372036854775807L)
  expect_money("92233720368547758", 9223372036854775800L)
  expect_money("9223372036854775.8", 922337203685477580L)
}

///|
test "money overflow at cent boundary" {
  expect_money_error(
    "92233720368547758.08", "金额超出 Int64 整数分范围",
  )
  expect_money_error("92233720368547759", "金额超出 Int64 整数分范围")
  expect_money_error(
    "9223372036854775808", "金额超出 Int64 整数分范围",
  )
  expect_money_error(
    "999999999999999999999999999.00", "金额超出 Int64 整数分范围",
  )
}

///|
test "money overflow when scaling a single fractional digit" {
  expect_money_error(
    "92233720368547758.1", "金额超出 Int64 整数分范围",
  )
}

///|
test "money rejects signs and whitespace" {
  for input in ["-1", "+1", " 1", "1 ", "\t1", "1\n", "-0.00"] {
    expect_money_error(
      input, "金额格式错误：仅支持非负数字和小数点",
    )
  }
}

///|
test "money rejects unsupported numeric formats" {
  for
    input in [
      "1e2", "1,000", "NaN", "Infinity", "￥12", "１２.３４", "1/2",
    ] {
    expect_money_error(
      input, "金额格式错误：仅支持非负数字和小数点",
    )
  }
}

///|
test "money rejects malformed decimal" {
  for input in [".5", ".", "1..2", "1.2.3"] {
    expect_money_error(
      input, "金额格式错误：请输入整数或最多两位小数",
    )
  }
  expect_money_error("1.", "小数点后必须有一到两位数字")
  expect_money_error("1.001", "金额最多支持两位小数")
  expect_money_error("", "金额不能为空")
}

///|
test "checked addition accepts maximum and zero" {
  match @shared.checked_add_cents(9223372036854775806L, 1L) {
    Ok(value) => assert_eq(value, 9223372036854775807L)
    Err(message) => fail(message)
  }
  match @shared.checked_add_cents(9223372036854775807L, 0L) {
    Ok(value) => assert_eq(value, 9223372036854775807L)
    Err(message) => fail(message)
  }
}

///|
test "checked addition rejects overflow and negatives" {
  for (a, b) in [(9223372036854775807L, 1L), (1L, 9223372036854775807L)] {
    match @shared.checked_add_cents(a, b) {
      Err(message) =>
        assert_eq(message, "金额合计超出 Int64 整数分范围")
      Ok(_) => fail("overflow accepted")
    }
  }
  for (a, b) in [(-1L, 0L), (0L, -1L), (-9223372036854775808L, 1L)] {
    match @shared.checked_add_cents(a, b) {
      Err(message) => assert_eq(message, "金额相加时不能包含负数")
      Ok(_) => fail("negative accepted")
    }
  }
}
