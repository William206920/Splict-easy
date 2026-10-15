///|
test "session rename atomic failure and report invalidation" {
  let session = Session::new()
  session.replace(sample_mixed())
  ignore(session.solve())
  assert_true(session.report is Some(_))
  assert_true(rejected(() => session.rename("小明", "小红")))
  assert_true(session.report is Some(_))
  session.rename("小明", "新名字")
  assert_true(session.report is None)
  assert_eq(session.ledger.payments[0].payer, "新名字")
  assert_eq(session.ledger.payments[1].shares[0].person, "新名字")
  assert_true(rejected(() => session.remove_person("新名字")))
  session.remove_payment(1)
  session.remove_payment(0)
  session.remove_person("新名字")
  assert_true(!session.ledger.people.contains("新名字"))
}

///|
test "reports exact output stable money and escaped markdown" {
  let r = settle(sample_mixed())
  let text = render_text(r)
  assert_true(text.contains("小美 → 小红：20.00 元"))
  assert_true(render_report_json(r).contains("\"total_cents\":27500"))
  assert_true(
    render_report_json(r) == render_report_json(settle(sample_mixed())),
  )
  let p = r.ledger.payments[0]
  let ledger : Ledger = {
    ..r.ledger,
    payments: [{ ..p, description: "<script>|换\n行", }],
  }
  let md = render_markdown(settle(ledger))
  assert_true(md.contains("&lt;script&gt;\\|换 行"))
  let solo : Ledger = {
    people: ["A"],
    ambiguous: [],
    payments: [{ ..p, payer: "A", participants: ["A"], }],
  }
  assert_true(render_text(settle(solo)).contains("无需转账"))
}

///|
test "desktop limits reject atomically" {
  let session = Session::new()
  session.replace(sample_mixed())
  let people = Array::makei(201, i => "P" + i.to_string())
  assert_true(
    rejected(() => session.replace({ people, payments: [], ambiguous: [], })),
  )
  assert_true(session.ledger == sample_mixed())
}

///|
test "markdown escapes repeated cells and all linebreaks" {
  assert_eq(md_cell("<a>|<b>|x\ny\nz"), "&lt;a&gt;\\|&lt;b&gt;\\|x y z")
}
