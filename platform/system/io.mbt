///|
#borrow(path)
extern "C" fn read_ffi(path : Bytes) -> Bytes = "se_io_read"

///|
#borrow(path, data)
extern "C" fn write_ffi(path : Bytes, data : Bytes) -> Bool = "se_io_write_atomic"

///|
#borrow(path)
extern "C" fn remove_ffi(path : Bytes) -> Bool = "se_io_remove"

///|
extern "C" fn error_ffi() -> Bool = "se_io_failed"

///|
pub fn read_file(path : String) -> String raise @shared.BillError {
  let bytes = read_ffi(@utf8.encode(path))
  if error_ffi() {
    @shared.invalid("无法读取文件：" + path)
  }
  @utf8.decode(bytes) catch {
    _ => {
      @shared.invalid("文件不是有效 UTF-8：" + path)
      ""
    }
  }
}

///|
pub fn write_file(path : String, text : String) -> Unit raise @shared.BillError {
  if !write_ffi(@utf8.encode(path), @utf8.encode(text)) {
    @shared.invalid("文件保存失败，原文件未替换：" + path)
  }
}

///|
pub fn remove_file(path : String) -> Bool {
  remove_ffi(@utf8.encode(path))
}

///|
#borrow(path)
extern "C" fn exists_ffi(path : Bytes) -> Bool = "se_io_exists"

///|
pub fn exists(path : String) -> Bool {
  exists_ffi(@utf8.encode(path))
}

///|
pub fn temp_directory() -> String {
  match @env.get_env_var("TEMP") {
    Some(p) => p
    None => "/tmp"
  }
}

///|
#borrow(data)
extern "C" fn output_ffi(data : Bytes, error : Bool) -> Unit = "se_console_output"

///|
pub extern "C" fn exit(code : Int32) -> Unit = "se_sys_exit"

///|
pub fn stdout(text : String) -> Unit {
  output_ffi(@utf8.encode(text), false)
}

///|
pub fn stderr(text : String) -> Unit {
  output_ffi(@utf8.encode(text), true)
}

///|
pub fn environment(name : String) -> String {
  match @env.get_env_var(name) {
    Some(value) => value
    None => ""
  }
}

///|
extern "C" fn line_ffi() -> Bytes = "se_console_line"

///|
pub fn read_line() -> String {
  @utf8.decode_lossy(line_ffi()).trim().to_owned()
}
