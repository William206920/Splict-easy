///|
fn web_escape(text : String) -> String {
  let out = StringBuilder()
  for c in text.iter() {
    match c {
      '&' => out.write_string("&amp;")
      '<' => out.write_string("&lt;")
      '>' => out.write_string("&gt;")
      '"' => out.write_string("&quot;")
      '\'' => out.write_string("&#39;")
      _ => out.write_char(c)
    }
  }
  out.to_string()
}

///|
fn web_avatar(text : String) -> String {
  if text.is_empty() {
    return "·"
  }
  let first = text[0].to_int()
  let length = if first >= 0xd800 && first <= 0xdbff && text.length() > 1 {
    2
  } else {
    1
  }
  web_escape(text[:length].to_owned())
}

///|
fn web_empty_html(text : String, symbol : String) -> String {
  "<div class=\"empty\"><span class=\"empty-symbol\" aria-hidden=\"true\">" +
  web_escape(symbol) +
  "</span>" +
  web_escape(text) +
  "</div>"
}

///|
fn web_expenses(ledger : @shared.Ledger) -> String {
  if ledger.payments.is_empty() {
    return web_empty_html(
      "还没有消费，从记录第一笔开始。", "▤",
    )
  }
  let rows : Array[String] = []
  for i = 0; i < ledger.payments.length(); i = i + 1 {
    let p = ledger.payments[i]
    let description = web_escape(p.description)
    let split = if p.split_mode == @shared.Equal {
      p.participants.length().to_string() + " 人平摊"
    } else {
      "按实际金额"
    }
    let date = if p.date.is_empty() { "" } else { " · " + web_escape(p.date) }
    rows.push(
      "<div class=\"expense-row\"><span class=\"expense-avatar\">" +
      web_avatar(p.description) +
      "</span><div class=\"expense-detail\"><strong>" +
      description +
      "</strong><small>" +
      web_escape(p.payer) +
      " 付款 · " +
      split +
      date +
      "</small></div><span class=\"expense-amount\">¥ " +
      @shared.money(p.amount_cents) +
      "</span><div class=\"row-actions\"><button data-edit=\"" +
      i.to_string() +
      "\" aria-label=\"编辑" +
      description +
      "\">编辑</button><button data-delete=\"" +
      i.to_string() +
      "\" aria-label=\"删除" +
      description +
      "\">删除</button></div></div>",
    )
  }
  rows.join("")
}

///|
fn web_member_count(ledger : @shared.Ledger, name : String) -> Int32 {
  ledger.payments
  .filter(p => {
    p.payer == name ||
    p.participants.contains(name) ||
    p.shares.any(s => s.person == name)
  })
  .length()
}

///|
fn web_members(ledger : @shared.Ledger) -> String {
  if ledger.people.is_empty() {
    return web_empty_html(
      "还没有成员，添加一起记账的人吧。", "♧",
    )
  }
  let rows : Array[String] = []
  for i = 0; i < ledger.people.length(); i = i + 1 {
    let name = ledger.people[i]
    rows.push(
      "<div class=\"member-card\"><span class=\"avatar\">" +
      web_avatar(name) +
      "</span><div class=\"info\"><strong>" +
      web_escape(name) +
      "</strong><p>关联 " +
      web_member_count(ledger, name).to_string() +
      " 笔消费</p><div class=\"row-actions\"><button data-rename=\"" +
      i.to_string() +
      "\">改名</button><button data-remove=\"" +
      i.to_string() +
      "\">删除</button></div></div></div>",
    )
  }
  rows.join("")
}

///|
fn web_transfers(report : @shared.Report?) -> String {
  match report {
    None =>
      web_empty_html(
        "添加消费后，这里会告诉你怎么转账。", "⇄",
      )
    Some(report) => {
      if report.transfers.is_empty() {
        return web_empty_html("大家已经平衡，无需转账。", "⇄")
      }
      report.transfers
      .map(t => {
        "<div class=\"transfer\"><span>" +
        web_escape(t.from) +
        "</span><span class=\"arrow\">→</span><span>" +
        web_escape(t.to) +
        "</span><strong>¥ " +
        @shared.money(t.amount_cents) +
        "</strong></div>"
      })
      .join("")
    }
  }
}

///|
fn web_balances(report : @shared.Report?) -> String {
  match report {
    None =>
      "<tr><td colspan=\"4\"><div class=\"empty\">记录消费后，查看每个人的付款与份额。</div></td></tr>"
    Some(report) =>
      report.balances
      .map(b => {
        let negative = b.balance_cents < 0L
        let balance = @shared.money(b.balance_cents)
        let label = if negative {
          "应付 " + balance[1:].to_owned()
        } else if b.balance_cents == 0L {
          "已平衡"
        } else {
          "应收 " + balance
        }
        "<tr><td>" +
        web_escape(b.person) +
        "</td><td>¥ " +
        @shared.money(b.paid_cents) +
        "</td><td>¥ " +
        @shared.money(b.due_cents) +
        "</td><td class=\"" +
        (if negative { "negative" } else { "positive" }) +
        "\">" +
        label +
        "</td></tr>"
      })
      .join("")
  }
}

///|
priv struct WebPresentation {
  total : String
  expenses : String
  members : String
  transfers : String
  balances : String
  text : String
  markdown : String
}

///|
fn web_present(
  ledger : @shared.Ledger,
) -> WebPresentation raise @shared.BillError {
  let report = if ledger.payments.is_empty() {
    None
  } else {
    Some(@shared.settle(ledger))
  }
  {
    total: match report {
      Some(r) => @shared.money(r.total_cents)
      None => "0.00"
    },
    expenses: web_expenses(ledger),
    members: web_members(ledger),
    transfers: web_transfers(report),
    balances: web_balances(report),
    text: match report {
      Some(r) => @shared.render_text(r)
      None => "尚无消费，添加后即可结算。"
    },
    markdown: match report {
      Some(r) => @shared.render_markdown(r)
      None => ""
    },
  }
}

///|
fn web_options(people : Array[String]) -> String {
  people.map(name => "<option>" + web_escape(name) + "</option>").join("")
}

///|
fn web_participants(
  ledger : @shared.Ledger,
  payment : @shared.Payment?,
) -> String {
  let rows : Array[String] = []
  for i = 0; i < ledger.people.length(); i = i + 1 {
    let name = ledger.people[i]
    let selected = match payment {
      None => true
      Some(p) =>
        p.participants.contains(name) || p.shares.any(s => s.person == name)
    }
    let amount = match payment {
      None => ""
      Some(p) =>
        match p.shares.iter().find_first(s => s.person == name) {
          Some(s) => @shared.money(s.amount_cents)
          None => ""
        }
    }
    let index = i.to_string()
    let escaped = web_escape(name)
    rows.push(
      "<label class=\"participant\" for=\"participant-" +
      index +
      "\"><input id=\"participant-" +
      index +
      "\" type=\"checkbox\" data-person=\"" +
      escaped +
      "\" " +
      (if selected { "checked" } else { "" }) +
      "><span>" +
      escaped +
      "</span><input class=\"share-input\" data-share=\"" +
      index +
      "\" aria-label=\"" +
      escaped +
      "的实际份额（元）\" inputmode=\"decimal\" placeholder=\"金额（元）\" value=\"" +
      amount +
      "\"></label>",
    )
  }
  rows.join("")
}

///|
fn web_payment_payload(
  index : Int32,
  payer : String,
  amount : String,
  description : String,
  date : String,
  mode : String,
  selected : String,
) -> String raise @shared.BillError {
  let selection = web_json(selected)
  let participants = strings(selection, "participants")
  let amounts = strings(selection, "amounts")
  "{\"index\":" +
  @shared.quote_json(index.to_string()) +
  ",\"payer\":" +
  @shared.quote_json(payer) +
  ",\"amount\":" +
  @shared.quote_json(amount.trim().to_owned()) +
  ",\"description\":" +
  @shared.quote_json(description.trim().to_owned()) +
  ",\"date\":" +
  @shared.quote_json(date) +
  ",\"mode\":" +
  @shared.quote_json(mode) +
  ",\"participants\":" +
  array(participants) +
  ",\"amounts\":" +
  array(amounts.map(s => s.trim().to_owned())) +
  "}"
}
