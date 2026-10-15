///|
fn must_report(text : String) -> @shared.SettlementReport raise {
  match @shared.report_from_text(text) {
    Ok(report) => report
    Err(message) => fail(message)
  }
}

///|
fn special_report() -> @shared.SettlementReport raise {
  let a = "<img/src=x/onerror=alert(1)>"
  let b = "B|*_[x]"
  let ledger = stage3_ledger([a, b], [
    {
      ..exact_bill(a, 29L, [{ person: b, amount_cents: 29L, }]),
      description: "茶</h3><script>alert(1)</script>&\"'|\n第二行",
      date: "</p><img/src=x/onerror=alert(2)>",
    },
  ])
  match @shared.build_report(ledger) {
    Ok(report) => report
    Err(message) => fail(message)
  }
}

///|
test "HTML escape special characters" {
  assert_eq(@shared.escape_html("<&>\"'"), "&lt;&amp;&gt;&quot;&#39;")
  assert_eq(@shared.escape_html("中文 &lt;"), "中文 &amp;lt;")
}

///|
test "HTML user text cannot create elements or attributes" {
  let html = @shared.render_html(special_report())
  assert_false(html.contains("<script>"))
  assert_false(html.contains("<img/"))
  assert_true(html.contains("&lt;script&gt;alert(1)&lt;/script&gt;"))
  assert_true(html.contains("&lt;/p&gt;&lt;img/src=x/onerror=alert(2)&gt;"))
  assert_true(html.contains("&amp;&quot;&#39;"))
  assert_true(html.contains("B|*_[x]"))
}

///|
test "HTML shows total details modes shares and balances" {
  let report = must_report("人：A B\nA 1 饭\nB 0.29 茶 =A:0.29 B:0")
  let html = @shared.render_html(report)
  for
    part in [
      "1.29 元", "消费明细", "平均分摊", "按实际金额分摊", "B：0.00 元",
      "每人净额", "已付（元）", "应付（元）", "转账清单", "结算计算完成",
    ] {
    assert_true(html.contains(part))
  }
  assert_true(html.contains("color:#15803d"))
  assert_true(html.contains("color:#b91c1c"))
}

///|
test "HTML full document offline and fragment separation" {
  let report = must_report("人：A\nA 1 茶")
  let fragment = @shared.render_html(report)
  let document = @shared.render_html_document(report)
  assert_true(fragment.has_prefix("<section"))
  assert_true(document.has_prefix("<!doctype html>"))
  assert_true(document.contains("width=device-width"))
  assert_true(document.contains("lang=\"zh-CN\""))
  assert_true(document.contains("日期：未填写"))
  assert_false(document.contains("<script"))
  assert_false(document.contains("https://"))
  assert_true(document.contains(fragment))
}

///|
test "HTML safe error and source line" {
  assert_eq(
    @shared.render_error_html("<script>&\"'"),
    "<div class=\"spliteasy-error\" role=\"alert\"><strong>无法结算：</strong>&lt;script&gt;&amp;&quot;&#39;</div>",
  )
  let html = @shared.render_text_html("人：A B\n<script> 1 茶")
  assert_true(html.contains("第 2 行：未知付款人：&lt;script&gt;"))
  assert_false(html.contains("<script>"))
  assert_true(html.contains("role=\"alert\""))
}

///|
test "HTML and markdown empty and settled messages" {
  for text in ["人：A", "人：A\nA 1 茶"] {
    let report = must_report(text)
    assert_true(
      @shared.render_html(report).contains(
        "无需转账，所有人已平账。",
      ),
    )
    assert_true(
      @shared.render_markdown(report).contains(
        "无需转账，所有人已平账。",
      ),
    )
    assert_true(@shared.render_json(report).contains("\"transfers\":[]"))
  }
  assert_true(
    @shared.render_html(must_report("人：A")).contains(
      "暂无消费记录。",
    ),
  )
  assert_true(
    @shared.render_markdown(must_report("人：A")).contains(
      "暂无消费记录。",
    ),
  )
}

///|
test "Markdown table metacharacters and line endings escaped" {
  assert_eq(@shared.escape_markdown("A|B\\C"), "A\\|B\\\\C")
  assert_eq(
    @shared.escape_markdown("*_[x](y)`#+-!~"),
    "\\*\\_\\[x\\]\\(y\\)\\`\\#\\+\\-\\!\\~",
  )
  assert_eq(
    @shared.escape_markdown("<b>&\r\nx\ry\nz\tq"),
    "&lt;b&gt;&amp;<br>x<br>y<br>z q",
  )
}

///|
test "Markdown all user columns and transfers are escaped" {
  let md = @shared.render_markdown(special_report())
  assert_false(md.contains("<script>"))
  assert_false(md.contains("<img/"))
  assert_true(md.contains("B\\|\\*\\_\\[x\\]"))
  assert_true(md.contains("&lt;/p&gt;&lt;img/src=x/onerror=alert\\(2\\)&gt;"))
  assert_true(md.contains("<br>第二行"))
}

///|
test "JSON quotes slashes controls and script delimiters" {
  assert_eq(
    @shared.quote_json("\"\\\n\r\t\u{0008}\u{000C}\u{0000}\u{001F}"),
    "\"\\\"\\\\\\n\\r\\t\\b\\f\\u0000\\u001f\"",
  )
  assert_eq(
    @shared.quote_json("<>&\u{2028}\u{2029}"),
    "\"\\u003c\\u003e\\u0026\\u2028\\u2029\"",
  )
  assert_eq(@shared.quote_json("中文😀"), "\"中文😀\"")
}

///|
test "JSON stable empty golden" {
  assert_eq(
    @shared.render_json(must_report("人：A")),
    "{\"schema_version\":1,\"total_cents\":0,\"balances\":[{\"person\":\"A\",\"paid_cents\":0,\"owed_cents\":0,\"balance_cents\":0}],\"transfers\":[],\"payments\":[]}\n",
  )
}

///|
test "JSON 64-bit integer tokens are not strings or rounded numbers" {
  let json = @shared.render_json(
    must_report("人：A B\nA 92233720368547758.07 茶 =B:92233720368547758.07"),
  )
  assert_true(json.contains("\"amount_cents\":9223372036854775807"))
  assert_true(json.contains("\"balance_cents\":-9223372036854775807"))
  assert_false(json.contains("\"9223372036854775807\""))
  assert_false(json.contains("e+"))
  assert_true(
    @shared.render_json(
      must_report("人：A B\nA 90071992547409.93 茶 =B:90071992547409.93"),
    ).contains("\"total_cents\":9007199254740993"),
  )
}

///|
test "JSON payments include dates zero allocations and stable order" {
  let json = @shared.render_json(must_report("人：A B\nA 0.01 茶 @B A"))
  assert_true(json.contains("\"split_mode\":\"equal\""))
  assert_true(json.contains("\"date\":\"\""))
  assert_true(
    json.contains(
      "\"shares\":[{\"person\":\"A\",\"amount_cents\":0},{\"person\":\"B\",\"amount_cents\":1}]",
    ),
  )
  let special = @shared.render_json(special_report())
  assert_true(special.contains("\\u003cscript\\u003e"))
  assert_true(special.contains("\\n第二行"))
}

///|
test "renders are deterministic and do not mutate reports" {
  let report = must_report("人：A B\nA 1 茶")
  let md = @shared.render_markdown(report)
  let html = @shared.render_html(report)
  let json = @shared.render_json(report)
  for _ in 0..<3 {
    assert_eq(@shared.render_markdown(report), md)
    assert_eq(@shared.render_html(report), html)
    assert_eq(@shared.render_json(report), json)
  }
  assert_eq(report.balances[0].balance_cents, 50L)
  assert_eq(report.transfers[0].amount_cents, 50L)
  assert_eq(report.payments[0].shares[1].amount_cents, 50L)
}

///|
test "Markdown dinner full golden output" {
  let report = must_report(
    "人：小明 小红 小刚 小美\n小明 300 晚餐\n小红 120 加菜\n小刚 40 饮料 !小红",
  )
  assert_eq(
    @shared.render_markdown(report),
    "# SplitEasy 结算单\n\n总消费：460.00 元\n\n## 消费明细\n\n| 序号 | 消费 | 付款人 | 金额（元） | 分摊方式 | 日期 |\n|---|---|---|---:|---|---|\n| 1 | 晚餐 | 小明 | 300.00 | 平均分摊 |  |\n| 2 | 加菜 | 小红 | 120.00 | 平均分摊 |  |\n| 3 | 饮料 | 小刚 | 40.00 | 平均分摊 |  |\n\n第 1 笔分摊：小明 75.00 元；小红 75.00 元；小刚 75.00 元；小美 75.00 元\n\n第 2 笔分摊：小明 30.00 元；小红 30.00 元；小刚 30.00 元；小美 30.00 元\n\n第 3 笔分摊：小明 13.33 元；小刚 13.33 元；小美 13.34 元\n\n## 每人净额\n\n| 人员 | 已付（元） | 应付（元） | 净额（元） |\n|---|---:|---:|---:|\n| 小明 | 300.00 | 118.33 | +181.67 |\n| 小红 | 120.00 | 105.00 | +15.00 |\n| 小刚 | 40.00 | 118.33 | -78.33 |\n| 小美 | 0.00 | 118.34 | -118.34 |\n\n## 转账清单\n\n1. 小美 → 小明：118.34 元\n2. 小刚 → 小明：63.33 元\n3. 小刚 → 小红：15.00 元\n\n结算计算完成。转账清单仅为建议，不代表已经完成付款。\n",
  )
}

///|
test "JSON mixed full golden output" {
  let report = must_report(
    "人：小明 小红 小刚 小美 小李\n小明 200 晚餐\n小红 75 奶茶 =小明:12 小红:15 小刚:18 小美:14 小李:16",
  )
  assert_eq(
    @shared.render_json(report),
    "{\"schema_version\":1,\"total_cents\":27500,\"balances\":[{\"person\":\"小明\",\"paid_cents\":20000,\"owed_cents\":5200,\"balance_cents\":14800},{\"person\":\"小红\",\"paid_cents\":7500,\"owed_cents\":5500,\"balance_cents\":2000},{\"person\":\"小刚\",\"paid_cents\":0,\"owed_cents\":5800,\"balance_cents\":-5800},{\"person\":\"小美\",\"paid_cents\":0,\"owed_cents\":5400,\"balance_cents\":-5400},{\"person\":\"小李\",\"paid_cents\":0,\"owed_cents\":5600,\"balance_cents\":-5600}],\"transfers\":[{\"from\":\"小刚\",\"to\":\"小明\",\"amount_cents\":5800},{\"from\":\"小李\",\"to\":\"小明\",\"amount_cents\":5600},{\"from\":\"小美\",\"to\":\"小明\",\"amount_cents\":3400},{\"from\":\"小美\",\"to\":\"小红\",\"amount_cents\":2000}],\"payments\":[{\"payer\":\"小明\",\"amount_cents\":20000,\"split_mode\":\"equal\",\"description\":\"晚餐\",\"date\":\"\",\"shares\":[{\"person\":\"小明\",\"amount_cents\":4000},{\"person\":\"小红\",\"amount_cents\":4000},{\"person\":\"小刚\",\"amount_cents\":4000},{\"person\":\"小美\",\"amount_cents\":4000},{\"person\":\"小李\",\"amount_cents\":4000}]},{\"payer\":\"小红\",\"amount_cents\":7500,\"split_mode\":\"exact\",\"description\":\"奶茶\",\"date\":\"\",\"shares\":[{\"person\":\"小明\",\"amount_cents\":1200},{\"person\":\"小红\",\"amount_cents\":1500},{\"person\":\"小刚\",\"amount_cents\":1800},{\"person\":\"小美\",\"amount_cents\":1400},{\"person\":\"小李\",\"amount_cents\":1600}]}]}\n",
  )
}
