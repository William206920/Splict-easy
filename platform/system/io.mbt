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
