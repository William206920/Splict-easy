///|
extern "C" fn gui_subsystem() -> Unit = "se_use_gui_subsystem"

///|
fn main {
  gui_subsystem()
  let args = @env.args()
  @app.run(
    demo=args.contains("--demo") ||
      args.contains("--demo-editor") ||
      args.contains("--demo-ai") ||
      args.contains("--demo-members") ||
      args.contains("--demo-import") ||
      args.contains("--demo-review"),
    demo_page=if args.contains("--demo-editor") {
      1
    } else if args.contains("--demo-ai") {
      3
    } else if args.contains("--demo-import") {
      2
    } else if args.contains("--demo-review") {
      4
    } else if args.contains("--demo-members") {
      5
    } else {
      0
    },
  )
}
