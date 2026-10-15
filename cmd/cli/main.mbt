///|
fn main {
  let raw = @env.args()
  let args : Array[String] = []
  for i = 1; i < raw.length(); i = i + 1 {
    args.push(raw[i])
  }
  if args == ["--help"] || args == ["-h"] {
    @sys.stdout(@core.usage())
    return
  }
  if args == ["--version"] {
    @sys.stdout("SplitEasy Desktop 0.7.0\n")
    return
  }
  try {
    let config = @core.parse_args(args)
    let content = @sys.read_file(config.input)
    let output = @core.execute(config, content)
    if config.output.is_empty() {
      @sys.stdout(output)
    } else {
      @sys.write_file(config.output, output)
    }
  } catch {
    error => {
      @sys.stderr(@shared.error_message(error) + "\n")
      @sys.exit(2)
    }
  }
}
