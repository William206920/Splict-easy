///|
/// Unicode whitespace tokenizer; optionally make reserved mode markers tokens.
fn text_tokens(input : String, markers : Bool) -> Array[String] {
  let tokens : Array[String] = []
  let word = StringBuilder()
  for ch in input.iter() {
    let marker = markers && (ch == '@' || ch == '!' || ch == '=')
    if ch.is_whitespace() || marker {
      if !word.is_empty() {
        tokens.push(word.to_string())
        word.reset()
      }
      if marker {
        let symbol = StringBuilder()
        symbol.write_char(ch)
        tokens.push(symbol.to_string())
      }
    } else {
      word.write_char(ch)
    }
  }
  if !word.is_empty() {
    tokens.push(word.to_string())
  }
  tokens
}

///|
fn people_header_body(line : String) -> String? {
  let prefix = StringBuilder()
  let body = StringBuilder()
  let mut separator_seen = false
  for ch in line.iter() {
    if !separator_seen && (ch == ':' || ch == '：') {
      separator_seen = true
    } else if separator_seen {
      body.write_char(ch)
    } else {
      prefix.write_char(ch)
    }
  }
  let words = text_tokens(prefix.to_string(), false)
  if separator_seen && words.length() == 1 && words[0] == "人" {
    Some(body.to_string())
  } else {
    None
  }
}

///|
fn description_from_tokens(tokens : Array[String], end : Int32) -> String {
  let result = StringBuilder()
  for i in 2..<end {
    if i > 2 {
      result.write_char(' ')
    }
    result.write_string(tokens[i])
  }
  result.to_string()
}

///|
fn parse_text_payment(
  people : Array[String],
  line : String,
) -> Result[Payment, String] {
  let tokens = text_tokens(line, true)
  let mut marker_index = -1
  for i, token in tokens {
    if token == "@" || token == "!" || token == "=" {
      if marker_index >= 0 {
        return Err(
          "每笔消费只能使用一次 @、! 或 = 标记，不得混用",
        )
      }
      marker_index = i
    }
  }
  let end = if marker_index < 0 { tokens.length() } else { marker_index }
  if end < 3 {
    return Err(
      "消费格式应为：付款人 金额 消费说明 [分摊标记]",
    )
  }
  let amount = match parse_money(tokens[1]) {
    Ok(value) => value
    Err(message) => return Err("消费金额：" + message)
  }
  let participants : Array[String] = []
  let shares : Array[Share] = []
  let mut mode = Equal
  if marker_index < 0 {
    for person in people {
      participants.push(person)
    }
  } else {
    if marker_index + 1 == tokens.length() {
      return Err("分摊标记后不能为空")
    }
    match tokens[marker_index] {
      "@" =>
        for i in (marker_index + 1)..<tokens.length() {
          participants.push(tokens[i])
        }
      "!" => {
        let excluded : Array[String] = []
        for i in (marker_index + 1)..<tokens.length() {
          let name = tokens[i]
          if !has_person(people, name) {
            return Err("未知排除人员：" + name)
          }
          if has_person(excluded, name) {
            return Err("排除人员重复：" + name)
          }
          excluded.push(name)
        }
        for person in people {
          if !has_person(excluded, person) {
            participants.push(person)
          }
        }
      }
      "=" => {
        mode = Exact
        for i in (marker_index + 1)..<tokens.length() {
          let (name_view, amount_view) = match tokens[i].split_once(":") {
            Some(value) => value
            None =>
              return Err(
                "实际金额格式应为 姓名:金额，使用英文冒号",
              )
          }
          let name = name_view.to_owned()
          if name.is_empty() {
            return Err("实际金额份额的姓名不能为空")
          }
          let share_amount = match parse_money(amount_view.to_owned()) {
            Ok(value) => value
            Err(message) =>
              return Err("人员“" + name + "”的分摊金额：" + message)
          }
          shares.push({ person: name, amount_cents: share_amount, })
        }
      }
      _ => return Err("无法识别分摊标记")
    }
  }
  let payment : Payment = {
    payer: tokens[0],
    amount_cents: amount,
    split_mode: mode,
    participants,
    shares,
    description: description_from_tokens(tokens, end),
    date: "",
  }
  match validate_payment_data(people, payment) {
    Ok(_) => Ok(payment)
    Err(message) => Err(message)
  }
}

///|
/// Parse an entire document or fail with its original 1-based physical line.
/// LF/CRLF/CR and an initial UTF-8 BOM are accepted. Blank lines are ignored.
/// No guessing, comments, quoting, escaped markers, dates, or network IO.
pub fn parse_text(input : String) -> Result[Ledger, String] {
  let text = match input.strip_prefix("\u{FEFF}") {
    Some(value) => value.to_owned()
    None => input
  }
  let normalized = text
    .replace_all(old="\r\n", new="\n")
    .replace_all(old="\r", new="\n")
  let people : Array[String] = []
  let payments : Array[Payment] = []
  let mut header_seen = false
  let mut total = 0L
  let mut line_number = 0
  for raw_line in normalized.split("\n") {
    line_number = line_number + 1
    let line = raw_line.to_owned()
    if text_tokens(line, false).is_empty() {
      continue
    }
    let prefix = "第 \{line_number} 行："
    match people_header_body(line) {
      Some(body) => {
        if header_seen {
          return Err(
            prefix +
            "人员名单只能声明一次，且必须位于消费之前",
          )
        }
        for name in text_tokens(body, false) {
          for ch in name.iter() {
            if ch == '@' || ch == '!' || ch == '=' || ch == ':' || ch == '：' {
              return Err(
                prefix + "文本模式姓名不能包含 @、!、= 或冒号",
              )
            }
          }
          people.push(name)
        }
        match validate_ledger({ people, payments: [], ambiguous: [], }) {
          Ok(_) => ()
          Err(message) => return Err(prefix + message)
        }
        header_seen = true
      }
      None => {
        if !header_seen {
          return Err(
            prefix +
            "首个非空行必须声明人员，例如：人：小明 小红",
          )
        }
        let payment = match parse_text_payment(people, line) {
          Ok(value) => value
          Err(message) => return Err(prefix + message)
        }
        total = match checked_add_cents(total, payment.amount_cents) {
          Ok(value) => value
          Err(message) => return Err(prefix + message)
        }
        payments.push(payment)
      }
    }
  }
  if !header_seen {
    return Err("第 1 行：缺少人员名单")
  }
  let ledger : Ledger = { people, payments, ambiguous: [], }
  match validate_ledger(ledger) {
    Ok(_) => Ok(ledger)
    Err(message) => Err("第 \{line_number} 行：" + message)
  }
}
