///|
extern "C" fn pid() -> Int32 = "se_io_pid"

///|
test "UTF8 atomic file roundtrip and failed save preserves existing data" {
  let temp = temp_directory()
  let path = temp + "/spliteasy-测试-" + pid().to_string() + ".json"
  let original = @shared.encode_ledger(@shared.sample_mixed())
  write_file(path, original)
  assert_eq(read_file(path), original)
  let blocked = try {
    write_file(path + "/missing", "bad")
    false
  } catch {
    _ => true
  }
  assert_true(blocked)
  assert_eq(read_file(path), original)
  write_file(path, "中文 😀\n第二行")
  assert_eq(read_file(path), "中文 😀\n第二行")
  assert_true(remove_file(path))
}
