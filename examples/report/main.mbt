///|
/// Fixed offline demonstration, not a CLI argument or file-IO implementation.
fn output(text : String, format : @shared.ReportFormat) -> String {
  match @shared.solve_text(text, format) {
    Ok(value) => value
    Err(message) => abort(message)
  }
}

///|
fn main {
  let dinner = "人：小明 小红 小刚 小美\n小明 300 晚餐\n小红 120 加菜\n小刚 40 饮料 !小红"
  let mixed = "人：小明 小红 小刚 小美 小李\n小明 200 晚餐\n小红 75 奶茶 =小明:12 小红:15 小刚:18 小美:14 小李:16"
  let large = "人：A B\nA 90071992547409.93 茶 =B:90071992547409.93"
  let max = "人：A B\nA 92233720368547758.07 茶 =B:92233720368547758.07"
  let person = "<img/src=x/onerror=alert(1)>"
  let special : @shared.Ledger = {
    people: [person, "B|*_[x]"],
    payments: [
      {
        payer: person,
        amount_cents: 29L,
        split_mode: Exact,
        participants: [],
        shares: [{ person: "B|*_[x]", amount_cents: 29L, }],
        description: "茶</h3><script>alert(1)</script>&\"'|\n第二行",
        date: "</p><img/src=x/onerror=alert(2)>",
      },
    ],
    ambiguous: [],
  }
  let special_report = match @shared.build_report(special) {
    Ok(value) => value
    Err(message) => abort(message)
  }
  let controls = StringBuilder()
  for i in 0..<32 {
    controls.write_char(i.to_char().unwrap())
  }
  controls.write_string("中文😀<>&\u{2028}\u{2029}")
  let outputs : Array[(String, String)] = [
    ("dinner_markdown", output(dinner, Markdown)),
    ("mixed_json", output(mixed, Json)),
    ("dinner_html", output(dinner, Html)),
    ("mixed_html", output(mixed, Html)),
    ("max_json", output(max, Json)),
    ("large_json", output(large, Json)),
    ("special_html", @shared.render_html_document(special_report)),
    ("special_markdown", @shared.render_markdown(special_report)),
    ("special_json", @shared.render_json(special_report)),
    ("no_transfer_html", output("人：A\nA 1 自用", Html)),
    ("error_html", @shared.render_text_html("人：A\n<script> 1 茶")),
    ("controls_encoded", @shared.quote_json(controls.to_string())),
  ]
  let result = StringBuilder()
  result.write_char('{')
  for i, entry in outputs {
    if i > 0 {
      result.write_char(',')
    }
    let (key, value) = entry
    result.write_string(
      @shared.quote_json(key) + ":" + @shared.quote_json(value),
    )
  }
  result.write_char('}')
  println(result.to_string())
}
