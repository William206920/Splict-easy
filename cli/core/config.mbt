///|
pub(all) struct Config {
  command : String
  input : String
  data : Bool
  json : Bool
  output : String
  ai : Bool
}

///|
pub fn usage() -> String {
  "SplitEasy\n  check -f bills.txt\n  check -d ledger.json\n  split -f bills.txt [-o out.md] [--json]\n  split -d ledger.json [--json] [-o out.json]\n  split -f free.txt --ai\n普通模式完全本地；AI 模式需两次确认。\n"
}

///|
pub fn parse_args(args : Array[String]) -> Config raise @shared.BillError {
  if args.is_empty() {
    @shared.invalid(usage())
  }
  let command = args[0]
  if command != "check" && command != "split" {
    @shared.invalid("命令必须是 check 或 split\n" + usage())
  }
  let mut input = ""
  let mut data = false
  let mut json = false
  let mut output = ""
  let mut ai = false
  let mut index = 1
  while index < args.length() {
    let arg = args[index]
    if arg == "-f" || arg == "-d" || arg == "-o" {
      if index + 1 >= args.length() ||
        args[index + 1].is_empty() ||
        args[index + 1].has_prefix("-") {
        @shared.invalid("参数缺少值：" + arg)
      }
      index = index + 1
      if arg == "-o" {
        if output != "" {
          @shared.invalid("-o 不能重复")
        }
        output = args[index]
      } else {
        if input != "" {
          @shared.invalid("-f 和 -d 必须二选一且不能重复")
        }
        input = args[index]
        data = arg == "-d"
      }
    } else if arg == "--json" {
      if json {
        @shared.invalid("--json 不能重复")
      }
      json = true
    } else if arg == "--ai" {
      if ai {
        @shared.invalid("--ai 不能重复")
      }
      ai = true
    } else {
      @shared.invalid("未知参数：" + arg)
    }
    index = index + 1
  }
  if input.is_empty() {
    @shared.invalid("必须提供 -f 或 -d")
  }
  if ai && (command != "split" || data) {
    @shared.invalid("--ai 仅用于 split -f 自然语言输入")
  }
  if command == "check" && (json || output != "") {
    @shared.invalid("check 不接受 --json 或 -o")
  }
  { command, input, data, json, output, ai, }
}

///|
pub fn execute(
  config : Config,
  content : String,
) -> String raise @shared.BillError {
  if config.ai {
    @shared.invalid("AI 由独立解析与确认流程执行")
  }
  let ledger = if config.data {
    @shared.decode_ledger(content)
  } else {
    @shared.parse_text(content)
  }
  if config.command == "check" {
    return "账单校验通过。\n"
  }
  let report = @shared.settle(ledger)
  if config.json {
    @shared.render_report_json(report)
  } else {
    @shared.render_markdown(report)
  }
}
