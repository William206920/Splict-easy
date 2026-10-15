///|
/// Call only after validate_ledger. Allocate in Ledger.people order, not UI order.
fn allocate_validated(
  people : Array[String],
  payment : Payment,
) -> Array[Share] {
  let allocated : Array[Share] = []
  match payment.split_mode {
    Equal => {
      let n = payment.participants.length().to_int64()
      let base = payment.amount_cents / n
      let remainder = payment.amount_cents % n
      let mut position = 0L
      for person in people {
        if has_person(payment.participants, person) {
          let extra = if position >= n - remainder { 1L } else { 0L }
          allocated.push({ person, amount_cents: base + extra, })
          position = position + 1L
        }
      }
    }
    Exact =>
      for person in people {
        for share in payment.shares {
          if share.person == person {
            allocated.push({ person, amount_cents: share.amount_cents, })
          }
        }
      }
  }
  allocated
}

///|
/// Validate a standalone payment against the supplied declaration order.
pub fn allocate_payment(
  people : Array[String],
  payment : Payment,
) -> Result[Array[Share], String] {
  match validate_ledger({ people, payments: [payment], ambiguous: [], }) {
    Err(message) => Err(message)
    Ok(_) => Ok(allocate_validated(people, payment))
  }
}

///|
fn person_index(people : Array[String], name : String) -> Int32 {
  for i, person in people {
    if person == name {
      return i
    }
  }
  -1
}

///|
/// Validate every call, then sum paid/owed separately with checked additions.
pub fn calculate_balances(ledger : Ledger) -> Result[BalanceSheet, String] {
  match validate_ledger(ledger) {
    Err(message) => return Err(message)
    Ok(_) => ()
  }
  let paid : Array[Int64] = Array::make(ledger.people.length(), 0L)
  let owed : Array[Int64] = Array::make(ledger.people.length(), 0L)
  let mut total = 0L
  for payment in ledger.payments {
    total = match checked_add_cents(total, payment.amount_cents) {
      Ok(value) => value
      Err(message) => return Err(message)
    }
    let payer = person_index(ledger.people, payment.payer)
    if payer < 0 {
      return Err("内部错误：付款人索引无效")
    }
    paid[payer] = match checked_add_cents(paid[payer], payment.amount_cents) {
      Ok(value) => value
      Err(message) => return Err(message)
    }
    for share in allocate_validated(ledger.people, payment) {
      let person = person_index(ledger.people, share.person)
      if person < 0 {
        return Err("内部错误：份额人员索引无效")
      }
      owed[person] = match checked_add_cents(owed[person], share.amount_cents) {
        Ok(value) => value
        Err(message) => return Err(message)
      }
    }
  }
  let balances : Array[PersonBalance] = []
  let mut paid_total = 0L
  let mut owed_total = 0L
  for i, person in ledger.people {
    paid_total = match checked_add_cents(paid_total, paid[i]) {
      Ok(value) => value
      Err(message) => return Err(message)
    }
    owed_total = match checked_add_cents(owed_total, owed[i]) {
      Ok(value) => value
      Err(message) => return Err(message)
    }
    // Both operands lie in [0, total] and total <= Int64.MAX_VALUE.
    // Their difference lies in [-MAX_VALUE, MAX_VALUE], so subtraction is safe.
    balances.push({
      person,
      paid_cents: paid[i],
      owed_cents: owed[i],
      balance_cents: paid[i] - owed[i],
    })
  }
  if paid_total != total || owed_total != total {
    return Err("内部错误：已付、应付与消费总额不守恒")
  }
  Ok({ total_cents: total, balances, })
}

///|
/// Largest creditor/debtor each round. Strict comparison keeps declaration ties.
/// Greedy reduces transfers but does not guarantee a global minimum count.
fn generate_transfers(
  balances : Array[PersonBalance],
) -> Result[Array[Transfer], String] {
  let remaining = balances.map(fn(balance) { balance.balance_cents })
  let transfers : Array[Transfer] = []
  while true {
    let mut creditor = -1
    let mut debtor = -1
    let mut credit = 0L
    let mut debt = 0L
    for i, value in remaining {
      if value > credit {
        creditor = i
        credit = value
      }
      if value < debt {
        debtor = i
        debt = value
      }
    }
    if creditor == -1 && debtor == -1 {
      break
    }
    if creditor < 0 || debtor < 0 || creditor == debtor {
      return Err("内部错误：余额不守恒，无法完成转账")
    }
    // Validated total bounds every balance, so debt can never be Int64.MIN_VALUE.
    let amount = if credit < -debt { credit } else { -debt }
    if amount <= 0L {
      return Err("内部错误：转账金额必须大于零")
    }
    transfers.push({
      from: balances[debtor].person,
      to: balances[creditor].person,
      amount_cents: amount,
    })
    remaining[creditor] = credit - amount
    remaining[debtor] = debt + amount
  }
  for value in remaining {
    if value != 0L {
      return Err("内部错误：结算后余额未归零")
    }
  }
  Ok(transfers)
}

///|
/// Public entrypoint: never settle unvalidated or ambiguous input.
pub fn settle_ledger(ledger : Ledger) -> Result[Settlement, String] {
  let sheet = match calculate_balances(ledger) {
    Ok(value) => value
    Err(message) => return Err(message)
  }
  let transfers = match generate_transfers(sheet.balances) {
    Ok(value) => value
    Err(message) => return Err(message)
  }
  Ok({ total_cents: sheet.total_cents, balances: sheet.balances, transfers, })
}
