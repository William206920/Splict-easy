///|
#borrow(text)
extern "C" fn control_ffi(
  kind : Int32,
  id : Int32,
  text : String,
  x : Int32,
  y : Int32,
  w : Int32,
  h : Int32,
) -> Bool = "se_win_add_control"

///|
pub extern "C" fn clear() -> Unit = "se_win_clear"

///|
pub extern "C" fn width() -> Int32 = "se_win_width"

///|
pub extern "C" fn content(height : Int32) -> Unit = "se_win_content"

///|
pub extern "C" fn flag(id : Int32, op : Int32, value : Int32) -> Int32 = "se_win_flag"

///|
#borrow(text)
extern "C" fn list_add_ffi(id : Int32, text : String) -> Int32 = "se_win_list_add"

///|
#borrow(text)
extern "C" fn message_ffi(text : String, kind : Int32) -> Int32 = "se_win_message"

///|
pub extern "C" fn file_dialog(save : Bool) -> String = "se_win_file_dialog"

///|
pub extern "C" fn draft_path() -> String = "se_win_draft_path"

///|
#borrow(text)
extern "C" fn clipboard_ffi(text : String) -> Bool = "se_win_clipboard"

///|
pub fn control(
  kind : Int32,
  id : Int32,
  text : String,
  x : Int32,
  y : Int32,
  w : Int32,
  h : Int32,
) -> Unit {
  if !control_ffi(kind, id, text, x, y, w, h) {
    message_ffi("无法创建系统控件", 0) |> ignore
  }
}

///|
pub fn list_add(id : Int32, text : String) -> Unit {
  ignore(list_add_ffi(id, text))
}

///|
pub fn notify(text : String) -> Unit {
  ignore(message_ffi(text, 0))
}

///|
pub fn ask(text : String) -> Int32 {
  message_ffi(text, 1)
}

///|
pub fn clipboard(text : String) -> Bool {
  clipboard_ffi(text)
}

///|
pub extern "C" fn timer(enabled : Bool) -> Unit = "se_win_timer"
