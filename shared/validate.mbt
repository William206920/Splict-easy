///|
fn has_person(people : Array[String], name : String) -> Bool {
  for person in people {
    if person == name {
      return true
    }
  }
  false
}

///|
/// Return the first Chinese error in declaration order. Do not modify input.
/// Empty payments are allowed for a draft, but a people list is required.
pub fn validate_ledger(ledger : Ledger) -> Result[Unit, String] {
  if ledger.people.is_empty() {
    return Err("参与人员不能为空")
  }
  let seen : Array[String] = []
  for i, person in ledger.people {
    let mut first = true
    let mut leading_space = false
    let mut trailing_space = false
    let mut only_space = true
    for ch in person.iter() {
      if first {
        leading_space = ch.is_whitespace()
        first = false
      }
      trailing_space = ch.is_whitespace()
      if !trailing_space {
        only_space = false
      }
    }
    if only_space {
      return Err("第 \{i + 1} 位人员的姓名不能为空")
    }
    if leading_space || trailing_space {
      return Err("第 \{i + 1} 位人员的姓名首尾不能有空白")
    }
    if has_person(seen, person) {
      return Err("人员姓名重复：\{person}")
    }
    seen.push(person)
  }
  if !ledger.ambiguous.is_empty() {
    return Err("账单存在歧义：\{ledger.ambiguous[0]}")
  }
  let mut total = 0L
  for i, payment in ledger.payments {
    let prefix = "第 \{i + 1} 笔消费："
    match validate_payment_data(ledger.people, payment) {
      Err(message) => return Err(prefix + message)
      Ok(_) => ()
    }
    total = match checked_add_cents(total, payment.amount_cents) {
      Ok(value) => value
      Err(message) => return Err(prefix + message)
    }
  }
  Ok(())
}

///|
/// Internal shared rules: caller validates the people list first.
/// Keep payment errors free of location prefixes so adapters can add a line or index.
fn validate_payment_data(
  people : Array[String],
  payment : Payment,
) -> Result[Unit, String] {
  if !has_person(people, payment.payer) {
    return Err("未知付款人：" + payment.payer)
  }
  if payment.amount_cents <= 0L {
    return Err("消费总金额必须大于零")
  }
  match payment.split_mode {
    Equal => {
      if !payment.shares.is_empty() {
        return Err("平均分摊不能同时填写实际金额份额")
      }
      if payment.participants.is_empty() {
        return Err("平均分摊至少需要一位参与者")
      }
      let participants : Array[String] = []
      for name in payment.participants {
        if !has_person(people, name) {
          return Err("未知参与者：" + name)
        }
        if has_person(participants, name) {
          return Err("参与者重复：" + name)
        }
        participants.push(name)
      }
    }
    Exact => {
      if !payment.participants.is_empty() {
        return Err("按实际金额分摊不能同时填写平均参与者")
      }
      if payment.shares.is_empty() {
        return Err("按实际金额分摊至少需要一条份额")
      }
      let shares_seen : Array[String] = []
      let mut sum = 0L
      for share in payment.shares {
        if !has_person(people, share.person) {
          return Err("未知份额人员：" + share.person)
        }
        if has_person(shares_seen, share.person) {
          return Err("份额人员重复：" + share.person)
        }
        if share.amount_cents < 0L {
          return Err("个人分摊金额不能为负数：" + share.person)
        }
        shares_seen.push(share.person)
        sum = match checked_add_cents(sum, share.amount_cents) {
          Ok(value) => value
          Err(message) => return Err(message)
        }
      }
      if sum != payment.amount_cents {
        return Err("个人分摊金额合计必须等于消费总金额")
      }
    }
  }
  Ok(())
}
