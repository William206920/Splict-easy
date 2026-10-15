///|
fn stage3_ledger(
  people : Array[String],
  payments : Array[@shared.Payment],
) -> @shared.Ledger {
  { people, payments, ambiguous: [], }
}

///|
fn equal_bill(
  payer : String,
  amount : Int64,
  participants : Array[String],
) -> @shared.Payment {
  {
    payer,
    amount_cents: amount,
    split_mode: Equal,
    participants,
    shares: [],
    description: "平均",
    date: "",
  }
}

///|
fn exact_bill(
  payer : String,
  amount : Int64,
  shares : Array[@shared.Share],
) -> @shared.Payment {
  {
    payer,
    amount_cents: amount,
    split_mode: Exact,
    participants: [],
    shares,
    description: "实际金额",
    date: "",
  }
}

///|
fn must_settle(ledger : @shared.Ledger) -> @shared.Settlement raise {
  match @shared.settle_ledger(ledger) {
    Ok(value) => value
    Err(message) => fail(message)
  }
}

///|
fn must_allocate(
  people : Array[String],
  payment : @shared.Payment,
) -> Array[@shared.Share] raise {
  match @shared.allocate_payment(people, payment) {
    Ok(value) => value
    Err(message) => fail(message)
  }
}

///|
fn check_shares(
  actual : Array[@shared.Share],
  names : Array[String],
  amounts : Array[Int64],
) -> Unit raise {
  assert_eq(actual.length(), names.length())
  assert_eq(actual.length(), amounts.length())
  for i, share in actual {
    assert_eq(share.person, names[i])
    assert_eq(share.amount_cents, amounts[i])
  }
}

///|
fn check_balances(
  actual : Array[@shared.PersonBalance],
  names : Array[String],
  paid : Array[Int64],
  owed : Array[Int64],
  net : Array[Int64],
) -> Unit raise {
  assert_eq(actual.length(), names.length())
  for i, balance in actual {
    assert_eq(balance.person, names[i])
    assert_eq(balance.paid_cents, paid[i])
    assert_eq(balance.owed_cents, owed[i])
    assert_eq(balance.balance_cents, net[i])
  }
}

///|
fn check_transfers(
  actual : Array[@shared.Transfer],
  expected : Array[(String, String, Int64)],
) -> Unit raise {
  assert_eq(actual.length(), expected.length())
  for i, transfer in actual {
    let (from, to, amount) = expected[i]
    assert_eq(transfer.from, from)
    assert_eq(transfer.to, to)
    assert_eq(transfer.amount_cents, amount)
  }
}

///|
fn test_person_index(
  balances : Array[@shared.PersonBalance],
  person : String,
) -> Int32 raise {
  for i, balance in balances {
    if balance.person == person {
      return i
    }
  }
  fail("unknown person in transfers")
}

///|
/// Independent replay checks conservation and legal directions for every transfer.
fn check_settlement_invariants(result : @shared.Settlement) -> Unit raise {
  let remaining = result.balances.map(fn(balance) { balance.balance_cents })
  let mut paid = 0L
  let mut owed = 0L
  let mut credit = 0L
  let mut debt = 0L
  let mut nonzero = 0
  for balance in result.balances {
    assert_true(balance.paid_cents >= 0L)
    assert_true(balance.owed_cents >= 0L)
    assert_eq(balance.balance_cents, balance.paid_cents - balance.owed_cents)
    paid = paid + balance.paid_cents
    owed = owed + balance.owed_cents
    if balance.balance_cents > 0L {
      credit = credit + balance.balance_cents
      nonzero = nonzero + 1
    } else if balance.balance_cents < 0L {
      debt = debt - balance.balance_cents
      nonzero = nonzero + 1
    }
  }
  assert_eq(paid, result.total_cents)
  assert_eq(owed, result.total_cents)
  assert_eq(credit, debt)
  for transfer in result.transfers {
    assert_true(transfer.from != transfer.to)
    assert_true(transfer.amount_cents > 0L)
    let from = test_person_index(result.balances, transfer.from)
    let to = test_person_index(result.balances, transfer.to)
    assert_true(remaining[from] < 0L)
    assert_true(remaining[to] > 0L)
    assert_true(transfer.amount_cents <= -remaining[from])
    assert_true(transfer.amount_cents <= remaining[to])
    remaining[from] = remaining[from] + transfer.amount_cents
    remaining[to] = remaining[to] - transfer.amount_cents
  }
  for balance in remaining {
    assert_eq(balance, 0L)
  }
  if nonzero == 0 {
    assert_eq(result.transfers.length(), 0)
  } else {
    assert_true(result.transfers.length() <= nonzero - 1)
  }
}

///|
test "equal allocation remainder goes to last declared participants" {
  let names = ["A", "B", "C"]
  check_shares(
    must_allocate(names, equal_bill("A", 10000L, ["C", "A", "B"])),
    names,
    [3333L, 3333L, 3334L],
  )
}

///|
test "equal allocation subset uses ledger order" {
  check_shares(
    must_allocate(["A", "B", "C", "D"], equal_bill("A", 5L, ["D", "B", "C"])),
    ["B", "C", "D"],
    [1L, 2L, 2L],
  )
}

///|
test "equal allocation divisible and single person" {
  check_shares(
    must_allocate(["A", "B"], equal_bill("A", 10L, ["A", "B"])),
    ["A", "B"],
    [5L, 5L],
  )
  check_shares(
    must_allocate(["A"], equal_bill("A", 9223372036854775807L, ["A"])),
    ["A"],
    [9223372036854775807L],
  )
}

///|
test "equal allocation less cents than participants" {
  check_shares(
    must_allocate(["A", "B", "C"], equal_bill("A", 1L, ["A", "B", "C"])),
    ["A", "B", "C"],
    [0L, 0L, 1L],
  )
}

///|
test "exact allocation preserves values and orders by ledger" {
  let bill = exact_bill("A", 75L, [
    { person: "C", amount_cents: 50L, },
    { person: "A", amount_cents: 25L, },
    { person: "B", amount_cents: 0L, },
  ])
  check_shares(must_allocate(["A", "B", "C", "D"], bill), ["A", "B", "C"], [
    25L, 0L, 50L,
  ])
  assert_eq(bill.shares[0].person, "C")
}

///|
test "allocation validates empty or unknown input before division" {
  for
    bill in [
      equal_bill("A", 1L, []),
      equal_bill("A", 1L, ["unknown"]),
      exact_bill("A", 1L, []),
    ] {
    match @shared.allocate_payment(["A"], bill) {
      Err(_) => ()
      Ok(_) => fail("invalid allocation accepted")
    }
  }
}

///|
test "golden A four person dinner" {
  let names = ["小明", "小红", "小刚", "小美"]
  let ledger = stage3_ledger(names, [
    equal_bill("小明", 30000L, names),
    equal_bill("小红", 12000L, names),
    equal_bill("小刚", 4000L, ["小明", "小刚", "小美"]),
  ])
  let result = must_settle(ledger)
  assert_eq(result.total_cents, 46000L)
  check_balances(
    result.balances,
    names,
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
test "golden B five person mixed dinner and milk tea" {
  let names = ["小明", "小红", "小刚", "小美", "小李"]
  let ledger = stage3_ledger(names, [
    equal_bill("小明", 20000L, names),
    exact_bill("小红", 7500L, [
      { person: "小明", amount_cents: 1200L, },
      { person: "小红", amount_cents: 1500L, },
      { person: "小刚", amount_cents: 1800L, },
      { person: "小美", amount_cents: 1400L, },
      { person: "小李", amount_cents: 1600L, },
    ]),
  ])
  let result = must_settle(ledger)
  assert_eq(result.total_cents, 27500L)
  check_balances(
    result.balances,
    names,
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
test "no payments produces all zero and no transfers" {
  let result = must_settle(stage3_ledger(["A", "B"], []))
  check_balances(result.balances, ["A", "B"], [0L, 0L], [0L, 0L], [0L, 0L])
  assert_eq(result.total_cents, 0L)
  check_settlement_invariants(result)
}

///|
test "self payment and already balanced ledger need no transfers" {
  for
    ledger in [
      stage3_ledger(["A"], [equal_bill("A", 100L, ["A"])]),
      stage3_ledger(["A", "B"], [
        equal_bill("A", 10L, ["A", "B"]),
        equal_bill("B", 10L, ["A", "B"]),
      ]),
    ] {
    let result = must_settle(ledger)
    assert_eq(result.transfers.length(), 0)
    check_settlement_invariants(result)
  }
}

///|
test "payer outside consumers and zero shares" {
  let result = must_settle(
    stage3_ledger(["A", "B", "C"], [
      exact_bill("A", 100L, [
        { person: "B", amount_cents: 100L, },
        { person: "C", amount_cents: 0L, },
      ]),
    ]),
  )
  check_balances(
    result.balances,
    ["A", "B", "C"],
    [100L, 0L, 0L],
    [0L, 100L, 0L],
    [100L, -100L, 0L],
  )
  check_transfers(result.transfers, [("B", "A", 100L)])
  check_settlement_invariants(result)
}

///|
test "equal payer outside consumers" {
  let result = must_settle(
    stage3_ledger(["A", "B", "C"], [equal_bill("A", 3L, ["C", "B"])]),
  )
  check_balances(result.balances, ["A", "B", "C"], [3L, 0L, 0L], [0L, 1L, 2L], [
    3L, -1L, -2L,
  ])
  check_transfers(result.transfers, [("C", "A", 2L), ("B", "A", 1L)])
}

///|
test "tie break follows people declaration for both signs" {
  let names = ["C2", "D2", "C1", "D1"]
  let ledger = stage3_ledger(names, [
    exact_bill("C1", 10L, [{ person: "D1", amount_cents: 10L, }]),
    exact_bill("C2", 10L, [{ person: "D2", amount_cents: 10L, }]),
  ])
  let result = must_settle(ledger)
  check_transfers(result.transfers, [("D2", "C2", 10L), ("D1", "C1", 10L)])
  check_settlement_invariants(result)
}

///|
test "largest creditor is chosen anew each round" {
  let result = must_settle(
    stage3_ledger(["C1", "C2", "D1", "D2", "D3"], [
      exact_bill("C1", 10L, [
        { person: "D1", amount_cents: 7L, },
        { person: "D2", amount_cents: 3L, },
      ]),
      exact_bill("C2", 8L, [
        { person: "D2", amount_cents: 3L, },
        { person: "D3", amount_cents: 5L, },
      ]),
    ]),
  )
  check_transfers(result.transfers, [
    ("D1", "C1", 7L),
    ("D2", "C2", 6L),
    ("D3", "C1", 3L),
    ("D3", "C2", 2L),
  ])
  check_settlement_invariants(result)
}

///|
test "repeat payer accumulates both allocation modes" {
  let result = must_settle(
    stage3_ledger(["A", "B"], [
      equal_bill("A", 100L, ["A", "B"]),
      exact_bill("A", 75L, [{ person: "B", amount_cents: 75L, }]),
    ]),
  )
  check_balances(result.balances, ["A", "B"], [175L, 0L], [50L, 125L], [
    125L, -125L,
  ])
  check_transfers(result.transfers, [("B", "A", 125L)])
  check_settlement_invariants(result)
}

///|
test "maximum cent amount stays exact during transfers" {
  let result = must_settle(
    stage3_ledger(["A", "B"], [
      exact_bill("A", 9223372036854775807L, [
        { person: "B", amount_cents: 9223372036854775807L, },
      ]),
    ]),
  )
  check_transfers(result.transfers, [("B", "A", 9223372036854775807L)])
  check_settlement_invariants(result)
}

///|
test "maximum equal amount allocates without overflow" {
  let result = must_settle(
    stage3_ledger(["A", "B"], [
      equal_bill("A", 9223372036854775807L, ["A", "B"]),
    ]),
  )
  check_balances(
    result.balances,
    ["A", "B"],
    [9223372036854775807L, 0L],
    [4611686018427387903L, 4611686018427387904L],
    [4611686018427387904L, -4611686018427387904L],
  )
  check_settlement_invariants(result)
}

///|
test "JS unsafe integer boundary survives balance computation" {
  let result = must_settle(
    stage3_ledger(["A", "B"], [
      exact_bill("A", 9007199254740993L, [
        { person: "B", amount_cents: 9007199254740993L, },
      ]),
    ]),
  )
  check_transfers(result.transfers, [("B", "A", 9007199254740993L)])
  check_settlement_invariants(result)
}

///|
test "public settlement rejects overflow and ambiguity" {
  let overflow = stage3_ledger(["A"], [
    equal_bill("A", 9223372036854775807L, ["A"]),
    equal_bill("A", 1L, ["A"]),
  ])
  match @shared.settle_ledger(overflow) {
    Err(message) =>
      assert_eq(
        message, "第 2 笔消费：金额合计超出 Int64 整数分范围",
      )
    Ok(_) => fail("overflow accepted")
  }
  match
    @shared.settle_ledger({
      ..stage3_ledger(["A"], []),
      ambiguous: ["付款人不明"],
    }) {
    Err(message) => assert_eq(message, "账单存在歧义：付款人不明")
    Ok(_) => fail("ambiguity accepted")
  }
}

///|
test "public balance and settlement revalidate bad inputs" {
  let ledger = stage3_ledger(["A", "B"], [
    exact_bill("A", 100L, [{ person: "B", amount_cents: 99L, }]),
  ])
  match @shared.calculate_balances(ledger) {
    Err(message) =>
      assert_eq(
        message, "第 1 笔消费：个人分摊金额合计必须等于消费总金额",
      )
    Ok(_) => fail("invalid balance input accepted")
  }
  match @shared.settle_ledger(stage3_ledger([], [])) {
    Err(message) => assert_eq(message, "参与人员不能为空")
    Ok(_) => fail("empty people accepted")
  }
}

///|
test "settlement deterministic and input independent from output mutation" {
  let people = ["A", "B", "C"]
  let participants = ["C", "A", "B"]
  let ledger = stage3_ledger(people, [equal_bill("A", 10000L, participants)])
  let first = must_settle(ledger)
  for _ in 0..<5 {
    let next = must_settle(ledger)
    check_transfers(next.transfers, [("C", "A", 3334L), ("B", "A", 3333L)])
    check_settlement_invariants(next)
  }
  first.transfers.clear()
  first.balances.clear()
  assert_eq(people[0], "A")
  assert_eq(participants[0], "C")
  assert_eq(ledger.payments[0].amount_cents, 10000L)
  assert_eq(must_settle(ledger).transfers.length(), 2)
}

///|
test "greedy does not promise global minimum count" {
  let result = must_settle(
    stage3_ledger(["C1", "C2", "D1", "D2", "D3"], [
      exact_bill("C1", 13L, [
        { person: "D2", amount_cents: 7L, },
        { person: "D3", amount_cents: 6L, },
      ]),
      exact_bill("C2", 8L, [{ person: "D1", amount_cents: 8L, }]),
    ]),
  )
  check_transfers(result.transfers, [
    ("D1", "C1", 8L),
    ("D2", "C2", 7L),
    ("D3", "C1", 5L),
    ("D3", "C2", 1L),
  ])
  check_settlement_invariants(result)
  // A different 3-transfer solution exists: D1->C2 8, D2->C1 7, D3->C1 6.
}

///|
test "bounded mixed ledgers conserve and fully settle across 375 cases" {
  let all_names = ["A", "B", "C", "D", "E"]
  let mut cases = 0
  for n in 1..<6 {
    let names : Array[String] = []
    for i in 0..<n {
      names.push(all_names[i])
    }
    for amount in 1..<26 {
      for payer in 0..<n {
        let ledger = stage3_ledger(names, [
          equal_bill(names[payer], amount.to_int64(), names),
          exact_bill(names[(payer + 1) % n], (amount + 2).to_int64(), [
            {
              person: names[(payer + 2) % n],
              amount_cents: (amount + 2).to_int64(),
            },
          ]),
        ])
        check_settlement_invariants(must_settle(ledger))
        cases = cases + 1
      }
    }
  }
  assert_eq(cases, 375)
}
