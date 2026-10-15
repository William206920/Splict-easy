///|
extern "C" fn gui_subsystem() -> Unit = "se_use_gui_subsystem"

///|
fn main {
  gui_subsystem()
  @app.run(demo=@env.args().contains("--demo"))
}
