///|
fn xlsx_text(text : String) -> String raise BillError {
  if text.length() > 32767 {
    invalid(
      "Excel 单元格内容超过 32767 字符，请缩短姓名或说明，或改用结算单/CSV",
    )
  }
  for char in text.iter() {
    if (char.to_int() < 32 && char != '\t' && char != '\n' && char != '\r') ||
      char.to_int() == 65534 ||
      char.to_int() == 65535 {
      invalid("账单含 Excel 不支持的控制字符，请清理后导出")
    }
  }
  // Escape OOXML's own _xHHHH_ notation before XML encoding.
  export_escape(text.replace_all(old="_x", new="_x005F_x"))
}

///|
fn xlsx_string(
  ref_ : String,
  text : String,
  style : Int32,
) -> String raise BillError {
  "<c r=\"" +
  ref_ +
  "\" s=\"" +
  style.to_string() +
  "\" t=\"inlineStr\"><is><t xml:space=\"preserve\">" +
  xlsx_text(text) +
  "</t></is></c>"
}

///|
fn xlsx_sheet(table : ExportTable) -> String raise BillError {
  let columns = ["A", "B", "C", "D", "E", "F"]
  let last = columns[table.headers.length() - 1]
  let end = (table.rows.length() + 5).to_string()
  let out = [
    "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><worksheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\"><dimension ref=\"A1:" +
    last +
    end +
    "\"/><sheetViews><sheetView workbookViewId=\"0\"><pane ySplit=\"5\" topLeftCell=\"A6\" activePane=\"bottomLeft\" state=\"frozen\"/><selection pane=\"bottomLeft\" activeCell=\"A6\" sqref=\"A6\"/></sheetView></sheetViews><sheetFormatPr defaultRowHeight=\"24\"/><cols>",
  ]
  let widths = if table.headers.length() == 4 {
    [22, 22, 22, 58]
  } else {
    [16, 34, 22, 24, 20, 72]
  }
  for i = 0; i < widths.length(); i = i + 1 {
    let n = (i + 1).to_string()
    out.push(
      "<col min=\"" +
      n +
      "\" max=\"" +
      n +
      "\" width=\"" +
      widths[i].to_string() +
      "\" customWidth=\"1\"/>",
    )
  }
  out.push(
    "</cols><sheetData><row r=\"1\" ht=\"34\" customHeight=\"1\">" +
    xlsx_string("A1", "SplitEasy · " + table.name, 2) +
    "</row><row r=\"2\" ht=\"34\" customHeight=\"1\">" +
    xlsx_string("A2", table.note, 4) +
    "</row><row r=\"3\" ht=\"30\" customHeight=\"1\">" +
    xlsx_string(
      "A3", "金额单位：元；超过 15 位有效数字的金额按文本保留。文件为静态结算快照。",
      4,
    ) +
    "</row><row r=\"5\" ht=\"28\" customHeight=\"1\">",
  )
  for i = 0; i < table.headers.length(); i = i + 1 {
    out.push(xlsx_string(columns[i] + "5", table.headers[i], 1))
  }
  out.push("</row>")
  for row_index = 0; row_index < table.rows.length(); row_index = row_index + 1 {
    let row = table.rows[row_index]
    let n = (row_index + 6).to_string()
    let mut height = 30
    for i = 0; i < row.length(); i = i + 1 {
      match row[i] {
        Text(text) => {
          let needed = (text.length() * 2 / widths[i] + 1) * 17 + 8
          if needed > height {
            height = if needed > 400 { 400 } else { needed }
          }
        }
        _ => ()
      }
    }
    out.push(
      "<row r=\"" +
      n +
      "\" ht=\"" +
      height.to_string() +
      "\" customHeight=\"1\">",
    )
    for i = 0; i < row.length(); i = i + 1 {
      let ref_ = columns[i] + n
      out.push(
        match row[i] {
          Text(s) => xlsx_string(ref_, s, 0)
          Amount(v) =>
            if v > 999999999999999L {
              xlsx_string(ref_, money(v), 0)
            } else {
              "<c r=\"" +
              ref_ +
              "\" s=\"3\" t=\"n\"><v>" +
              money(v) +
              "</v></c>"
            }
        },
      )
    }
    out.push("</row>")
  }
  out.push(
    "</sheetData><autoFilter ref=\"A5:" +
    last +
    end +
    "\"/><mergeCells count=\"3\"><mergeCell ref=\"A1:" +
    last +
    "1\"/><mergeCell ref=\"A2:" +
    last +
    "2\"/><mergeCell ref=\"A3:" +
    last +
    "3\"/></mergeCells><pageMargins left=\"0.3\" right=\"0.3\" top=\"0.5\" bottom=\"0.5\" header=\"0.2\" footer=\"0.2\"/><pageSetup paperSize=\"9\" orientation=\"landscape\" fitToWidth=\"1\" fitToHeight=\"0\"/></worksheet>",
  )
  out.join("")
}

///|
pub fn export_xlsx(ledger : Ledger) -> Bytes raise BillError {
  let tables = export_tables(ledger)
  let types = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\"><Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/><Default Extension=\"xml\" ContentType=\"application/xml\"/><Override PartName=\"/xl/workbook.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml\"/><Override PartName=\"/xl/styles.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml\"/><Override PartName=\"/xl/worksheets/sheet1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/><Override PartName=\"/xl/worksheets/sheet2.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/></Types>"
  let rels = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"xl/workbook.xml\"/></Relationships>"
  let workbook = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><workbook xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\"><bookViews><workbookView/></bookViews><sheets><sheet name=\"成员转账明细\" sheetId=\"1\" r:id=\"rId1\"/><sheet name=\"消费明细\" sheetId=\"2\" r:id=\"rId2\"/></sheets></workbook>"
  let workbook_rels = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet1.xml\"/><Relationship Id=\"rId2\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet2.xml\"/><Relationship Id=\"rId3\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles\" Target=\"styles.xml\"/></Relationships>"
  let styles = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><styleSheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\"><numFmts count=\"1\"><numFmt numFmtId=\"164\" formatCode=\"#,##0.00\"/></numFmts><fonts count=\"3\"><font><sz val=\"11\"/><color rgb=\"FF172B46\"/><name val=\"Microsoft YaHei\"/></font><font><b/><sz val=\"11\"/><color rgb=\"FFFFFFFF\"/><name val=\"Microsoft YaHei\"/></font><font><b/><sz val=\"18\"/><color rgb=\"FF203653\"/><name val=\"Microsoft YaHei\"/></font></fonts><fills count=\"3\"><fill><patternFill patternType=\"none\"/></fill><fill><patternFill patternType=\"gray125\"/></fill><fill><patternFill patternType=\"solid\"><fgColor rgb=\"FF203653\"/><bgColor indexed=\"64\"/></patternFill></fill></fills><borders count=\"1\"><border><left/><right/><top/><bottom/><diagonal/></border></borders><cellStyleXfs count=\"1\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\"/></cellStyleXfs><cellXfs count=\"5\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\" xfId=\"0\" applyAlignment=\"1\"><alignment vertical=\"top\" wrapText=\"1\"/></xf><xf numFmtId=\"0\" fontId=\"1\" fillId=\"2\" borderId=\"0\" xfId=\"0\" applyAlignment=\"1\"><alignment vertical=\"center\"/></xf><xf numFmtId=\"0\" fontId=\"2\" fillId=\"0\" borderId=\"0\" xfId=\"0\"/><xf numFmtId=\"164\" fontId=\"0\" fillId=\"0\" borderId=\"0\" xfId=\"0\" applyNumberFormat=\"1\" applyAlignment=\"1\"><alignment horizontal=\"right\" vertical=\"top\"/></xf><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\" xfId=\"0\" applyAlignment=\"1\"><alignment wrapText=\"1\" vertical=\"center\"/></xf></cellXfs><cellStyles count=\"1\"><cellStyle name=\"Normal\" xfId=\"0\" builtinId=\"0\"/></cellStyles></styleSheet>"
  zip_store([
    ("[Content_Types].xml", types),
    ("_rels/.rels", rels),
    ("xl/workbook.xml", workbook),
    ("xl/_rels/workbook.xml.rels", workbook_rels),
    ("xl/styles.xml", styles),
    ("xl/worksheets/sheet1.xml", xlsx_sheet(tables[0])),
    ("xl/worksheets/sheet2.xml", xlsx_sheet(tables[1])),
  ])
}
