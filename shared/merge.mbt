///|
// Validate both inputs before constructing a new ledger. Existing member order
// stays fixed, so appending members never changes the old payments' tail cents.
pub fn merge_ledgers(
  current : Ledger,
  incoming : Ledger,
) -> Ledger raise BillError {
  let original = Session::new()
  original.replace(current)
  let added = Session::new()
  added.replace(incoming)
  let people = current.people.copy()
  for name in incoming.people {
    if !people.contains(name) {
      people.push(name)
    }
  }
  let payments = current.payments.copy()
  for payment in incoming.payments {
    payments.push(payment)
  }
  let result = Session::new()
  result.replace({ people, payments, ambiguous: [], })
  result.ledger
}

///|
// Exact record matches are warnings, never silently removed: two identical
// purchases may be legitimate. No monetary conversion passes through Float.
pub fn duplicate_payments(current : Ledger, incoming : Ledger) -> Int32 {
  let seen : Map[String, Bool] = Map([])
  for payment in current.payments {
    seen[encode_ledger({ people: [], payments: [payment], ambiguous: [], })] = true
  }
  let mut count = 0
  for payment in incoming.payments {
    let key = encode_ledger({ people: [], payments: [payment], ambiguous: [], })
    if seen.contains(key) {
      count = count + 1
    }
    seen[key] = true
  }
  count
}
