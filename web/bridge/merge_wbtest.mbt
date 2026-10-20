///|
test "AI results default to append and do not alter the old ledger before confirmation" {
  let state = WebState::new()
  state.replace(web_fixture())
  let before = state.source()
  let serial = state.begin_request()
  let incoming = @shared.parse_text(
    "人：小明 小红 小刚\n小明 30 早餐",
  )
  assert_true(
    state.finish_request(serial, 200, web_response(incoming, "核对早餐")),
  )
  assert_eq(state.source(), before)
  match state.preview {
    Some(p) => assert_true(p.merge)
    None => fail("AI preview required")
  }
  assert_eq(state.preview_result().payments.length(), 4)
  state.apply_preview()
  assert_eq(state.ledger.payments.length(), 4)
  assert_eq(web_present(state.ledger).total, "170.00")
  assert_eq(state.ledger.payments[0], web_fixture().payments[0])
  assert_true(web_rejects(() => state.apply_preview()))
  assert_eq(state.ledger.payments.length(), 4)
}

///|
test "switching preview modes is reversible and replacing old records needs acknowledgement" {
  let state = WebState::new()
  state.replace(web_fixture())
  let before = state.source()
  let incoming = @shared.parse_text(
    "人：小明 新成员\n新成员 20 水果",
  )
  state.stage(incoming, "预览", merge=true)
  assert_eq(state.preview_result().payments.length(), 4)
  match state.preview {
    Some(p) => state.preview = Some({ ..p, merge: false, })
    None => fail("preview required")
  }
  assert_eq(state.preview_result().payments.length(), 1)
  assert_true(web_rejects(() => state.apply_preview()))
  assert_eq(state.source(), before)
  state.apply_preview(replacement_confirmed=true)
  assert_eq(state.ledger.people, ["小明", "新成员"])
  assert_eq(web_present(state.ledger).total, "20.00")
}

///|
test "duplicate appends are blocked until reviewed and never silently deduplicated" {
  let state = WebState::new()
  state.replace(web_fixture())
  let before = state.source()
  state.stage(web_fixture(), "重复预览", merge=true)
  assert_eq(state.preview_duplicates(), 3)
  assert_true(web_rejects(() => state.apply_preview()))
  assert_eq(state.source(), before)
  assert_true(state.preview is Some(_))
  state.apply_preview(duplicates_confirmed=true)
  assert_eq(state.ledger.payments.length(), 6)
  assert_eq(web_present(state.ledger).total, "280.00")
}

///|
test "empty incoming append and stale previews preserve the existing ledger" {
  let state = WebState::new()
  state.replace(web_fixture())
  let before = state.source()
  state.stage(mutate("view", web_empty, "{}"), "空预览", merge=true)
  state.apply_preview()
  assert_eq(state.source(), before)
  state.stage(web_fixture(), "待确认", merge=true)
  state.change("add_person", "{\"name\":\"后来者\"}")
  let changed = state.source()
  assert_true(web_rejects(() => state.apply_preview(duplicates_confirmed=true)))
  assert_eq(state.source(), changed)
}

///|
test "preview cards show actual merged tail cents and escape user text" {
  let current = @shared.parse_text("人：甲 乙")
  let incoming = @shared.parse_text(
    "人：乙 甲\n甲 0.29 <script>晚餐</script>",
  )
  let merged = @shared.merge_ledgers(current, incoming)
  let html = web_preview_markup(current, incoming, merged, true)
  assert_true(html.contains("确认后总额"))
  assert_true(html.contains("¥ 0.29"))
  assert_true(html.contains("甲 <b>¥ 0.14"))
  assert_true(html.contains("乙 <b>¥ 0.15"))
  assert_true(html.contains("&lt;script&gt;"))
  assert_false(html.contains("<script>"))
  assert_true(web_bill_context(merged).contains("默认追加"))
}
