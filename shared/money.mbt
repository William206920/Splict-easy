///|
/// Accept ASCII digits with an optional decimal point and 1-2 fractional digits.
/// Zero is valid here (e.g. an exact share); payments separately require > 0.
/// No signs, whitespace, separators, exponent notation, or floating point.
pub fn parse_money(input : String) -> Result[Int64, String] {
  if input.is_empty() {
    return Err("金额不能为空")
  }
  let mut value = 0L
  let mut decimal = false
  let mut integer_digits = 0
  let mut fraction_digits = 0
  for ch in input.iter() {
    if ch == '.' {
      if decimal || integer_digits == 0 {
        return Err("金额格式错误：请输入整数或最多两位小数")
      }
      decimal = true
    } else if ch >= '0' && ch <= '9' {
      if decimal {
        fraction_digits = fraction_digits + 1
        if fraction_digits > 2 {
          return Err("金额最多支持两位小数")
        }
      } else {
        integer_digits = integer_digits + 1
      }
      let digit = (ch.to_int() - 48).to_int64()
      if value > (9223372036854775807L - digit) / 10L {
        return Err("金额超出 Int64 整数分范围")
      }
      value = value * 10L + digit
    } else {
      return Err("金额格式错误：仅支持非负数字和小数点")
    }
  }
  if decimal && fraction_digits == 0 {
    return Err("小数点后必须有一到两位数字")
  }
  let scale = if fraction_digits == 0 {
    100L
  } else if fraction_digits == 1 {
    10L
  } else {
    1L
  }
  if value > 9223372036854775807L / scale {
    return Err("金额超出 Int64 整数分范围")
  }
  Ok(value * scale)
}

///|
/// For nonnegative cent amounts only. Check before addition, never after wraparound.
pub fn checked_add_cents(a : Int64, b : Int64) -> Result[Int64, String] {
  if a < 0L || b < 0L {
    return Err("金额相加时不能包含负数")
  }
  if a > 9223372036854775807L - b {
    return Err("金额合计超出 Int64 整数分范围")
  }
  Ok(a + b)
}
