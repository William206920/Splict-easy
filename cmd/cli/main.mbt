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
    @sys.stdout("SplitEasy Desktop 0.9.2\n")
    return
  }
  try {
    let config = @core.parse_args(args)
    let content = @sys.read_file(config.input)
    let output = if config.ai {
      run_ai(config, content)
    } else {
      @core.execute(config, content)
    }
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

///|
fn confirm(prompt : String) -> Bool {
  @sys.stderr(
    prompt + "\n请输入 yes 确认，其他输入或无输入取消：",
  )
  let answer = @sys.read_line()
  answer == "yes" || answer == "y" || answer == "是"
}

///|
fn run_ai(
  config : @core.Config,
  text : String,
) -> String raise @shared.BillError {
  let settings : @ai.Config = {
    base_url: @sys.environment("MOONBIT_BASE_URL"),
    api_key: @sys.environment("MOONBIT_API_KEY"),
    model: @sys.environment("MOONBIT_MODEL"),
  }
  let url = @ai.endpoint(settings)
  let body = @ai.request_body(settings, text)
  let flow = @ai.Flow::new()
  if !flow.send(
      confirm(
        "将把以下账单发送到 " +
        url +
        "，模型 " +
        settings.model +
        "：\n" +
        text,
      ),
    ) {
    @shared.invalid("已取消，未发送账单")
  }
  @http.start(url, settings.api_key, body)
  while @http.state() == 1 {
    @http.pause(50)
  }
  let ledger = flow.receive(@http.result())
  let result = flow.confirm(
    confirm(@ai.preview(ledger) + "\n确认按上述账单结算？"),
  )
  if config.json {
    @shared.render_report_json(result)
  } else {
    @shared.render_markdown(result)
  }
}
