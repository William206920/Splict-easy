///|
pub(all) enum SplitMode {
  Equal
  Exact
} derive(Eq, @debug.Debug)

///|
pub(all) struct Share {
  person : String
  amount_cents : Int64
} derive(Eq, @debug.Debug)

///|
pub(all) struct Payment {
  payer : String
  amount_cents : Int64
  split_mode : SplitMode
  participants : Array[String]
  shares : Array[Share]
  description : String
  date : String
} derive(Eq, @debug.Debug)

///|
pub(all) struct Ledger {
  people : Array[String]
  payments : Array[Payment]
  ambiguous : Array[String]
} derive(Eq, @debug.Debug)

///|
pub(all) struct Transfer {
  from : String
  to : String
  amount_cents : Int64
} derive(Eq, @debug.Debug)

///|
pub fn valid_name(name : String) -> Bool {
  if name.is_empty() {
    return false
  }
  for c in name.iter() {
    if c.is_whitespace() ||
      c == ':' ||
      c == '：' ||
      c == '@' ||
      c == '!' ||
      c == '=' {
      return false
    }
  }
  true
}

///|
pub fn validate_date(date : String) -> Unit raise BillError {
  if date.is_empty() {
    return
  }
  let p = date.split("-").to_array()
  if p.length() != 3 {
    invalid("日期请使用 YYYY-MM-DD")
  }
  if p[0].length() != 4 || p[1].length() != 2 || p[2].length() != 2 {
    invalid("日期请使用 YYYY-MM-DD")
  }
  let y = parse_cents_integer(p[0].to_owned())
  let m = parse_cents_integer(p[1].to_owned())
  let d = parse_cents_integer(p[2].to_owned())
  if y < 1L || m < 1L || m > 12L {
    invalid("日期无效")
  }
  let days = if m == 2L {
    if y % 400L == 0L || (y % 4L == 0L && y % 100L != 0L) {
      29L
    } else {
      28L
    }
  } else if m == 4L || m == 6L || m == 9L || m == 11L {
    30L
  } else {
    31L
  }
  if d < 1L || d > days {
    invalid("日期无效")
  }
}

///|
pub fn validate_people(people : Array[String]) -> Unit raise BillError {
  if people.is_empty() {
    invalid("请先添加人员")
  }
  let seen : Array[String] = []
  for name in people {
    if !valid_name(name) {
      invalid("姓名不能为空、含空格或保留符号：" + name)
    }
    if seen.contains(name) {
      invalid("人员重复：" + name)
    }
    seen.push(name)
  }
}

///|
pub fn validate_payment(
  people : Array[String],
  p : Payment,
) -> Unit raise BillError {
  if !people.contains(p.payer) {
    invalid("未知付款人：" + p.payer)
  }
  if p.amount_cents <= 0L {
    invalid("消费总额必须大于零")
  }
  if p.description.trim().is_empty() {
    invalid("消费名称不能为空")
  }
  validate_date(p.date)
  let seen : Array[String] = []
  match p.split_mode {
    Equal => {
      if !p.shares.is_empty() || p.participants.is_empty() {
        invalid("平均模式须选择人员，且不能填写实际份额")
      }
      for name in p.participants {
        if !people.contains(name) {
          invalid("未知参与者：" + name)
        }
        if seen.contains(name) {
          invalid("参与者重复：" + name)
        }
        seen.push(name)
      }
    }
    Exact => {
      if !p.participants.is_empty() || p.shares.is_empty() {
        invalid("实际金额模式只填写个人份额")
      }
      let mut total = 0L
      for share in p.shares {
        if !people.contains(share.person) {
          invalid("未知份额人员：" + share.person)
        }
        if seen.contains(share.person) {
          invalid("份额人员重复：" + share.person)
        }
        seen.push(share.person)
        if share.amount_cents < 0L {
          invalid("个人份额不得为负数")
        }
        total = add_money(total, share.amount_cents)
      }
      if total != p.amount_cents {
        invalid("个人份额合计必须等于消费总额")
      }
    }
  }
}

///|
pub fn validate(ledger : Ledger) -> Unit raise BillError {
  validate_people(ledger.people)
  if !ledger.ambiguous.is_empty() {
    invalid("账单存在歧义：" + ledger.ambiguous.join("；"))
  }
  let mut total = 0L
  for p in ledger.payments {
    validate_payment(ledger.people, p)
    total = add_money(total, p.amount_cents)
  }
  ignore(total)
}

///|
pub extend SplitMode with Eq::{equal, not_equal}

///|
pub extend Share with Eq::{equal, not_equal}

///|
pub extend Payment with Eq::{equal, not_equal}

///|
pub extend Ledger with Eq::{equal, not_equal}

///|
pub extend Transfer with Eq::{equal, not_equal}

///|
pub extend SplitMode with @debug.Debug::{to_repr}

///|
pub extend Share with @debug.Debug::{to_repr}

///|
pub extend Payment with @debug.Debug::{to_repr}

///|
pub extend Ledger with @debug.Debug::{to_repr}

///|
pub extend Transfer with @debug.Debug::{to_repr}
