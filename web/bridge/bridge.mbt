///|
fn field(value : Json, name : String) -> String raise @shared.BillError {
  match value {
    Object(fields) =>
      match fields.get(name) {
        Some(String(text)) => text
        _ => {
          @shared.invalid("缺少字段：" + name)
          ""
        }
      }
    _ => {
      @shared.invalid("请求格式错误")
      ""
    }
  }
}

///|
fn strings(
  value : Json,
  name : String,
) -> Array[String] raise @shared.BillError {
  match value {
    Object(fields) =>
      match fields.get(name) {
        Some(Array(values)) =>
          values.map(v => {
            match v {
              String(s) => s
              _ => {
                @shared.invalid("名单格式错误")
                ""
              }
            }
          })
        _ => {
          @shared.invalid("缺少名单：" + name)
          []
        }
      }
    _ => {
      @shared.invalid("请求格式错误")
      []
    }
  }
}

///|
fn array(values : Array[String]) -> String {
  "[" + values.map(@shared.quote_json).join(",") + "]"
}

///|
fn error_result(error : @shared.BillError) -> String {
  "{\"ok\":false,\"error\":" +
  @shared.quote_json(@shared.error_message(error)) +
  "}"
}

///|
fn payment_index(text : String) -> Int32 raise @shared.BillError {
  let index = @shared.parse_cents_integer(text)
  if index > 5000L {
    @shared.invalid("消费索引无效")
  }
  index.to_int()
}

///|
fn view(ledger : @shared.Ledger) -> String raise @shared.BillError {
  let payments = ledger.payments.map(p => {
    let shares = p.shares.map(s => {
      "{\"person\":" +
      @shared.quote_json(s.person) +
      ",\"amount\":" +
      @shared.quote_json(@shared.money(s.amount_cents)) +
      "}"
    })
    "{\"payer\":" +
    @shared.quote_json(p.payer) +
    ",\"amount\":" +
    @shared.quote_json(@shared.money(p.amount_cents)) +
    ",\"mode\":" +
    @shared.quote_json(
      if p.split_mode == @shared.Equal {
        "equal"
      } else {
        "exact"
      },
    ) +
    ",\"description\":" +
    @shared.quote_json(p.description) +
    ",\"date\":" +
    @shared.quote_json(p.date) +
    ",\"participants\":" +
    array(p.participants) +
    ",\"shares\":[" +
    shares.join(",") +
    "]}"
  })
  let mut total = "0.00"
  let mut balances = "[]"
  let mut transfers = "[]"
  let mut text = "尚无消费，添加后即可结算。"
  let mut markdown = ""
  if !ledger.payments.is_empty() {
    let report = @shared.settle(ledger)
    total = @shared.money(report.total_cents)
    balances = "[" +
      report.balances
      .map(b => {
        "{\"person\":" +
        @shared.quote_json(b.person) +
        ",\"paid\":" +
        @shared.quote_json(@shared.money(b.paid_cents)) +
        ",\"due\":" +
        @shared.quote_json(@shared.money(b.due_cents)) +
        ",\"balance\":" +
        @shared.quote_json(@shared.money(b.balance_cents)) +
        "}"
      })
      .join(",") +
      "]"
    transfers = "[" +
      report.transfers
      .map(t => {
        "{\"from\":" +
        @shared.quote_json(t.from) +
        ",\"to\":" +
        @shared.quote_json(t.to) +
        ",\"amount\":" +
        @shared.quote_json(@shared.money(t.amount_cents)) +
        "}"
      })
      .join(",") +
      "]"
    text = @shared.render_text(report)
    markdown = @shared.render_markdown(report)
  }
  "{\"ok\":true,\"ledger\":" +
  @shared.quote_json(@shared.encode_ledger(ledger)) +
  ",\"people\":" +
  array(ledger.people) +
  ",\"payments\":[" +
  payments.join(",") +
  "],\"total\":" +
  @shared.quote_json(total) +
  ",\"balances\":" +
  balances +
  ",\"transfers\":" +
  transfers +
  ",\"text\":" +
  @shared.quote_json(text) +
  ",\"markdown\":" +
  @shared.quote_json(markdown) +
  "}"
}

///|
fn run(
  action : String,
  source : String,
  data : String,
) -> String raise @shared.BillError {
  if source.length() > 2000000 || data.length() > 2000000 {
    @shared.invalid("账单内容过长，请拆分导入")
  }
  let payload = @json.parse(data) catch {
    _ => {
      @shared.invalid("操作参数无效")
      Json::null()
    }
  }
  let session = @shared.Session::new()
  session.replace(@shared.decode_ledger(source, allow_empty=true))
  match action {
    "view" => ()
    "import" => {
      let input = field(payload, "text").trim().to_owned()
      if input.has_prefix("{") || input.has_prefix("\u{FEFF}") {
        session.replace(@shared.decode_ledger(input, allow_empty=true))
      } else {
        session.replace(@shared.parse_text(input))
      }
    }
    "add_person" => session.add_person(field(payload, "name"))
    "rename" => session.rename(field(payload, "old"), field(payload, "name"))
    "remove_person" => session.remove_person(field(payload, "name"))
    "remove_payment" =>
      session.remove_payment(payment_index(field(payload, "index")))
    "put_payment" => {
      let mode = field(payload, "mode")
      if mode != "equal" && mode != "exact" {
        @shared.invalid("分摊方式无效")
      }
      let participants = strings(payload, "participants")
      let amounts = strings(payload, "amounts")
      let shares : Array[@shared.Share] = []
      if mode == "exact" {
        if participants.length() != amounts.length() {
          @shared.invalid("份额数量不匹配")
        }
        for i = 0; i < participants.length(); i = i + 1 {
          shares.push({
            person: participants[i],
            amount_cents: @shared.parse_money(amounts[i]),
          })
        }
      }
      let index = field(payload, "index")
      session.put_payment(
        if index == "-1" {
          -1
        } else {
          payment_index(index)
        },
        {
          payer: field(payload, "payer"),
          amount_cents: @shared.parse_money(field(payload, "amount")),
          description: field(payload, "description"),
          date: field(payload, "date"),
          split_mode: if mode == "equal" {
            @shared.Equal
          } else {
            @shared.Exact
          },
          participants: if mode == "equal" {
            participants
          } else {
            []
          },
          shares,
        },
      )
    }
    _ => @shared.invalid("未知操作")
  }
  view(session.ledger)
}

///|
pub fn execute(action : String, source : String, data : String) -> String {
  run(action, source, data) catch {
    error => error_result(error)
  }
}

///|
pub fn model_request(model : String, text : String) -> String {
  @ai.request_body(
    { base_url: "https://server.invalid/v1", api_key: "server-only", model, },
    text,
  ) catch {
    error => error_result(error)
  }
}

///|
pub fn model_response(response : String) -> String {
  try {
    let ledger = @ai.parse_response(response)
    let session = @shared.Session::new()
    session.replace(ledger)
    "{\"ok\":true,\"ledger\":" +
    @shared.quote_json(@shared.encode_ledger(ledger)) +
    ",\"preview\":" +
    @shared.quote_json(@ai.preview(ledger)) +
    "}"
  } catch {
    error => error_result(error)
  }
}
