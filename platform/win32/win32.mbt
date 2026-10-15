///|
extern "C" fn supported_ffi() -> Bool = "se_win_supported"

///|
#borrow(title)
extern "C" fn create_ffi(title : String, visible : Bool) -> Bool = "se_win_create"

///|
#borrow(text)
extern "C" fn add_ffi(
  kind : Int32,
  id : Int32,
  text : String,
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32,
) -> Bool = "se_win_add"

///|
#borrow(text)
extern "C" fn set_text_ffi(id : Int32, text : String) -> Bool = "se_win_set_text"

///|
extern "C" fn get_text_ffi(id : Int32) -> String = "se_win_get_text"

///|
extern "C" fn next_event_ffi() -> Int32 = "se_win_next_event"

///|
extern "C" fn post_click_ffi(id : Int32) -> Bool = "se_win_post_click"

///|
extern "C" fn close_ffi() -> Unit = "se_win_close"

///|
extern "C" fn exit_ffi(code : Int32) -> Unit = "se_process_exit"

///|
pub fn supported() -> Bool {
  supported_ffi()
}

///|
pub fn create(title : String, visible : Bool) -> Bool {
  create_ffi(title, visible)
}

///|
pub fn add_label(
  id : Int32,
  text : String,
  x : Int32,
  y : Int32,
  w : Int32,
  h : Int32,
) -> Bool {
  add_ffi(0, id, text, x, y, w, h)
}

///|
pub fn add_button(
  id : Int32,
  text : String,
  x : Int32,
  y : Int32,
  w : Int32,
  h : Int32,
) -> Bool {
  add_ffi(1, id, text, x, y, w, h)
}

///|
pub fn set_text(id : Int32, text : String) -> Bool {
  set_text_ffi(id, text)
}

///|
pub fn get_text(id : Int32) -> String {
  get_text_ffi(id)
}

///|
pub fn next_event() -> Int32 {
  next_event_ffi()
}

///|
pub fn post_click(id : Int32) -> Bool {
  post_click_ffi(id)
}

///|
pub fn close() -> Unit {
  close_ffi()
}

///|
pub fn exit(code : Int32) -> Unit {
  exit_ffi(code)
}
