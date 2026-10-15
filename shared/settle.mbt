///|
pub(all) struct Balance {
  person : String
  paid_cents : Int64
  due_cents : Int64
  balance_cents : Int64
} derive(Eq, @debug.Debug)

///|
pub(all) struct Report {
  ledger : Ledger
  total_cents : Int64
  balances : Array[Balance]
  transfers : Array[Transfer]
} derive(Eq, @debug.Debug)

///|
pub extend Balance with Eq::{equal, not_equal}

///|
pub extend Balance with @debug.Debug::{to_repr}

///|
pub extend Report with Eq::{equal, not_equal}

///|
pub extend Report with @debug.Debug::{to_repr}

///|
pub fn shares_for(
  people : Array[String],
  p : Payment,
) -> Array[Share] raise BillError {
  validate_payment(people, p)
  if p.split_mode == Exact {
    return p.shares.copy()
  }
  let count = p.participants.length()
  let base = p.amount_cents / count.to_int64()
  let extra = (p.amount_cents % count.to_int64()).to_int()
  let result : Array[Share] = []
  for name in people {
    if p.participants.contains(name) {
      result.push({
        person: name,
        amount_cents: base +
        (if result.length() >= count - extra { 1L } else { 0L }),
      })
    }
  }
  result
}

///|
pub fn settle(ledger : Ledger) -> Report raise BillError {
  validate(ledger)
  let n = ledger.people.length()
  let paid = Array::make(n, 0L)
  let due = Array::make(n, 0L)
  let mut total = 0L
  for p in ledger.payments {
    total = add_money(total, p.amount_cents)
    for i = 0; i < n; i = i + 1 {
      if ledger.people[i] == p.payer {
        paid[i] = add_money(paid[i], p.amount_cents)
      }
    }
    for share in shares_for(ledger.people, p) {
      for i = 0; i < n; i = i + 1 {
        if ledger.people[i] == share.person {
          due[i] = add_money(due[i], share.amount_cents)
        }
      }
    }
  }
  let balances : Array[Balance] = []
  let remaining : Array[Int64] = []
  for i = 0; i < n; i = i + 1 {
    let b = paid[i] - due[i]
    balances.push({
      person: ledger.people[i],
      paid_cents: paid[i],
      due_cents: due[i],
      balance_cents: b,
    })
    remaining.push(b)
  }
  let transfers : Array[Transfer] = []
  while true {
    let mut creditor = -1
    let mut debtor = -1
    for i = 0; i < n; i = i + 1 {
      if remaining[i] > 0L &&
        (creditor < 0 || remaining[i] > remaining[creditor]) {
        creditor = i
      }
      if remaining[i] < 0L && (debtor < 0 || remaining[i] < remaining[debtor]) {
        debtor = i
      }
    }
    if creditor < 0 || debtor < 0 {
      break
    }
    let amount = if remaining[creditor] < -remaining[debtor] {
      remaining[creditor]
    } else {
      -remaining[debtor]
    }
    transfers.push({
      from: ledger.people[debtor],
      to: ledger.people[creditor],
      amount_cents: amount,
    })
    remaining[creditor] = remaining[creditor] - amount
    remaining[debtor] = remaining[debtor] + amount
  }
  for amount in remaining {
    if amount != 0L {
      invalid("结算未守恒")
    }
  }
  { ledger, total_cents: total, balances, transfers, }
}

///|
pub fn sample_mixed() -> Ledger {
  {
    people: ["小明", "小红", "小刚", "小美", "小李"],
    ambiguous: [],
    payments: [
      {
        payer: "小明",
        amount_cents: 20000L,
        split_mode: Equal,
        participants: ["小明", "小红", "小刚", "小美", "小李"],
        shares: [],
        description: "晚餐",
        date: "",
      },
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
        date: "",
      },
    ],
  }
}
