///|
pub(all) enum ExportCell {
  Text(String)
  Amount(Int64)
} derive(Eq)

///|
pub extend ExportCell with Eq::{equal, not_equal}

///|
pub(all) struct ExportTable {
  name : String
  headers : Array[String]
  rows : Array[Array[ExportCell]]
  note : String
}

///|
pub fn export_tables(ledger : Ledger) -> Array[ExportTable] raise BillError {
  // Never trust a cached report: every export is recalculated and validated.
  let report = settle(ledger)
  let transfers : Array[Array[ExportCell]] = []
  let mut transfer_total = 0L
  for person in ledger.people {
    let mut count = 0
    for t in report.transfers {
      if t.from == person {
        transfers.push([
          Text(person),
          Text(t.to),
          Amount(t.amount_cents),
          Text("待转账（结算建议）"),
        ])
        transfer_total = add_money(transfer_total, t.amount_cents)
        count = count + 1
      }
    }
    if count == 0 {
      transfers.push([
        Text(person),
        Text("—"),
        Amount(0L),
        Text("无需转出；如需收款请查看转入记录"),
      ])
    }
  }
  let payments : Array[Array[ExportCell]] = []
  for p in ledger.payments {
    let shares = shares_for(ledger.people, p).map(s => {
      s.person + "：" + money(s.amount_cents) + " 元"
    })
    payments.push([
      Text(p.date),
      Text(p.description),
      Text(p.payer),
      Amount(p.amount_cents),
      Text(if p.split_mode == Equal { "平均分摊" } else { "实际金额" }),
      Text(shares.join("；")),
    ])
  }
  [
    {
      name: "成员转账明细",
      headers: ["姓名", "转账给谁", "金额（元）", "说明"],
      rows: transfers,
      note: "总消费 " +
      money(report.total_cents) +
      " 元；待转账合计 " +
      money(transfer_total) +
      " 元。建议清单不代表已经付款。",
    },
    {
      name: "消费明细",
      headers: [
        "日期", "消费名称", "付款人", "消费金额（元）", "分摊方式",
        "各成员承担（元）",
      ],
      rows: payments,
      note: "共 " +
      ledger.payments.length().to_string() +
      " 笔；总消费 " +
      money(report.total_cents) +
      " 元。分摊尾差按原名单顺序计算。",
    },
  ]
}

///|
fn csv_cell(value : String, text : Bool) -> String {
  // Quoting alone does not stop spreadsheet formula interpretation.
  let probe = value.trim().to_owned()
  let safe = if text &&
    (
      probe.has_prefix("=") ||
      probe.has_prefix("+") ||
      probe.has_prefix("-") ||
      probe.has_prefix("@") ||
      value.has_prefix("\t") ||
      value.has_prefix("\r") ||
      value.has_prefix("\n")
    ) {
    "'" + value
  } else {
    value
  }
  "\"" + safe.replace_all(old="\"", new="\"\"") + "\""
}

///|
fn csv_export_cell(cell : ExportCell) -> String {
  match cell {
    Text(s) => csv_cell(s, true)
    Amount(v) =>
      csv_cell((if v > 999999999999999L { "'" } else { "" }) + money(v), false)
  }
}

///|
pub fn export_csv(ledger : Ledger) -> String raise BillError {
  let tables = export_tables(ledger)
  let lines = [
    "\u{FEFF}" +
    [
      "记录类型", "姓名/付款人", "转账给谁", "金额（元）", "消费名称",
      "日期", "分摊方式", "各成员承担（元）", "说明",
    ]
    .map(s => csv_cell(s, true))
    .join(","),
  ]
  for row in tables[0].rows {
    let cells = [
      Text("转账"),
      row[0],
      row[1],
      row[2],
      Text(""),
      Text(""),
      Text(""),
      Text(""),
      row[3],
    ]
    lines.push(cells.map(csv_export_cell).join(","))
  }
  for row in tables[1].rows {
    let cells = [
      Text("消费"),
      row[2],
      Text(""),
      row[3],
      row[1],
      row[0],
      row[4],
      row[5],
      Text(""),
    ]
    lines.push(cells.map(csv_export_cell).join(","))
  }
  lines.join("\r\n") + "\r\n"
}
