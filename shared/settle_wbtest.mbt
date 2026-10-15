///|
fn dinner_fixture() -> Ledger {
  let people = ["小明", "小红", "小刚", "小美"]
  {
    people,
    ambiguous: [],
    payments: [
      {
        payer: "小明",
        amount_cents: 30000L,
        split_mode: Equal,
        participants: people.copy(),
        shares: [],
        description: "晚餐",
        date: "",
      },
      {
        payer: "小红",
        amount_cents: 12000L,
        split_mode: Equal,
        participants: people.copy(),
        shares: [],
        description: "加菜",
        date: "",
      },
      {
        payer: "小刚",
        amount_cents: 4000L,
        split_mode: Equal,
        participants: ["小明", "小刚", "小美"],
        shares: [],
        description: "饮料",
        date: "",
      },
    ],
  }
}

///|
test "golden dinner balances and ordered transfers" {
  let report = settle(dinner_fixture())
  assert_true(
    report.balances.map(b => b.balance_cents) ==
    [18167L, 1500L, -7833L, -11834L],
  )
  assert_true(
    report.transfers ==
    [
      { from: "小美", to: "小明", amount_cents: 11834L, },
      { from: "小刚", to: "小明", amount_cents: 6333L, },
      { from: "小刚", to: "小红", amount_cents: 1500L, },
    ],
  )
}

///|
test "golden mixed balances and ordered transfers" {
  let r = settle(sample_mixed())
  assert_eq(r.total_cents, 27500L)
  assert_true(
    r.balances.map(b => b.balance_cents) ==
    [14800L, 2000L, -5800L, -5400L, -5600L],
  )
  assert_true(
    r.transfers ==
    [
      { from: "小刚", to: "小明", amount_cents: 5800L, },
      { from: "小李", to: "小明", amount_cents: 5600L, },
      { from: "小美", to: "小明", amount_cents: 3400L, },
      { from: "小美", to: "小红", amount_cents: 2000L, },
    ],
  )
}

///|
test "declaration order residual excluded payer zero and max" {
  let people = ["A", "B", "C"]
  let p : Payment = {
    payer: "A",
    amount_cents: 10000L,
    split_mode: Equal,
    participants: ["C", "A", "B"],
    shares: [],
    description: "x",
    date: "",
  }
  assert_true(
    shares_for(people, p).map(s => s.amount_cents) == [3333L, 3333L, 3334L],
  )
  assert_true(
    shares_for(people, { ..p, amount_cents: 1L, }).map(s => s.amount_cents) ==
    [0L, 0L, 1L],
  )
  let r = settle({
    people,
    payments: [
      { ..p, amount_cents: 9223372036854775807L, participants: ["C"], },
    ],
    ambiguous: [],
  })
  assert_eq(r.transfers[0].amount_cents, 9223372036854775807L)
}

///|
test "400 small ledgers conserve replay and determinism" {
  let people = ["A", "B", "C"]
  for a = 1; a <= 20; a = a + 1 {
    for b = 1; b <= 20; b = b + 1 {
      let p : Payment = {
        payer: "A",
        amount_cents: a.to_int64(),
        split_mode: Equal,
        participants: people.copy(),
        shares: [],
        description: "x",
        date: "",
      }
      let ledger : Ledger = {
        people,
        payments: [
          p,
          {
            ..p,
            payer: "B",
            amount_cents: b.to_int64(),
            participants: ["A", "C"],
          },
        ],
        ambiguous: [],
      }
      let r = settle(ledger)
      assert_true(r == settle(ledger))
      let remain = r.balances.map(x => x.balance_cents)
      let mut sum = 0L
      for x in remain {
        sum = sum + x
      }
      assert_eq(sum, 0L)
      for t in r.transfers {
        assert_true(t.amount_cents > 0L && t.from != t.to)
        for i = 0; i < people.length(); i = i + 1 {
          if people[i] == t.from {
            remain[i] = remain[i] + t.amount_cents
          }
          if people[i] == t.to {
            remain[i] = remain[i] - t.amount_cents
          }
        }
      }
      assert_true(remain == [0L, 0L, 0L])
    }
  }
}
