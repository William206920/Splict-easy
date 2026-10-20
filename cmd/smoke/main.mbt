///|
fn require(ok : Bool, message : String) -> Unit {
  if !ok {
    println("FAIL: " + message)
    @win32.close()
    @win32.exit(1)
  }
}

///|
fn main {
  require(@win32.supported(), "Windows required; no simulated GUI pass")
  require(
    @win32.create(@shared.app_title(), false),
    "create hidden native window",
  )
  require(
    @win32.add_label(1000, @shared.ready_message(), 24, 28, 690, 68),
    "create Unicode label",
  )
  require(
    @win32.add_button(1001, "验证共享核心", 24, 116, 220, 44),
    "create native button",
  )
  require(
    @win32.get_text(1000) == @shared.ready_message(),
    "Unicode initial roundtrip",
  )
  require(@win32.post_click(1001), "post button event")
  require(@win32.next_event() == 1001, "native event returns to MoonBit")
  require(
    @win32.set_text(1000, @shared.verified_message()),
    "MoonBit updates native text",
  )
  require(
    @win32.get_text(1000) == @shared.verified_message(),
    "Unicode updated roundtrip",
  )
  @win32.close()
  require(@win32.next_event() == 0, "window close exits message loop")
  @app.export_smoke() catch {
    e => {
      println(@shared.error_message(e))
      @win32.exit(1)
    }
  }
  @app.smoke() catch {
    e => {
      println(@shared.error_message(e))
      @win32.close()
      @win32.exit(1)
    }
  }
  let base = @sys.environment("SPLITEASY_AI_TEST_BASE_URL")
  if !base.is_empty() {
    @app.network_smoke(base) catch {
      e => {
        println(@shared.error_message(e))
        @win32.close()
        @win32.exit(1)
      }
    }
  }
  println("PASS: Win32 Unicode + MoonBit event + shared core + close")
}
