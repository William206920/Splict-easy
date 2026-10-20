///|
fn web_rejects(action : () -> Unit raise @shared.BillError) -> Bool {
  try {
    action()
    false
  } catch {
    _ => true
  }
}

///|
fn web_fixture() -> @shared.Ledger raise @shared.BillError {
  mutate(
    "import",
    web_empty,
    "{\"text\":" + @shared.quote_json(web_sample) + "}",
  )
}

///|
fn web_response(ledger : @shared.Ledger, preview : String) -> String {
  "{\"ok\":true,\"ledger\":" +
  @shared.quote_json(@shared.encode_ledger(ledger)) +
  ",\"preview\":" +
  @shared.quote_json(preview) +
  "}"
}

///|
test "browser presentation preserves mixed golden transfers and reports" {
  let ledger = web_fixture()
  let page = web_present(ledger)
  assert_eq(page.total, "140.00")
  assert_true(page.expenses.contains("小明 付款 · 3 人平摊"))
  assert_true(page.expenses.contains("小红 付款 · 按实际金额"))
  assert_true(page.balances.contains("应收 40.00"))
  assert_eq(page.balances.split("应付 20.00").count(), 3)
  assert_eq(page.transfers.split("<strong>¥ 20.00</strong>").count(), 3)
  assert_true(page.text.contains("总消费：140.00 元"))
  assert_true(page.markdown.contains("140.00"))
  assert_eq(web_member_count(ledger, "小明"), 3)
  assert_eq(web_member_count(ledger, "小红"), 2)
  assert_eq(web_member_count(ledger, "小刚"), 2)
}

///|
test "all dynamic HTML contexts escape markup and preserve emoji avatars" {
  assert_eq(web_escape("<&>\"'"), "&lt;&amp;&gt;&quot;&#39;")
  assert_eq(web_avatar("😀旅行"), "😀")
  assert_eq(web_avatar("<hello"), "&lt;")
  assert_eq(web_avatar(""), "·")
  let ledger = mutate(
    "import",
    web_empty,
    "{\"text\":" +
    @shared.quote_json("人：<A> B\n<A> 0.29 <script> @<A> B") +
    "}",
  )
  let page = web_present(ledger)
  for
    html in [
      page.expenses,
      page.members,
      page.transfers,
      page.balances,
      web_options(ledger.people),
      web_participants(ledger, None),
    ] {
    assert_false(html.contains("<script>"))
    assert_false(html.contains("<A>"))
    assert_true(html.contains("&lt;A&gt;"))
  }
  assert_true(page.expenses.contains("&lt;script&gt;"))
}

///|
test "payment editor selection carries exact shares without JS arithmetic" {
  let ledger = web_fixture()
  let exact = web_participants(ledger, Some(ledger.payments[1]))
  assert_true(exact.contains("value=\"10.00\""))
  assert_true(exact.contains("value=\"20.00\""))
  assert_eq(exact.split(" checked").count(), 3)
  let equal = web_participants(ledger, Some(ledger.payments[2]))
  assert_eq(equal.split(" checked").count(), 3)
  let fresh = web_participants(ledger, None)
  assert_eq(fresh.split(" checked").count(), 4)
  let payload = web_payment_payload(
    -1, "小明", " 0.29 ", " 尾差 ", "", "equal", "{\"participants\":[\"小明\",\"小红\",\"小刚\"],\"amounts\":[\"\",\"\",\"\"]}",
  )
  let changed = mutate("put_payment", @shared.encode_ledger(ledger), payload)
  let report = @shared.settle(changed)
  assert_eq(report.total_cents, 14029L)
  assert_eq(changed.payments[3].description, "尾差")
}

///|
test "browser renderer never rounds an Int64 amount through a double" {
  let ledger = mutate(
    "import",
    web_empty,
    "{\"text\":" +
    @shared.quote_json("人：A B\nA 90071992547409.93 巨额 @A B") +
    "}",
  )
  let page = web_present(ledger)
  assert_eq(page.total, "90071992547409.93")
  assert_true(page.expenses.contains("90071992547409.93"))
  assert_true(page.balances.contains("45035996273704.97"))
  let state = WebState::new()
  state.replace(ledger)
  let recovered = WebState::new()
  recovered.load(state.source())
  assert_eq(recovered.ledger, ledger)
}

///|
test "failed import and failed mutation preserve the prior browser ledger" {
  let state = WebState::new()
  state.replace(web_fixture())
  let before = state.source()
  assert_true(
    web_rejects(() => state.change("remove_person", "{\"name\":\"小明\"}")),
  )
  assert_true(
    web_rejects(() => state.stage_import("人：A B\nA 1 错误 =A:0.20 B:0.20")),
  )
  assert_true(
    web_rejects(() => {
      state.change("remove_payment", "{\"index\":\"4294967296\"}")
    }),
  )
  assert_eq(state.source(), before)
  assert_eq(state.revision, 1)
  assert_true(state.preview is None)
}

///|
test "staging, cancelling, and applying an import require explicit replacement" {
  let state = WebState::new()
  let before = state.source()
  state.stage_import(web_sample)
  assert_eq(state.source(), before)
  assert_true(state.preview is Some(_))
  state.preview = None
  assert_eq(state.source(), before)
  assert_true(web_rejects(() => state.apply_preview()))
  state.stage_import(web_sample)
  state.apply_preview()
  assert_eq(web_present(state.ledger).total, "140.00")
  assert_true(state.preview is None)
}

///|
test "any intervening ledger revision invalidates an older preview" {
  let state = WebState::new()
  state.stage_import(web_sample)
  state.change("add_person", "{\"name\":\"新成员\"}")
  let before = state.source()
  assert_true(web_rejects(() => state.apply_preview()))
  assert_eq(state.source(), before)
  assert_eq(state.ledger.people, ["新成员"])
}

///|
test "corrupt browser drafts retain original bytes and block writes until backup" {
  let state = WebState::new()
  let broken = "{broken-old-ledger"
  assert_true(web_rejects(() => state.load(broken)))
  assert_eq(state.saved, broken)
  assert_eq(state.corrupt, Some(broken))
  assert_true(web_rejects(() => state.writable(broken, true)))
  assert_eq(state.ledger.people.length(), 0)
  state.corrupt = None
  state.writable(broken, true)
}

///|
test "concurrent tab changes cannot silently overwrite browser storage" {
  let state = WebState::new()
  let original = @shared.encode_ledger(web_fixture())
  state.load(original)
  state.writable(original, true)
  assert_true(web_rejects(() => state.writable("different-tab", true)))
  assert_true(web_rejects(() => state.writable("", true)))
  // Unavailable storage permits in-memory work; the browser warns on failed save.
  state.writable("", false)
  state.change("add_person", "{\"name\":\"只在内存\"}")
  assert_eq(state.saved, original)
  state.writable(original, true)
}

///|
test "service absence, missing consent, empty text and missing invite fail before IO" {
  let state = WebState::new()
  assert_true(web_rejects(() => ignore(state.prepare_ai("账单", true, ""))))
  state.service = Some(web_service("{\"enabled\":false}"))
  assert_true(web_rejects(() => ignore(state.prepare_ai("账单", true, ""))))
  state.service = Some(
    web_service(
      "{\"enabled\":true,\"provider\":\"api.moonshot.cn\",\"model\":\"kimi-k2.6\",\"invitationRequired\":true}",
    ),
  )
  for text in ["", " ", "\n\t"] {
    assert_true(
      web_rejects(() => ignore(state.prepare_ai(text, true, "invitation"))),
    )
  }
  assert_true(
    web_rejects(() => ignore(state.prepare_ai("账单", false, "invitation"))),
  )
  assert_true(web_rejects(() => ignore(state.prepare_ai("账单", true, ""))))
  assert_false(state.busy)
  assert_eq(state.serial, 0)
  let confirmation = state.prepare_ai("账单", true, "invitation")
  assert_true(confirmation.contains("api.moonshot.cn"))
  assert_true(confirmation.contains("kimi-k2.6"))
  assert_false(state.busy)
}

///|
test "browser AI text length is validated without starting a request" {
  let state = WebState::new()
  state.service = Some({
    enabled: true,
    provider: "api.moonshot.cn",
    model: "kimi-k2.6",
    invite: false,
  })
  let text = StringBuilder()
  for i = 0; i < 8000; i = i + 1 {
    text.write_string("中")
  }
  ignore(state.prepare_ai(text.to_string(), true, ""))
  text.write_string("文")
  assert_true(
    web_rejects(() => ignore(state.prepare_ai(text.to_string(), true, ""))),
  )
  assert_eq(state.serial, 0)
}

///|
test "AI success creates a validated preview and never commits before confirmation" {
  let state = WebState::new()
  let original = state.source()
  let serial = state.begin_request()
  assert_true(state.busy)
  assert_true(
    web_rejects(() => state.change("add_person", "{\"name\":\"禁止修改\"}")),
  )
  assert_true(
    state.finish_request(
      serial,
      200,
      web_response(web_fixture(), "逐笔核对"),
    ),
  )
  assert_false(state.busy)
  assert_eq(state.source(), original)
  match state.preview {
    Some(p) => assert_eq(p.text, "逐笔核对")
    None => fail("preview required")
  }
  state.apply_preview()
  assert_eq(web_present(state.ledger).total, "140.00")
}

///|
test "cancellation and stale callbacks cannot overwrite a later request" {
  let state = WebState::new()
  let first = state.begin_request()
  state.cancel_request()
  let second = state.begin_request()
  assert_false(
    state.finish_request(first, 200, web_response(web_fixture(), "旧响应")),
  )
  assert_true(state.busy)
  assert_true(state.preview is None)
  assert_true(
    state.finish_request(second, 200, web_response(web_fixture(), "新响应")),
  )
  assert_false(
    state.finish_request(
      second,
      200,
      web_response(web_fixture(), "重复响应"),
    ),
  )
  match state.preview {
    Some(p) => assert_eq(p.text, "新响应")
    None => fail("preview required")
  }
}

///|
test "ambiguous, malformed, failed and interrupted responses preserve the ledger" {
  for
    response in [
      (422, "{\"error\":\"账单存在歧义：付款人是谁？\"}"),
      (503, "{\"error\":\"额度服务暂不可用\"}"),
      (200, "not-json"),
      (200, "{\"ledger\":\"{}\",\"preview\":\"不可用\"}"),
      (-1, ""),
    ] {
    let state = WebState::new()
    state.replace(web_fixture())
    let before = state.source()
    let serial = state.begin_request()
    assert_true(
      web_rejects(() => {
        ignore(state.finish_request(serial, response.0, response.1))
      }),
    )
    assert_false(state.busy)
    assert_eq(state.source(), before)
    assert_true(state.preview is None)
  }
  let interrupted = WebState::new()
  assert_false(interrupted.finish_request(interrupted.begin_request(), 0, ""))
  assert_false(interrupted.busy)
}

///|
test "server ledger strings are independently revalidated on the client" {
  let state = WebState::new()
  let invalid = "{\"schema_version\":1,\"people\":[\"A\",\"B\"],\"payments\":[],\"ambiguous\":[\"谁付钱？\"]}"
  let response = "{\"ledger\":" +
    @shared.quote_json(invalid) +
    ",\"preview\":\"看似正确\"}"
  let serial = state.begin_request()
  assert_true(
    web_rejects(() => ignore(state.finish_request(serial, 200, response))),
  )
  assert_true(state.preview is None)
  assert_eq(state.ledger.people.length(), 0)
}

///|
test "empty state, zero transfers and unknown routes remain usable" {
  let state = WebState::new()
  let page = web_present(state.ledger)
  assert_eq(page.total, "0.00")
  assert_true(page.expenses.contains("还没有消费"))
  assert_true(page.members.contains("还没有成员"))
  assert_true(page.balances.contains("colspan=\"4\""))
  assert_true(page.transfers.contains("添加消费后"))
  assert_eq(web_route("#members"), "members")
  assert_eq(web_route("#import"), "import")
  assert_eq(web_route("#ai"), "ai")
  assert_eq(web_route("#<script>"), "overview")
  assert_eq(web_route(""), "overview")
  let balanced = mutate(
    "import",
    web_empty,
    "{\"text\":" + @shared.quote_json("人：A B\nA 1 单人 @A") + "}",
  )
  assert_true(web_present(balanced).transfers.contains("大家已经平衡"))
}
