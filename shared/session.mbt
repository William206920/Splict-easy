///|
pub(all) struct Session {
  mut ledger : Ledger
  mut revision : Int32
  mut report : Report?
}

///|
pub fn Session::new() -> Session {
  {
    ledger: { people: [], payments: [], ambiguous: [], },
    revision: 0,
    report: None,
  }
}

///|
pub fn Session::replace(
  self : Session,
  ledger : Ledger,
) -> Unit raise BillError {
  if ledger.people.length() > 200 || ledger.payments.length() > 5000 {
    invalid("桌面账单最多 200 人、5000 笔消费；请拆分账单")
  }
  if ledger.people.is_empty() &&
    ledger.payments.is_empty() &&
    ledger.ambiguous.is_empty() {
    ()
  } else {
    validate(ledger)
  }
  self.ledger = ledger
  self.revision = self.revision + 1
  self.report = None
}

///|
pub fn Session::add_person(
  self : Session,
  name : String,
) -> Unit raise BillError {
  let people = self.ledger.people.copy()
  people.push(name)
  self.replace({ ..self.ledger, people, })
}

///|
pub fn Session::rename(
  self : Session,
  old : String,
  name : String,
) -> Unit raise BillError {
  if !self.ledger.people.contains(old) {
    invalid("未知人员")
  }
  let people = self.ledger.people.map(p => if p == old { name } else { p })
  let payments = self.ledger.payments.map(p => {
    ..p,
    payer: if p.payer == old {
      name
    } else {
      p.payer
    },
    participants: p.participants.map(v => if v == old { name } else { v }),
    shares: p.shares.map(s => {
      ..s,
      person: if s.person == old {
        name
      } else {
        s.person
      },
    }),
  })
  self.replace({ ..self.ledger, people, payments, })
}

///|
pub fn Session::remove_person(
  self : Session,
  name : String,
) -> Unit raise BillError {
  if !self.ledger.people.contains(name) {
    invalid("未知人员")
  }
  for p in self.ledger.payments {
    if p.payer == name ||
      p.participants.contains(name) ||
      p.shares.any(s => s.person == name) {
      invalid("请先处理引用该人员的消费")
    }
  }
  self.replace({
    ..self.ledger,
    people: self.ledger.people.filter(p => p != name),
  })
}

///|
pub fn Session::put_payment(
  self : Session,
  index : Int32,
  p : Payment,
) -> Unit raise BillError {
  let payments = self.ledger.payments.copy()
  if index == -1 {
    payments.push(p)
  } else {
    if index < 0 || index >= payments.length() {
      invalid("消费索引无效")
    }
    payments[index] = p
  }
  self.replace({ ..self.ledger, payments, })
}

///|
pub fn Session::remove_payment(
  self : Session,
  index : Int32,
) -> Unit raise BillError {
  if index < 0 || index >= self.ledger.payments.length() {
    invalid("消费索引无效")
  }
  let payments : Array[Payment] = []
  for i = 0; i < self.ledger.payments.length(); i = i + 1 {
    if i != index {
      payments.push(self.ledger.payments[i])
    }
  }
  self.replace({ ..self.ledger, payments, })
}

///|
pub fn Session::solve(self : Session) -> Report raise BillError {
  if self.ledger.payments.is_empty() {
    invalid("请先添加消费")
  }
  let report = settle(self.ledger)
  self.report = Some(report)
  report
}
