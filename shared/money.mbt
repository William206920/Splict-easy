///|
pub suberror BillError {
  Invalid(String)
} derive(@debug.Debug)

///|
pub fn invalid(message : String) -> Unit raise BillError {
  raise BillError::Invalid(message)
}

///|
pub fn parse_cents_integer(text : String) -> Int64 raise BillError {
  if text.is_empty() {
    invalid("金额不能为空")
  }
  let mut value = 0L
  for c in text.iter() {
    if c < '0' || c > '9' {
      invalid("整数分必须是非负十进制整数")
    }
    let digit = (c.to_int() - 48).to_int64()
    if value > (9223372036854775807L - digit) / 10L {
      invalid("金额超出 Int64 范围")
    }
    value = value * 10L + digit
  }
  value
}

///|
pub fn parse_money(text : String) -> Int64 raise BillError {
  let fields = text.split(".").to_array()
  if fields.length() > 2 || fields[0].is_empty() {
    invalid("金额格式错误")
  }
  let yuan = fields[0].to_owned()
  let fraction = if fields.length() == 1 {
    "00"
  } else {
    let f = fields[1].to_owned()
    if f.length() < 1 || f.length() > 2 {
      invalid("金额支持一至两位小数")
    }
    if f.length() == 1 {
      f + "0"
    } else {
      f
    }
  }
  parse_cents_integer(yuan + fraction)
}

///|
pub fn add_money(a : Int64, b : Int64) -> Int64 raise BillError {
  if a < 0L || b < 0L || a > 9223372036854775807L - b {
    invalid("金额合计溢出")
  }
  a + b
}

///|
pub fn money(value : Int64) -> String {
  let negative = value < 0L
  // Application balances cannot reach Int64::MIN; handle it for a total formatter.
  if value == -9223372036854775807L - 1L {
    return "-92233720368547758.08"
  }
  let n = if negative { -value } else { value }
  let tail = (n % 100L).to_string()
  (if negative { "-" } else { "" }) +
  (n / 100L).to_string() +
  "." +
  (if tail.length() == 1 { "0" + tail } else { tail })
}

///|
pub extend BillError with @debug.Debug::{to_repr}

///|
pub fn error_message(error : BillError) -> String {
  match error {
    Invalid(text) => text
  }
}
