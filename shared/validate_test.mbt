///|
fn equal_payment() -> @shared.Payment {
  {
    payer: "小明",
    amount_cents: 20000L,
    split_mode: Equal,
    participants: ["小明", "小红"],
    shares: [],
    description: "晚餐",
    date: "",
  }
}

///|
fn exact_payment() -> @shared.Payment {
  {
    payer: "小红",
    amount_cents: 7500L,
    split_mode: Exact,
    participants: [],
    shares: [
      { person: "小明", amount_cents: 1200L, },
      { person: "小红", amount_cents: 1500L, },
      { person: "小刚", amount_cents: 1800L, },
      { person: "小美", amount_cents: 1400L, },
      { person: "小李", amount_cents: 1600L, },
    ],
    description: "奶茶",
    date: "2026-10-15",
  }
}

///|
fn ledger_with(payments : Array[@shared.Payment]) -> @shared.Ledger {
  {
    people: ["小明", "小红", "小刚", "小美", "小李"],
    payments,
    ambiguous: [],
  }
}

///|
fn expect_valid(ledger : @shared.Ledger) -> Unit raise {
  match @shared.validate_ledger(ledger) {
    Ok(_) => ()
    Err(message) => fail(message)
  }
}

///|
fn expect_invalid(ledger : @shared.Ledger, expected : String) -> Unit raise {
  match @shared.validate_ledger(ledger) {
    Err(message) => assert_eq(message, expected)
    Ok(_) => fail("invalid ledger accepted")
  }
}

///|
test "validate draft with no payments" {
  expect_valid(ledger_with([]))
}

///|
test "validate empty people and blank names" {
  expect_invalid(
    { people: [], payments: [], ambiguous: [], },
    "参与人员不能为空",
  )
  for name in ["", " ", "\t\n\r"] {
    expect_invalid(
      { people: [name], payments: [], ambiguous: [], },
      "第 1 位人员的姓名不能为空",
    )
  }
}

///|
test "validate duplicate and boundary spaces" {
  expect_invalid(
    { people: ["小明", "小明"], payments: [], ambiguous: [], },
    "人员姓名重复：小明",
  )
  expect_invalid(
    { people: ["小明", " 小红"], payments: [], ambiguous: [], },
    "第 2 位人员的姓名首尾不能有空白",
  )
}

///|
test "validate ambiguous ledger blocks processing" {
  expect_invalid(
    { ..ledger_with([]), ambiguous: ["奶茶由谁付款？", "还有歧义"], },
    "账单存在歧义：奶茶由谁付款？",
  )
}

///|
test "validate unknown payer" {
  expect_invalid(
    ledger_with([{ ..equal_payment(), payer: "陌生人", }]),
    "第 1 笔消费：未知付款人：陌生人",
  )
}

///|
test "validate positive payment amount" {
  for amount in [0L, -1L, -9223372036854775808L] {
    expect_invalid(
      ledger_with([{ ..equal_payment(), amount_cents: amount, }]),
      "第 1 笔消费：消费总金额必须大于零",
    )
  }
}

///|
test "validate equal payment" {
  expect_valid(ledger_with([equal_payment()]))
}

///|
test "validate equal needs participants" {
  expect_invalid(
    ledger_with([{ ..equal_payment(), participants: [], }]),
    "第 1 笔消费：平均分摊至少需要一位参与者",
  )
}

///|
test "validate equal rejects conflicting shares" {
  expect_invalid(
    ledger_with([
      { ..equal_payment(), shares: [{ person: "小明", amount_cents: 0L, }], },
    ]),
    "第 1 笔消费：平均分摊不能同时填写实际金额份额",
  )
}

///|
test "validate equal rejects unknown or duplicate participants" {
  expect_invalid(
    ledger_with([{ ..equal_payment(), participants: ["未知"], }]),
    "第 1 笔消费：未知参与者：未知",
  )
  expect_invalid(
    ledger_with([{ ..equal_payment(), participants: ["小明", "小明"], }]),
    "第 1 笔消费：参与者重复：小明",
  )
}

///|
test "validate payer need not participate" {
  expect_valid(ledger_with([{ ..equal_payment(), participants: ["小红"], }]))
  expect_valid(
    ledger_with([
      {
        ..exact_payment(),
        payer: "小红",
        shares: [{ person: "小明", amount_cents: 7500L, }],
      },
    ]),
  )
}

///|
test "validate exact five person milk tea" {
  expect_valid(ledger_with([exact_payment()]))
}

///|
test "validate exact rejects conflicting participants" {
  expect_invalid(
    ledger_with([{ ..exact_payment(), participants: ["小明"], }]),
    "第 1 笔消费：按实际金额分摊不能同时填写平均参与者",
  )
}

///|
test "validate exact needs shares" {
  expect_invalid(
    ledger_with([{ ..exact_payment(), shares: [], }]),
    "第 1 笔消费：按实际金额分摊至少需要一条份额",
  )
}

///|
test "validate exact rejects unknown or duplicate person" {
  expect_invalid(
    ledger_with([
      {
        ..exact_payment(),
        shares: [{ person: "未知", amount_cents: 7500L, }],
      },
    ]),
    "第 1 笔消费：未知份额人员：未知",
  )
  expect_invalid(
    ledger_with([
      {
        ..exact_payment(),
        shares: [
          { person: "小明", amount_cents: 7500L, },
          { person: "小明", amount_cents: 0L, },
        ],
      },
    ]),
    "第 1 笔消费：份额人员重复：小明",
  )
}

///|
test "validate exact negative share" {
  expect_invalid(
    ledger_with([
      { ..exact_payment(), shares: [{ person: "小明", amount_cents: -1L, }], },
    ]),
    "第 1 笔消费：个人分摊金额不能为负数：小明",
  )
}

///|
test "validate exact zero share and omitted people" {
  expect_valid(
    ledger_with([
      {
        ..exact_payment(),
        shares: [
          { person: "小明", amount_cents: 7500L, },
          { person: "小红", amount_cents: 0L, },
        ],
      },
    ]),
  )
}

///|
test "validate exact sum mismatch in both directions" {
  for amount in [7499L, 7501L] {
    expect_invalid(
      ledger_with([
        {
          ..exact_payment(),
          shares: [{ person: "小明", amount_cents: amount, }],
        },
      ]),
      "第 1 笔消费：个人分摊金额合计必须等于消费总金额",
    )
  }
}

///|
test "validate exact sum overflow before comparison" {
  expect_invalid(
    ledger_with([
      {
        ..exact_payment(),
        amount_cents: 9223372036854775807L,
        shares: [
          { person: "小明", amount_cents: 9223372036854775807L, },
          { person: "小红", amount_cents: 1L, },
        ],
      },
    ]),
    "第 1 笔消费：金额合计超出 Int64 整数分范围",
  )
}

///|
test "validate ledger total overflow" {
  expect_invalid(
    ledger_with([
      { ..equal_payment(), amount_cents: 9223372036854775807L, },
      { ..equal_payment(), amount_cents: 1L, },
    ]),
    "第 2 笔消费：金额合计超出 Int64 整数分范围",
  )
}

///|
test "validate total at maximum" {
  expect_valid(
    ledger_with([
      { ..equal_payment(), amount_cents: 9223372036854775806L, },
      { ..equal_payment(), amount_cents: 1L, },
    ]),
  )
}

///|
test "validate mixed modes and repeat payer" {
  expect_valid(
    ledger_with([equal_payment(), { ..exact_payment(), payer: "小明", }]),
  )
}

///|
test "validate reports payment index deterministically without mutation" {
  let payment = { ..equal_payment(), payer: "未知", }
  let ledger = ledger_with([equal_payment(), payment])
  expect_invalid(ledger, "第 2 笔消费：未知付款人：未知")
  expect_invalid(ledger, "第 2 笔消费：未知付款人：未知")
  assert_eq(ledger.payments.length(), 2)
  assert_eq(ledger.payments[1].payer, "未知")
  assert_eq(ledger.people[0], "小明")
}

///|
test "validate Unicode blank names and boundary whitespace" {
  for name in ["\u{3000}", "\u{00A0}", "\u{2003}\u{2028}"] {
    expect_invalid(
      { people: [name], payments: [], ambiguous: [], },
      "第 1 位人员的姓名不能为空",
    )
  }
  for name in ["小明\u{3000}", "\u{00A0}小明"] {
    expect_invalid(
      { people: [name], payments: [], ambiguous: [], },
      "第 1 位人员的姓名首尾不能有空白",
    )
  }
}

///|
test "validate exact maximum and JS unsafe integer boundary" {
  for amount in [9007199254740993L, 9223372036854775807L] {
    expect_valid(
      ledger_with([
        {
          ..exact_payment(),
          amount_cents: amount,
          shares: [{ person: "小明", amount_cents: amount, }],
        },
      ]),
    )
  }
}

///|
test "validate single cent with multiple equal participants" {
  expect_valid(ledger_with([{ ..equal_payment(), amount_cents: 1L, }]))
}
