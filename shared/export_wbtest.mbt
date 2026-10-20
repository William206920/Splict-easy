///|
test "export has exactly two tables with all members and individually actionable transfers" {
  let tables = export_tables(sample_mixed())
  assert_eq(tables.length(), 2)
  assert_eq(tables[0].name, "成员转账明细")
  assert_eq(tables[1].name, "消费明细")
  assert_eq(tables[0].rows.length(), 6)
  assert_true(tables[0].rows[0][0] == Text("小明"))
  assert_true(tables[0].rows[0][2] == Amount(0L))
  assert_true(
    tables[0].rows[3] ==
    [
      Text("小美"),
      Text("小明"),
      Amount(3400L),
      Text("待转账（结算建议）"),
    ],
  )
  assert_true(
    tables[0].rows[4] ==
    [
      Text("小美"),
      Text("小红"),
      Amount(2000L),
      Text("待转账（结算建议）"),
    ],
  )
  assert_true(tables[0].note.contains("待转账合计 168.00"))
  assert_eq(tables[1].rows.length(), 2)
  assert_true(tables[1].rows[1][3] == Amount(7500L))
  assert_true(
    tables[1].rows[1][5] ==
    Text(
      "小明：12.00 元；小红：15.00 元；小刚：18.00 元；小美：14.00 元；小李：16.00 元",
    ),
  )
}

///|
test "CSV quotes delimiters, blocks formula interpretation and retains maximal cents" {
  assert_eq(csv_cell("=1+1", true), "\"'=1+1\"")
  assert_eq(csv_cell("a,\"b\"\nnext", true), "\"a,\"\"b\"\"\nnext\"")
  let ledger = parse_text("人：A B\nA 92233720368547758.07 最大金额 @B")
  let csv = export_csv(ledger)
  assert_true(csv.has_prefix("\u{FEFF}"))
  assert_true(csv.contains("'92233720368547758.07"))
  assert_true(csv.contains("\r\n"))
}

///|
test "HTML escapes user content and has exactly two independent report tables" {
  let ledger = parse_text("人：A B\nA 1 <script>alert(1)</script>")
  let html = export_html(ledger)
  assert_true(html.contains("&lt;script&gt;alert(1)&lt;/script&gt;"))
  assert_true(!html.contains("<script>"))
  assert_eq(html.split("<table>").to_array().length(), 3)
  assert_true(html.contains("window.print()"))
}

///|
test "XLSX stores exact large cents as text and ordinary money as numeric values" {
  let table = export_tables(
      parse_text("人：A B\nA 92233720368547758.07 大额 @B"),
    )[1]
  let xml = xlsx_sheet(table)
  assert_true(
    xml.contains(
      "t=\"inlineStr\"><is><t xml:space=\"preserve\">92233720368547758.07",
    ),
  )
  assert_true(!xml.contains("<v>92233720368547758.07</v>"))
  let normal = xlsx_sheet(export_tables(sample_mixed())[1])
  assert_true(normal.contains("<v>200.00</v>"))
  assert_true(normal.contains("ySplit=\"5\""))
  assert_eq(crc32(@utf8.encode("123456789")), 0xcbf43926U)
  assert_eq(export_xlsx(sample_mixed()), export_xlsx(sample_mixed()))
}

///|
test "XLSX literal escape sequences round trip and unsupported long cells fail explicitly" {
  assert_eq(xlsx_text("_x0041_ & <"), "_x005F_x0041_ &amp; &lt;")
  let rejected = try {
    ignore(xlsx_text(Array::make(32768, "x").join("")))
    false
  } catch {
    _ => true
  }
  assert_true(rejected)
}
