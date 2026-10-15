///|
test "native newline normalization preserves every line and is idempotent" {
  let expected = "a\r\nb\r\nc\r\nd"
  assert_eq(crlf("a\nb\nc\r\nd"), expected)
  assert_eq(crlf(expected), expected)
}
