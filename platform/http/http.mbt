///|
#borrow(url, key, body)
extern "C" fn start_ffi(url : Bytes, key : Bytes, body : Bytes) -> Bool = "se_http_start"

///|
pub extern "C" fn state() -> Int32 = "se_http_state"

///|
pub extern "C" fn cancel() -> Unit = "se_http_cancel"

///|
pub extern "C" fn pause(milliseconds : Int32) -> Unit = "se_http_pause"

///|
extern "C" fn result_ffi() -> Bytes = "se_http_result"

///|
pub fn start(
  url : String,
  key : String,
  body : String,
) -> Unit raise @shared.BillError {
  if !start_ffi(@utf8.encode(url), @utf8.encode(key), @utf8.encode(body)) {
    @shared.invalid(
      "无法启动 AI 请求：前一请求可能仍在结束，或当前平台不支持",
    )
  }
}

///|
pub fn result() -> String raise @shared.BillError {
  let status = state()
  if status < 2 {
    @shared.invalid("AI 请求尚未结束")
  }
  let text = @utf8.decode(result_ffi()) catch {
    _ => {
      @shared.invalid("模型响应不是有效 UTF-8")
      ""
    }
  }
  if status != 2 {
    @shared.invalid("AI 请求失败：" + text)
  }
  text
}
