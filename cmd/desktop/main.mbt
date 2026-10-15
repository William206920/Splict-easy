///|
extern "C" fn gui_subsystem() -> Unit = "se_use_gui_subsystem"

///|
fn main {
  gui_subsystem()
  if !@win32.supported() {
    println(
      "此原生界面仅支持 Windows，当前系统不能运行窗口。",
    )
    @win32.exit(1)
  }
  if !@win32.create(@shared.app_title(), true) {
    @win32.exit(1)
  }
  let label_ok = @win32.add_label(
    1000,
    @shared.ready_message(),
    24,
    28,
    690,
    68,
  )
  let button_ok = @win32.add_button(
    1001, "验证共享核心", 24, 116, 220, 44,
  )
  if !label_ok || !button_ok {
    @win32.close()
    @win32.exit(1)
  }
  let mut running = true
  while running {
    let event = @win32.next_event()
    if event == 0 {
      running = false
    } else if event < 0 {
      @win32.close()
      @win32.exit(1)
    } else if event == 1001 {
      if !@win32.set_text(1000, @shared.verified_message()) {
        @win32.close()
        @win32.exit(1)
      }
    }
  }
}
