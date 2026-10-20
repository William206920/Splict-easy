///|
fn import_instructions() -> String {
  [
    "文本写法（金额单位：元）", "1. 第一行列出成员：人：小明 小红 小刚",
    "2. 每笔一行：付款人 金额 消费名称", "   小明 90 晚餐   → 全员平均分摊",
    "3. 在行末加一种分摊标记（同笔不可混用）：", "   @小明 小红   仅这些人平摊",
    "   !小刚        排除这些人后平摊", "   =小明:10 小红:20   按实际金额，合计须等于实付",
    "", "JSON 写法（金额单位：整数分，1250 表示 12.50 元）", "点击「JSON 示例」取得完整模板，再修改人名、金额和消费名称。",
    "schema_version 固定为 1；people 是名单；payments 是消费数组。",
    "每笔必填 payer、amount_cents、description、date 和分摊字段。",
    "equal：participants 填参与者，shares 为 []。", "exact：participants 为 []，shares 填每个人的 person 与 amount_cents。",
    "日期未知填空字符串；ambiguous 填 []；不要使用报表 JSON。",
    "", "共同规则：姓名不可含空格、冒号或 @ ! =；名单内的人才能参与。",
    "点击示例只填入编辑框。解析后选择追加或替换，确认后，才改变当前账单。",
  ].join("\n")
}

///|
fn import_text_example() -> String {
  "人：小明 小红 小刚\n小明 90 晚餐\n小红 30 奶茶 =小明:10 小红:20\n小刚 20 车费 @小明 小刚"
}

///|
fn import_json_example() -> String {
  [
    "{", "  \"schema_version\": 1,", "  \"people\": [\"小明\", \"小红\", \"小刚\"],",
    "  \"payments\": [", "    {", "      \"payer\": \"小明\",", "      \"amount_cents\": 9000,",
    "      \"split_mode\": \"equal\",", "      \"participants\": [\"小明\", \"小红\", \"小刚\"],",
    "      \"shares\": [],", "      \"description\": \"晚餐\",", "      \"date\": \"\"",
    "    },", "    {", "      \"payer\": \"小红\",", "      \"amount_cents\": 3000,",
    "      \"split_mode\": \"exact\",", "      \"participants\": [],", "      \"shares\": [",
    "        {\"person\": \"小明\", \"amount_cents\": 1000},", "        {\"person\": \"小红\", \"amount_cents\": 2000}",
    "      ],", "      \"description\": \"奶茶\",", "      \"date\": \"\"", "    },",
    "    {", "      \"payer\": \"小刚\",", "      \"amount_cents\": 2000,", "      \"split_mode\": \"equal\",",
    "      \"participants\": [\"小明\", \"小刚\"],", "      \"shares\": [],",
    "      \"description\": \"车费\",", "      \"date\": \"\"", "    }", "  ],",
    "  \"ambiguous\": []", "}",
  ].join("\n")
}

///|
fn clean_import(text : String) -> String {
  let trimmed = text.trim().to_owned()
  if trimmed.has_prefix("\u{FEFF}") {
    let chars = trimmed.iter().to_array()
    let mut result = ""
    for i = 1; i < chars.length(); i = i + 1 {
      result = result + chars[i].to_string()
    }
    result.trim().to_owned()
  } else {
    trimmed
  }
}

///|
fn import_ledger(text : String) -> @shared.Ledger raise @shared.BillError {
  let input = clean_import(text)
  if input.is_empty() {
    @shared.invalid(
      "请先输入账单，或点击文本 / JSON 示例后修改",
    )
  }
  if input.has_prefix("{") {
    @shared.decode_ledger(input, allow_empty=true)
  } else {
    @shared.parse_text(input)
  }
}

///|
fn ledger_preview(ledger : @shared.Ledger) -> String raise @shared.BillError {
  if ledger.payments.is_empty() {
    "成员：" +
    (if ledger.people.is_empty() { "无" } else { ledger.people.join("、") }) +
    "\n尚无消费，可以继续添加消费。"
  } else {
    @shared.render_text(@shared.settle(ledger))
  }
}
