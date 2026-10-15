///|
test "CLI valid configs and input mutual exclusion" {
  let c = parse_args(["split", "-d", "ledger.json", "--json", "-o", "out.json"])
  assert_true(c.data && c.json && c.output == "out.json")
  for
    args in [
      ["split"],
      ["split", "-f"],
      ["split", "-f", "a", "-d", "b"],
      ["check", "-f", "a", "--ai"],
      ["split", "-d", "a", "--ai"],
      ["split", "-f", "a", "--bad"],
      ["check", "-f", "a", "--json"],
    ] {
    let failed = try {
      ignore(parse_args(args))
      false
    } catch {
      _ => true
    }
    assert_true(failed)
  }
  let result = execute(
    parse_args(["split", "-f", "x", "--json"]),
    "人：A B\nA 1 x",
  )
  assert_true(result.contains("\"amount_cents\":50"))
}
