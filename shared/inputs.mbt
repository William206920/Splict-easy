///|
pub fn words(text : String) -> Array[String] {
  let result : Array[String] = []
  let mut word = ""
  for c in text.iter() {
    if c.is_whitespace() {
      if !word.is_empty() {
        result.push(word)
        word = ""
      }
    } else {
      word = word + c.to_string()
    }
  }
  if !word.is_empty() {
    result.push(word)
  }
  result
}

///|
fn drop_chars(text : String, count : Int32) -> String {
  let mut result = ""
  let mut i = 0
  for c in text.iter() {
    if i >= count {
      result = result + c.to_string()
    }
    i = i + 1
  }
  result
}

///|
fn payment_line(
  people : Array[String],
  line : String,
) -> Payment raise BillError {
  let tokens = words(line)
  if tokens.length() < 2 {
    invalid("消费至少填写付款人和金额")
  }
  let amount = parse_money(tokens[1])
  let descriptions : Array[String] = []
  let names : Array[String] = []
  let shares : Array[Share] = []
  let mut marker = ""
  for i = 2; i < tokens.length(); i = i + 1 {
    let token = tokens[i]
    let prefix = if token.has_prefix("@") {
      "@"
    } else if token.has_prefix("!") {
      "!"
    } else if token.has_prefix("=") {
      "="
    } else {
      ""
    }
    let mut value = token
    if prefix != "" {
      if marker != "" {
        invalid("一笔只能使用一个 @、! 或 = 标记")
      }
      marker = prefix
      value = drop_chars(token, 1)
      if value.is_empty() {
        continue
      }
    }
    if marker == "" {
      descriptions.push(value)
    } else if marker == "=" {
      let parts = value.split(":").to_array()
      if parts.length() != 2 {
        invalid("实际份额格式为 姓名:金额")
      }
      shares.push({
        person: parts[0].to_owned(),
        amount_cents: parse_money(parts[1].to_owned()),
      })
    } else {
      names.push(value)
    }
  }
  if marker != "" && names.is_empty() && shares.is_empty() {
    invalid("分摊标记后缺少人员")
  }
  let participants = if marker == "=" {
    []
  } else if marker == "@" {
    names
  } else if marker == "!" {
    let seen : Array[String] = []
    for name in names {
      if !people.contains(name) {
        invalid("未知排除人员：" + name)
      }
      if seen.contains(name) {
        invalid("排除人员重复：" + name)
      }
      seen.push(name)
    }
    people.filter(name => !names.contains(name))
  } else {
    people.copy()
  }
  let p : Payment = {
    payer: tokens[0],
    amount_cents: amount,
    split_mode: if marker == "=" {
      Exact
    } else {
      Equal
    },
    participants,
    shares,
    description: if descriptions.is_empty() {
      "消费"
    } else {
      descriptions.join(" ")
    },
    date: "",
  }
  validate_payment(people, p)
  p
}

///|
pub fn parse_text(text : String) -> Ledger raise BillError {
  let lines = text.split("\n").to_array()
  let mut people : Array[String] = []
  let payments : Array[Payment] = []
  let mut total = 0L
  for index = 0; index < lines.length(); index = index + 1 {
    let mut line = lines[index].trim().to_owned()
    if index == 0 && line.has_prefix("\u{FEFF}") {
      line = drop_chars(line, 1)
    }
    if line.is_empty() {
      continue
    }
    try {
      if line.has_prefix("人：") || line.has_prefix("人:") {
        if !people.is_empty() || !payments.is_empty() {
          invalid("人员名单只能在消费之前声明一次")
        }
        people = words(drop_chars(line, 2))
        validate_people(people)
      } else {
        if people.is_empty() {
          invalid("请先用 人： 声明人员")
        }
        let p = payment_line(people, line)
        total = add_money(total, p.amount_cents)
        payments.push(p)
      }
    } catch {
      error =>
        invalid(
          "第 " + (index + 1).to_string() + " 行：" + error_message(error),
        )
    }
  }
  let ledger : Ledger = { people, payments, ambiguous: [], }
  validate(ledger)
  ledger
}

///|
pub fn quote_json(text : String) -> String {
  Json::string(text).stringify()
}

///|
fn json_field(value : RawJson, key : String) -> RawJson raise BillError {
  match value {
    Obj(fields) =>
      match fields.get(key) {
        Some(item) => item
        None => {
          invalid("缺少字段：" + key)
          Str("")
        }
      }
    _ => {
      invalid("JSON 必须是对象")
      Str("")
    }
  }
}

///|
fn json_string(value : RawJson) -> String raise BillError {
  match value {
    Str(text) => text
    _ => {
      invalid("JSON 字段必须是字符串")
      ""
    }
  }
}

///|
fn json_array(value : RawJson) -> Array[RawJson] raise BillError {
  match value {
    Arr(items) => items
    _ => {
      invalid("JSON 字段必须是数组")
      []
    }
  }
}

///|
fn json_cents(value : RawJson) -> Int64 raise BillError {
  match value {
    Num(text) => parse_cents_integer(text)
    _ => {
      invalid("JSON 金额必须是整数分数字")
      0L
    }
  }
}

///|
pub fn decode_ledger(text : String) -> Ledger raise BillError {
  let value = parse_raw_json(text)
  if json_cents(json_field(value, "schema_version")) != 1L {
    invalid("不支持的账单版本")
  }
  let people = json_array(json_field(value, "people")).map(item => {
    json_string(item)
  })
  let ambiguous = json_array(json_field(value, "ambiguous")).map(item => {
    json_string(item)
  })
  let payments : Array[Payment] = []
  for item in json_array(json_field(value, "payments")) {
    let mode = json_string(json_field(item, "split_mode"))
    if mode != "equal" && mode != "exact" {
      invalid("未知分摊模式")
    }
    let shares : Array[Share] = []
    for share in json_array(json_field(item, "shares")) {
      shares.push({
        person: json_string(json_field(share, "person")),
        amount_cents: json_cents(json_field(share, "amount_cents")),
      })
    }
    payments.push({
      payer: json_string(json_field(item, "payer")),
      amount_cents: json_cents(json_field(item, "amount_cents")),
      split_mode: if mode == "equal" {
        Equal
      } else {
        Exact
      },
      participants: json_array(json_field(item, "participants")).map(p => {
        json_string(p)
      }),
      shares,
      description: json_string(json_field(item, "description")),
      date: json_string(json_field(item, "date")),
    })
  }
  let ledger : Ledger = { people, payments, ambiguous, }
  validate(ledger)
  ledger
}

///|
pub fn encode_ledger(ledger : Ledger) -> String {
  let payments = ledger.payments.map(p => {
    let shares = p.shares.map(s => {
      "{\"person\":" +
      quote_json(s.person) +
      ",\"amount_cents\":" +
      s.amount_cents.to_string() +
      "}"
    })
    "{\"payer\":" +
    quote_json(p.payer) +
    ",\"amount_cents\":" +
    p.amount_cents.to_string() +
    ",\"split_mode\":" +
    quote_json(if p.split_mode == Equal { "equal" } else { "exact" }) +
    ",\"participants\":[" +
    p.participants.map(quote_json).join(",") +
    "],\"shares\":[" +
    shares.join(",") +
    "],\"description\":" +
    quote_json(p.description) +
    ",\"date\":" +
    quote_json(p.date) +
    "}"
  })
  "{\"schema_version\":1,\"people\":[" +
  ledger.people.map(quote_json).join(",") +
  "],\"payments\":[" +
  payments.join(",") +
  "],\"ambiguous\":[" +
  ledger.ambiguous.map(quote_json).join(",") +
  "]}"
}
