///|
/// Host bridge only: textContent treats the message as plain text.
extern "js" fn set_status(message : String) -> Unit =
  #| (message) => { document.getElementById("status").textContent = message; }
