///|
priv enum RawJson {
  Str(String)
  Num(String)
  Arr(Array[RawJson])
  Obj(Map[String, RawJson])
}

///|
priv struct JsonCursor {
  chars : Array[Char]
  mut pos : Int32
}

///|
fn JsonCursor::skip(self : JsonCursor) -> Unit {
  while self.pos < self.chars.length() &&
        (
          self.chars[self.pos] == ' ' ||
          self.chars[self.pos] == '\n' ||
          self.chars[self.pos] == '\r' ||
          self.chars[self.pos] == '\t'
        ) {
    self.pos = self.pos + 1
  }
}

///|
fn JsonCursor::expect(self : JsonCursor, wanted : Char) -> Unit raise BillError {
  self.skip()
  if self.pos >= self.chars.length() || self.chars[self.pos] != wanted {
    invalid("JSON 语法错误")
  }
  self.pos = self.pos + 1
}

///|
fn JsonCursor::string(self : JsonCursor) -> String raise BillError {
  self.expect('"')
  let mut source = "\""
  let mut escaped = false
  while self.pos < self.chars.length() {
    let c = self.chars[self.pos]
    self.pos = self.pos + 1
    source = source + c.to_string()
    if c == '"' && !escaped {
      let parsed = @json.parse(source) catch {
        _ => {
          invalid("JSON 字符串转义错误")
          Json::string("")
        }
      }
      return match parsed {
        String(s) => s
        _ => ""
      }
    }
    if c == '\\' && !escaped {
      escaped = true
    } else {
      escaped = false
    }
  }
  invalid("JSON 字符串未结束")
  ""
}

///|
fn JsonCursor::value(
  self : JsonCursor,
  depth : Int32,
) -> RawJson raise BillError {
  if depth > 64 {
    invalid("JSON 嵌套过深")
  }
  self.skip()
  if self.pos >= self.chars.length() {
    invalid("JSON 意外结束")
  }
  let c = self.chars[self.pos]
  if c == '"' {
    return Str(self.string())
  }
  if c >= '0' && c <= '9' {
    let mut digits = ""
    while self.pos < self.chars.length() &&
          self.chars[self.pos] >= '0' &&
          self.chars[self.pos] <= '9' {
      digits = digits + self.chars[self.pos].to_string()
      self.pos = self.pos + 1
    }
    if digits.length() > 1 && digits.has_prefix("0") {
      invalid("JSON 数字不能有多余前导零")
    }
    return Num(digits)
  }
  if c == '[' {
    self.pos = self.pos + 1
    let items : Array[RawJson] = []
    self.skip()
    if self.pos < self.chars.length() && self.chars[self.pos] == ']' {
      self.pos = self.pos + 1
      return Arr(items)
    }
    while true {
      items.push(self.value(depth + 1))
      self.skip()
      if self.pos < self.chars.length() && self.chars[self.pos] == ']' {
        self.pos = self.pos + 1
        break
      }
      self.expect(',')
    }
    return Arr(items)
  }
  if c == '{' {
    self.pos = self.pos + 1
    let fields : Map[String, RawJson] = Map([])
    self.skip()
    if self.pos < self.chars.length() && self.chars[self.pos] == '}' {
      self.pos = self.pos + 1
      return Obj(fields)
    }
    while true {
      let key = self.string()
      if fields.contains(key) {
        invalid("JSON 字段重复：" + key)
      }
      self.expect(':')
      fields[key] = self.value(depth + 1)
      self.skip()
      if self.pos < self.chars.length() && self.chars[self.pos] == '}' {
        self.pos = self.pos + 1
        break
      }
      self.expect(',')
    }
    return Obj(fields)
  }
  invalid(
    "JSON 账单仅接受对象、数组、字符串和非负整数；不接受小数或指数金额",
  )
  Str("")
}

///|
fn parse_raw_json(text : String) -> RawJson raise BillError {
  if text.length() > 2000000 {
    invalid("账单文件超过 2MB 字符限制")
  }
  let cursor : JsonCursor = { chars: text.iter().to_array(), pos: 0, }
  let value = cursor.value(0)
  cursor.skip()
  if cursor.pos != cursor.chars.length() {
    invalid("JSON 尾部有多余内容")
  }
  value
}
