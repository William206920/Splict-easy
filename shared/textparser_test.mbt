///|
fn must_parse(text : String) -> @shared.Ledger raise {
  match @shared.parse_text(text) {
    Ok(ledger) => ledger
    Err(message) => fail(message)
  }
}

///|
fn text_error(text : String, expected : String) -> Unit raise {
  match @shared.parse_text(text) {
    Err(message) => assert_eq(message, expected)
    Ok(_) => fail("invalid text accepted")
  }
}

///|
test "text default equal and multiword description" {
  let ledger = must_parse("人：小明 小红\n小明 12.30 晚餐 加菜")
  assert_eq(ledger.people.length(), 2)
  assert_eq(ledger.payments.length(), 1)
  let payment = ledger.payments[0]
  assert_eq(payment.payer, "小明")
  assert_eq(payment.amount_cents, 1230L)
  assert_true(payment.split_mode == @shared.Equal)
  assert_eq(payment.participants[0], "小明")
  assert_eq(payment.participants[1], "小红")
  assert_true(payment.shares.is_empty())
  assert_eq(payment.description, "晚餐 加菜")
  assert_eq(payment.date, "")
  assert_true(ledger.ambiguous.is_empty())
}

///|
test "text whitespace tabs Chinese spaces and attached markers" {
  let ledger = must_parse(
    "\u{3000}人：\tA\u{3000}B C\n\tA\t1.00\u{3000}午餐\t加菜@C A\u{3000}",
  )
  assert_eq(ledger.payments[0].description, "午餐 加菜")
  assert_eq(ledger.payments[0].participants[0], "C")
  check_shares(must_allocate(ledger.people, ledger.payments[0]), ["A", "C"], [
    50L, 50L,
  ])
}

///|
test "text ascii header and zero payment draft" {
  let ledger = must_parse("人: A B\n\n")
  assert_eq(ledger.people.length(), 2)
  assert_true(ledger.payments.is_empty())
}

///|
test "text BOM and CRLF preserve names" {
  let ledger = must_parse("\u{FEFF}人：A B\r\nA 0.29 茶\r\n")
  assert_eq(ledger.people[0], "A")
  assert_eq(ledger.payments[0].amount_cents, 29L)
}

///|
test "text CR line endings accepted" {
  let ledger = must_parse("人：A B\rA 1 茶\rB 2 饭")
  assert_eq(ledger.payments.length(), 2)
}

///|
test "text at selects without changing canonical remainder" {
  let ledger = must_parse("人：A B C D\nA 0.05 茶 @D B C")
  check_shares(
    must_allocate(ledger.people, ledger.payments[0]),
    ["B", "C", "D"],
    [1L, 2L, 2L],
  )
}

///|
test "text bang excludes one or multiple people" {
  let ledger = must_parse("人：A B C D\nA 1 茶 !B D")
  assert_eq(ledger.payments[0].participants.length(), 2)
  assert_eq(ledger.payments[0].participants[0], "A")
  assert_eq(ledger.payments[0].participants[1], "C")
}

///|
test "text exact amounts mode and zero share" {
  let ledger = must_parse("人：A B C\nA 0.29 奶茶 =B:0.29 A:0")
  let bill = ledger.payments[0]
  assert_true(bill.split_mode == @shared.Exact)
  assert_true(bill.participants.is_empty())
  assert_eq(bill.shares.length(), 2)
  assert_eq(bill.shares[0].person, "B")
  assert_eq(bill.shares[0].amount_cents, 29L)
  assert_eq(bill.shares[1].amount_cents, 0L)
  check_transfers(must_settle(ledger).transfers, [("B", "A", 29L)])
}

///|
test "text payer may not participate" {
  for
    text in [
      "人：A B\nA 1 茶 @B", "人：A B\nA 1 茶 !A", "人：A B\nA 1 茶 =B:1",
    ] {
    check_transfers(must_settle(must_parse(text)).transfers, [("B", "A", 100L)])
  }
}

///|
test "text all three marked modes across different payments" {
  let ledger = must_parse(
    "人：A B C\nA 1 饭\nB 0.03 茶 @C A\nC 2 车费 !B\nA 3 早餐 =B:1 C:2",
  )
  assert_eq(ledger.payments.length(), 4)
  check_settlement_invariants(must_settle(ledger))
}

///|
test "text empty document and blank document rejected" {
  for text in ["", "\n\t\u{3000}\n", "\u{FEFF}"] {
    text_error(text, "第 1 行：缺少人员名单")
  }
}

///|
test "text header required before payments" {
  text_error(
    "\nA 1 茶\n人：A B", "第 2 行：首个非空行必须声明人员，例如：人：小明 小红",
  )
}

///|
test "text empty or duplicate header people" {
  text_error("人：\n", "第 1 行：参与人员不能为空")
  text_error("人：A A", "第 1 行：人员姓名重复：A")
}

///|
test "text header cannot be repeated" {
  text_error(
    "人：A B\n\n人：A C", "第 3 行：人员名单只能声明一次，且必须位于消费之前",
  )
  text_error(
    "人：A B\nA 1 茶\n人: A B", "第 3 行：人员名单只能声明一次，且必须位于消费之前",
  )
}

///|
test "text reserved symbols rejected in names" {
  for name in ["A@B", "A!B", "A=B", "A:B", "A：B"] {
    text_error(
      "人：" + name,
      "第 1 行：文本模式姓名不能包含 @、!、= 或冒号",
    )
  }
}

///|
test "text payment requires payer amount and description" {
  for line in ["A", "A 1", "A 1 @B", "@A 1 茶"] {
    text_error(
      "人：A B\n" + line,
      "第 2 行：消费格式应为：付款人 金额 消费说明 [分摊标记]",
    )
  }
}

///|
test "text rejects zero and negative payment" {
  text_error("人：A\nA 0 茶", "第 2 行：消费总金额必须大于零")
  text_error(
    "人：A\nA -1 茶", "第 2 行：消费金额：金额格式错误：仅支持非负数字和小数点",
  )
}

///|
test "text rejects invalid precision and amount overflow" {
  text_error(
    "人：A\nA 0.001 茶", "第 2 行：消费金额：金额最多支持两位小数",
  )
  text_error(
    "人：A\nA 92233720368547758.08 茶", "第 2 行：消费金额：金额超出 Int64 整数分范围",
  )
}

///|
test "text unknown payer reports original line" {
  text_error("\n人：A B\n\nC 1 茶\n", "第 4 行：未知付款人：C")
}

///|
test "text unknown duplicate selected people" {
  text_error("人：A B\nA 1 茶 @C", "第 2 行：未知参与者：C")
  text_error("人：A B\nA 1 茶 @A A", "第 2 行：参与者重复：A")
}

///|
test "text unknown duplicate or all excluded people" {
  text_error("人：A B\nA 1 茶 !C", "第 2 行：未知排除人员：C")
  text_error("人：A B\nA 1 茶 !B B", "第 2 行：排除人员重复：B")
  text_error(
    "人：A B\nA 1 茶 !A B", "第 2 行：平均分摊至少需要一位参与者",
  )
}

///|
test "text each marker requires a payload" {
  for marker in ["@", "!", "="] {
    text_error(
      "人：A B\nA 1 茶 " + marker,
      "第 2 行：分摊标记后不能为空",
    )
  }
}

///|
test "text mixed or repeated markers rejected" {
  for
    suffix in [
      "@A !B", "!B =A:1", "=A:1 @A", "@A @B", "!A !B", "=A:1 =B:0", "@!", "==A:1",
    ] {
    text_error(
      "人：A B\nA 1 茶 " + suffix,
      "第 2 行：每笔消费只能使用一次 @、! 或 = 标记，不得混用",
    )
  }
}

///|
test "text exact requires ASCII colon and a name" {
  text_error(
    "人：A\nA 1 茶 =A", "第 2 行：实际金额格式应为 姓名:金额，使用英文冒号",
  )
  text_error(
    "人：A\nA 1 茶 =A：1", "第 2 行：实际金额格式应为 姓名:金额，使用英文冒号",
  )
  text_error(
    "人：A\nA 1 茶 =:1", "第 2 行：实际金额份额的姓名不能为空",
  )
}

///|
test "text exact amount errors include person and line" {
  text_error(
    "人：A\nA 1 茶 =A:", "第 2 行：人员“A”的分摊金额：金额不能为空",
  )
  text_error(
    "人：A\nA 1 茶 =A:-1", "第 2 行：人员“A”的分摊金额：金额格式错误：仅支持非负数字和小数点",
  )
  text_error(
    "人：A\nA 1 茶 =A:1.001", "第 2 行：人员“A”的分摊金额：金额最多支持两位小数",
  )
  text_error(
    "人：A\nA 1 茶 =A:1:0", "第 2 行：人员“A”的分摊金额：金额格式错误：仅支持非负数字和小数点",
  )
}

///|
test "text exact unknown or duplicate names" {
  text_error("人：A B\nA 1 茶 =C:1", "第 2 行：未知份额人员：C")
  text_error(
    "人：A B\nA 1 茶 =A:1 A:0", "第 2 行：份额人员重复：A",
  )
}

///|
test "text exact mismatch and share sum overflow" {
  text_error(
    "人：A B\nA 1 茶 =A:0.99", "第 2 行：个人分摊金额合计必须等于消费总金额",
  )
  text_error(
    "人：A B\nA 92233720368547758.07 茶 =A:92233720368547758.07 B:0.01", "第 2 行：金额合计超出 Int64 整数分范围",
  )
}

///|
test "text total overflow uses second payment physical line" {
  text_error(
    "人：A B\nA 92233720368547758.07 茶\n\nB 0.01 饭\n", "第 4 行：金额合计超出 Int64 整数分范围",
  )
}

///|
test "text CRLF error line counts blank lines" {
  text_error(
    "\u{FEFF}\r\n人：A B\r\n\r\nA 1 茶\r\nB 1 饭 @C\r\n", "第 5 行：未知参与者：C",
  )
}

///|
test "text stops at first bad line without guessing" {
  text_error(
    "人：A B\nC 1 茶\nA 2 饭 @D", "第 2 行：未知付款人：C",
  )
}

///|
test "text no quotes or comments supported" {
  text_error(
    "# 人：A B\nA 1 茶", "第 1 行：首个非空行必须声明人员，例如：人：小明 小红",
  )
}

///|
test "text repeated parse has independent arrays" {
  let text = "人：A B\nA 1 茶 @B"
  let first = must_parse(text)
  first.people.clear()
  first.payments.clear()
  let next = must_parse(text)
  assert_eq(next.people.length(), 2)
  assert_eq(next.payments.length(), 1)
  check_settlement_invariants(must_settle(next))
}

///|
test "text maximum and JS unsafe integers settle exactly" {
  for
    (amount, expected) in [
      ("90071992547409.93", 9007199254740993L),
      ("92233720368547758.07", 9223372036854775807L),
    ] {
    let result = must_settle(
      must_parse("人：A B\nA " + amount + " 茶 =B:" + amount),
    )
    check_transfers(result.transfers, [("B", "A", expected)])
    check_settlement_invariants(result)
  }
}

///|
test "text golden A dinner through parsing and settlement" {
  let text = "人：小明 小红 小刚 小美\n小明 300 晚餐\n小红 120 加菜\n小刚 40 饮料 !小红"
  let ledger = must_parse(text)
  assert_eq(ledger.payments[2].description, "饮料")
  let result = must_settle(ledger)
  assert_eq(result.total_cents, 46000L)
  check_balances(
    result.balances,
    ["小明", "小红", "小刚", "小美"],
    [30000L, 12000L, 4000L, 0L],
    [11833L, 10500L, 11833L, 11834L],
    [18167L, 1500L, -7833L, -11834L],
  )
  check_transfers(result.transfers, [
    ("小美", "小明", 11834L),
    ("小刚", "小明", 6333L),
    ("小刚", "小红", 1500L),
  ])
  check_settlement_invariants(result)
}

///|
test "text golden B mixed through parsing and settlement" {
  let text = "人：小明 小红 小刚 小美 小李\n小明 200 晚餐\n小红 75 奶茶 =小明:12 小红:15 小刚:18 小美:14 小李:16"
  let ledger = must_parse(text)
  assert_eq(ledger.payments[0].description, "晚餐")
  assert_eq(ledger.payments[1].description, "奶茶")
  let result = must_settle(ledger)
  assert_eq(result.total_cents, 27500L)
  check_balances(
    result.balances,
    ledger.people,
    [20000L, 7500L, 0L, 0L, 0L],
    [5200L, 5500L, 5800L, 5400L, 5600L],
    [14800L, 2000L, -5800L, -5400L, -5600L],
  )
  check_transfers(result.transfers, [
    ("小刚", "小明", 5800L),
    ("小李", "小明", 5600L),
    ("小美", "小明", 3400L),
    ("小美", "小红", 2000L),
  ])
  check_settlement_invariants(result)
}

///|
test "text first header colon wins even when a name has reserved punctuation" {
  text_error(
    "人: A：B", "第 1 行：文本模式姓名不能包含 @、!、= 或冒号",
  )
  text_error(
    "人 ： A:B", "第 1 行：文本模式姓名不能包含 @、!、= 或冒号",
  )
}
