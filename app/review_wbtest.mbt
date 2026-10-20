///|
test "native review preserves old bills, path and final member tail order" {
  let ui = Desktop::new(true)
  ui.session.replace(@shared.parse_text("人：B A\nB 10 晚餐"))
  ui.path = "existing.json"
  let old = ui.session.ledger.payments[0]
  ui.begin_review(@shared.parse_text("人：A B C\nA 0.01 早餐"), true)
  assert_true(ui.review_append)
  assert_true(ui.ai_preview.contains("A：0.00"))
  assert_true(ui.ai_preview.contains("B：0.01"))
  assert_eq(ui.session.ledger.payments.length(), 1)
  ui.apply_review()
  assert_eq(ui.path, "existing.json")
  assert_true(ui.session.ledger.people == ["B", "A", "C"])
  assert_true(ui.session.ledger.payments[0] == old)
  assert_eq(ui.session.ledger.payments.length(), 2)
  assert_eq(ledger_total(ui.session.ledger), 1001L)
  let blocked = try {
    ui.apply_review()
    false
  } catch {
    _ => true
  }
  assert_true(blocked)
  assert_eq(ui.session.ledger.payments.length(), 2)
}

///|
test "native duplicate and replacement checks are enforced before mutation" {
  let ui = Desktop::new(true)
  let bill = @shared.parse_text("人：A B\nA 10 晚餐")
  ui.session.replace(bill)
  ui.begin_review(bill, true)
  assert_eq(ui.review_duplicates(), 1)
  let duplicate = try {
    ui.apply_review()
    false
  } catch {
    _ => true
  }
  assert_true(duplicate && ui.session.ledger == bill)
  ui.review_duplicates_ok = true
  ui.apply_review()
  assert_eq(ui.session.ledger.payments.length(), 2)
  ui.begin_review(bill, false)
  let before = ui.session.ledger
  let replacement = try {
    ui.apply_review()
    false
  } catch {
    _ => true
  }
  assert_true(replacement && ui.session.ledger == before)
  ui.review_replace_ok = true
  ui.apply_review()
  assert_true(ui.session.ledger == bill)
}

///|
test "native stale preview rejects changed ledger and preserves pending state" {
  let ui = Desktop::new(true)
  ui.session.replace(@shared.parse_text("人：A B\nA 10 晚餐"))
  ui.begin_review(@shared.parse_text("人：A B\nB 20 早餐"), true)
  ui.session.add_person("C")
  let before = ui.session.ledger
  let rejected = try {
    ui.apply_review()
    false
  } catch {
    _ => true
  }
  assert_true(rejected && ui.session.ledger == before && ui.pending is Some(_))
}

///|
test "native member-only import can be reviewed and applied without settlement" {
  let ui = Desktop::new(true)
  ui.begin_review(@shared.parse_text("人：A B"), false)
  assert_true(ui.ai_preview.contains("尚无消费"))
  ui.apply_review()
  assert_true(
    ui.session.ledger.people == ["A", "B"] && ui.session.report is None,
  )
}

///|
test "native overflowing append remains cancellable or replaceable" {
  let ui = Desktop::new(true)
  ui.session.replace(
    @shared.parse_text("人：A\nA 92233720368547758.07 最大金额"),
  )
  ui.begin_review(@shared.parse_text("人：A\nA 0.01 早餐"), true)
  assert_true(ui.ai_preview.contains("暂时无法记入"))
  let before = ui.session.ledger
  let rejected = try {
    ui.apply_review()
    false
  } catch {
    _ => true
  }
  assert_true(rejected && ui.session.ledger == before)
  ui.review_append = false
  ui.review_replace_ok = true
  ui.refresh_review()
  ui.apply_review()
  assert_eq(ledger_total(ui.session.ledger), 1L)
}
