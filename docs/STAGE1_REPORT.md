# SplitEasy V3.1 阶段 1 交付报告

## 1. 本阶段完成内容

2026-10-15：已核实官方 stable 文档，安装真实工具链，创建共享 MoonBit 包、Native 和 JS 入口、最小网页、Makefile 和网页构建脚本。仅实现工程启动消息；没有提前进入阶段 2。

## 2. 新增和修改文件列表

- `.github/workflows/.gitkeep`
- `.gitignore`
- `AI_USAGE.md`
- `CHANGELOG.md`
- `LICENSE`
- `Makefile`
- `README.md`
- `cli/core/moon.pkg`
- `cli/core/runner.mbt`
- `cli/main/main.mbt`
- `cli/main/moon.pkg`
- `docs/architecture.md`
- `docs/browser-verification.json`
- `docs/toolchain.txt`
- `docs/verification.json`
- `examples/.gitkeep`
- `fixtures/.gitkeep`
- `moon.mod`
- `shared/bootstrap.mbt`
- `shared/bootstrap_test.mbt`
- `shared/moon.pkg`
- `web/build.sh`
- `web/dom.mbt`
- `web/index.html`
- `web/main.mbt`
- `web/moon.pkg`
- `web/spliteasy.js`

目录 fixtures、examples、.github/workflows 用空 .gitkeep 保留。后续业务文件按阶段创建。
另外本报告为交付汇编，不将自身递归嵌入内容。

## 3. 所有文件完整内容

以下为全部工程文件的 UTF-8 原文，包括工具链帮助输出、验证 JSON 和 MoonBit 生成的网页 JS。
Git 内部元数据、可再生 _build 缓存不属于源码交付。

### .github/workflows/.gitkeep

````text

````

### .gitignore

````text
/_build/
/target/
/.mooncakes/
/web/spliteasy.js
*.log
.DS_Store

````

### AI_USAGE.md

````text
# AI 使用记录

## 2026-10-15 · 阶段 1

工具：ChatGPT 中的 Codex，使用真实终端、官方文档检索和本地构建工具。
用户提供 SplitEasy V3.1 开发方案，要求阶段结束后等待确认。
AI 创建共享包、Native/JS 入口、DOM 桥接、构建脚本和本阶段文档。
本阶段没有实现整数分、分摊算法、Ledger、AI API 或业务界面。

实际执行命令和输出见 docs/verification.json；工具帮助输出见 docs/toolchain.txt。
安装首次因 tar 恢复 uid/gid 被容器拒绝而失败，使用 TAR_OPTIONS=--no-same-owner 重试。
不得将自动化冒烟检查写成人工验收；真实手机和用户电脑验证尚未完成。
不宣称已经创建公开 GitHub 仓库、部署 Pages 或通过赛事审核。

后续阶段再记录整数分设计、贪心局限、AI 解析风险和具体修复。

````

### CHANGELOG.md

````text
# Changelog

## 0.1.0 · 2026-10-15

- 阶段 1：建立 MoonBit 共享包、Native/JS 入口和可重复网页构建脚本。
- 本版本仅为工程骨架，不提供实际分账功能。

````

### LICENSE

````text
MIT License

Copyright (c) 2026 SplitEasy contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

````

### Makefile

````text
.PHONY: test check build-native build-web run-cli

test:
	moon test --target native
	moon test --target js

check:
	moon check --target native
	moon check --target js

build-native:
	moon build --target native

build-web:
	bash web/build.sh

run-cli:
	moon run cli/main --target native

````

### README.md

````text
# SplitEasy · AA 分账器

MoonBit 黑客松项目，产品规范 V3.1。当前仅交付阶段 1 工程骨架，尚未实现记账和分账。
内部交付截止：2026-10-24 23:59（Asia/Shanghai）。

## 环境

使用 MoonBit 官方默认 stable 工具链，不固定未经验证的旧版本。
Linux/macOS 安装：

```bash
curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash
export PATH="$HOME/.moon/bin:$PATH"
```

Windows 用户建议通过 VS Code 的 MoonBit 扩展安装工具链。
本项目 Makefile 和 build.sh 需要 Bash/Make；Windows 可使用 WSL。
Native 需要可用 C 编译器，JS 测试需要 Node.js。

## 阶段 1 命令

在项目根目录逐条运行：

```bash
moon version
moon --help
moon build --help
moon test --help
moon check --help
make check
make test
make build-native
make run-cli
make build-web
python3 -m http.server 8000 --directory web
```

最后一条命令启动本地服务器；打开 http://localhost:8000。
Native 输出和网页状态应为 `SplitEasy: MoonBit shared core ready.`。
这只表示共享包可用，不代表分账功能完成。

## 结构

- shared：纯 MoonBit 共享包，当前只有启动信息和冒烟测试。
- cli/core：Native 适配包，当前转发共享启动信息。
- cli/main：Native 可执行入口。
- web：JS 可执行入口、DOM FFI、HTML 和构建脚本。
- fixtures、examples、.github/workflows：保留后续阶段目录。
- docs：实际验证日志及阶段交付记录。

只创建本阶段所需文件；金额模型、分账、文本解析、AI、CI、部署均在后续阶段完成。
`web/spliteasy.js` 是编译产物，不手写、不提交 Git；运行 `make build-web` 重新生成。
仓库地址、在线演示、手机体验、赛事要求均待验证，不提供虚构链接。

## 隐私

当前程序只显示固定启动信息，不收集或上传账单，不使用外部 CDN。

## 官方参考

- https://www.moonbitlang.com/download/
- https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html
- https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html
- https://docs.moonbitlang.com/en/stable/tutorial/cli-quickstart.html
- https://docs.moonbitlang.com/en/stable/language/ffi.html

## 许可证

MIT，见 LICENSE。

````

### cli/core/moon.pkg

````text
import {
  "spliteasy/spliteasy/shared",
}

supported_targets = "native"

````

### cli/core/runner.mbt

````text
///|
/// Stage 1 only. Argument parsing and IO belong to stage 7.
pub fn startup_message() -> String {
  @shared.startup_message()
}

````

### cli/main/main.mbt

````text
///|
fn main {
  println(@core.startup_message())
}

````

### cli/main/moon.pkg

````text
import {
  "spliteasy/spliteasy/cli/core",
}

pkgtype(kind: "executable")

supported_targets = "native"

````

### docs/architecture.md

````text
# 阶段 1 技术核实

核实日期：2026-10-15。以官方 stable 文档和安装后命令结果为依据。

- moon：0.1.20261012 (748b63c 2026-10-12)。
- moonc：v0.10.15+943464bfa (2026-10-12)。
- 新工程采用 moon.mod / moon.pkg，不使用旧 JSON 清单。
- 模块默认 Native，支持 +native+js；shared 双端；web 仅 JS；cli 仅 Native。
- pkgtype(kind: "executable") 声明两个可执行入口。
- web 的 options(link: { "js": { "format": "iife" } }) 已实际生成 IIFE。
- 当前产物路径 _build/js/release/build/web/web.js 已实测。
- Native 可执行产物通过 moon run cli/main --target native 实际运行。
- Native IO、参数解析和网络 AI 本阶段不实现；官方 Native CLI 示例使用 async 包与 core/argparse，后续阶段再核对当时版本。
- 所有当前包都不依赖第三方模块；仅使用随工具链提供的标准库。

官方资料：
https://www.moonbitlang.com/download/
https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html
https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html
https://docs.moonbitlang.com/en/stable/tutorial/cli-quickstart.html
https://docs.moonbitlang.com/en/stable/language/ffi.html

实际错误和修复：
1. 官方安装脚本首次 tar 恢复 uid/gid 失败：用 TAR_OPTIONS=--no-same-owner 重试，成功。
2. 首次 moon fmt 在工程父目录执行失败：切换到 spliteasy 根目录后成功。
3. 黑盒测试隐式导入警告：改为 @shared.startup_message() 后检查无警告。
4. 首次 IIFE 构建提示 TypeScript 声明仅支持 ESM：本项目不依赖 TypeScript 声明，JS 产物正常生成。
5. 真实浏览器缺失且下载包无效：不伪造验收，明确留待用户或后续环境验证。

仓库：已 git init -b main。未建立远程仓库、未提交或推送、未部署。
赛事资格与官方截止尚未独立核验；本阶段继续遵守用户给定内部交付截止。

````

### docs/browser-verification.json

````text
{
  "node_mock_dom": {
    "exit_code": 0,
    "stdout": "SplitEasy: MoonBit shared core ready.\n"
  },
  "real_browser_tested": false,
  "real_phone_tested": false,
  "offline_browser_tested": false,
  "reason": "Playwright 缺少 Chromium，下载的浏览器压缩包无效；未完成真实浏览器验证。"
}

````

### docs/toolchain.txt

````text
$ moon version
moon 0.1.20261012 (748b63c 2026-10-12)

Feature flags enabled: rr_moon_mod,rr_moon_pkg

exit=0

$ moon --help
The build system and package manager for MoonBit.

Usage: moon [OPTIONS] <COMMAND>

Commands:
  new                    Create a new MoonBit module
  build                  Build the current package
  check                  Check the current package, but don't build object files
  prove                  Prove the current package
  run                    Run a main package
  runwasm                Deprecated: use moon run --target wasm locally or moonx for registry packages
  test                   Test the current package
  clean                  Remove local build outputs or configured global caches
  fmt                    Format source code
  doc                    Generate documentation or searching documentation for a symbol
  explain                Explain compiler diagnostics and language topics
  info                   Generate public interface (`.mbti`) files for all packages in the module or workspace
  bench                  Run benchmarks in the current package
  add                    Add a dependency
  remove                 Remove a dependency
  install                Install a binary package globally or install project dependencies (deprecated without args)
  tree                   Display the dependency tree
  fetch                  Download a package to .repos directory (unstable)
  search                 Search modules and package summaries in the registry
  view                   View a registry module or a user's published modules
  work                   Workspace maintenance commands
  login                  Log in to your account
  whoami                 Show login status and username
  register               Register an account at mooncakes.io
  publish                Publish the current module
  package                Package the current module
  deprecate              Deprecate or restore all existing versions of a published module
  update                 Update the package registry index
  coverage               Code coverage utilities
  generate-build-matrix  Generate build matrix for benchmarking (legacy feature)
  upgrade                Upgrade toolchains
  shell-completion       Generate shell completion for bash/elvish/fish/pwsh/zsh to stdout
  version                Print version information and exit
  help                   Print this message or the help of the given subcommand(s)

Options:
  -V, --version  Print all version information and exit
  -h, --help     Print help

Common Options:
  -C <DIR>
          Change to DIR before doing anything else (must appear before the subcommand). Relative paths in other options and arguments are interpreted relative to DIR. Example: `moon -C a run .` runs the same as invoking `moon run .` from within `a`
      --target-dir <TARGET_DIR>
          The target directory. Defaults to `<project-root>/_build`, or `<source-dir>/_build/<file-name>` for a standalone file
  -q, --quiet
          Suppress output
  -v, --verbose
          Increase verbosity
      --trace
          Trace the execution of the program
      --dry-run
          Do not actually run the command
  -Z, --unstable-feature <UNSTABLE_FEATURE>
          Unstable flags to MoonBuild [env: MOON_UNSTABLE=] [default: ]

exit=0

$ moon build --help
Build the current package

Usage: moon build [OPTIONS] [PATH]...

Arguments:
  [PATH]...  Paths to the packages that should be built, or one standalone `.mbtx` file

Options:
  -g, --debug                      Emit debug information
      --release                    Compile in release mode
      --strip                      Enable stripping debug information
      --no-strip                   Disable stripping debug information
      --target <TARGET>            Select output target [possible values: wasm, wasm-gc, js, native, llvm, all]
      --enable-coverage            Enable coverage instrumentation
      --sort-input                 Sort input files
      --output-wat                 Output WAT instead of WASM
  -d, --deny-warn                  Treat all warnings as errors
      --no-render                  Don't render diagnostics (in raw human-readable format)
      --output-json                Output diagnostics in JSON format
      --warn-list <WARN_LIST>      Warn list config
  -j, --jobs <JOBS>                Set the max number of jobs to run in parallel
      --render-no-loc <MIN_LEVEL>  Render no-location diagnostics starting from a certain level [default: error] [possible values: info, warn, error]
      --diagnostic-limit <N>       Limit the number of rendered diagnostics
  -h, --help                       Print help

Manifest Options:
      --frozen  Do not sync dependencies, assuming local dependencies are up-to-date
  -w, --watch   Monitor the file system and automatically build artifacts

Common Options:
      --target-dir <TARGET_DIR>  The target directory. Defaults to `<project-root>/_build`, or `<source-dir>/_build/<file-name>` for a standalone file
  -q, --quiet                    Suppress output
  -v, --verbose                  Increase verbosity
      --trace                    Trace the execution of the program
      --dry-run                  Do not actually run the command

exit=0

$ moon test --help
Test the current package

Usage: moon test [OPTIONS] [PATH]...

Options:
  -g, --debug
          Emit debug information

      --release
          Compile in release mode

      --strip
          Enable stripping debug information

      --no-strip
          Disable stripping debug information

      --target <TARGET>
          Select output target
          
          [possible values: wasm, wasm-gc, js, native, llvm, all]

      --enable-coverage
          Enable coverage instrumentation

      --sort-input
          Sort input files

      --output-wat
          Output WAT instead of WASM

  -d, --deny-warn
          Treat all warnings as errors

      --no-render
          Don't render diagnostics (in raw human-readable format)

      --output-json
          Output diagnostics in JSON format

      --warn-list <WARN_LIST>
          Warn list config

  -j, --jobs <JOBS>
          Set the max number of jobs to run in parallel

      --render-no-loc <MIN_LEVEL>
          Render no-location diagnostics starting from a certain level
          
          [default: error]
          [possible values: info, warn, error]

      --diagnostic-limit <N>
          Limit the number of rendered diagnostics

      --wasm-policy <PATH>
          Pass a moonrun JSON policy file to Wasm backends; ignored by other backends

  -p, --package <PACKAGE>...
          Run test in the specified package

  -i, --index <INDEX>
          Run only the index-th test in the file. Accepts a single index or a left-inclusive right-exclusive range like `0-2`. Only valid when a single file is selected. Implies `--include-skipped`

      --doc-index <DOC_INDEX>
          Run only the index-th doc test in the file. Only valid when a single file is selected. Implies `--include-skipped`

  -u, --update
          Update the test snapshot

  -l, --limit <LIMIT>
          Limit of expect test update passes to run, in order to avoid infinite loops
          
          [default: 256]

  -h, --help
          Print help (see a summary with '-h')

Manifest Options:
      --frozen
          Do not sync dependencies, assuming local dependencies are up-to-date

      --build-only
          Only build, do not run the tests

      --profile
          Profile native test executables using Time Profiler on macOS or perf on Linux

      --no-parallelize
          Run the tests in a target backend sequentially

      --outline
          Print the outline of tests to be executed and exit

      --test-failure-json
          Print failure message in JSON format

      --patch-file <PATCH_FILE>
          Path to the patch file

      --include-skipped
          Include skipped tests. Automatically implied when `--[doc-]index` is set

  -f, --filter <FILTER>
          Run only tests whose name matches the given glob pattern. Supports '*' (matches any sequence) and '?' (matches any single character)

  [PATH]...
          Run tests for package directories, files inside packages, or one standalone `.mbtx` script.
          
          An explicit `.mbtx` path tests only that script, even inside a project. The script must define `fn main`, but tests use a generated entrypoint and do not execute the script's main. Package-wide testing excludes `.mbtx` scripts. Outside a project, a single `.mbt` or `.mbt.md` file can also be tested.

Common Options:
      --target-dir <TARGET_DIR>
          The target directory. Defaults to `<project-root>/_build`, or `<source-dir>/_build/<file-name>` for a standalone file

  -q, --quiet
          Suppress output

  -v, --verbose
          Increase verbosity

      --trace
          Trace the execution of the program

      --dry-run
          Do not actually run the command

exit=0

$ moon check --help
Check the current package, but don't build object files

Usage: moon check [OPTIONS] [PATH]...

Options:
  -g, --debug                      Emit debug information
      --release                    Compile in release mode
      --strip                      Enable stripping debug information
      --no-strip                   Disable stripping debug information
      --target <TARGET>            Select output target [possible values: wasm, wasm-gc, js, native, llvm, all]
      --enable-coverage            Enable coverage instrumentation
      --sort-input                 Sort input files
      --output-wat                 Output WAT instead of WASM
  -d, --deny-warn                  Treat all warnings as errors
      --no-render                  Don't render diagnostics (in raw human-readable format)
      --output-json                Output diagnostics in JSON format
      --warn-list <WARN_LIST>      Warn list config
  -j, --jobs <JOBS>                Set the max number of jobs to run in parallel
      --render-no-loc <MIN_LEVEL>  Render no-location diagnostics starting from a certain level [default: error] [possible values: info, warn, error]
      --diagnostic-limit <N>       Limit the number of rendered diagnostics
  -h, --help                       Print help

Manifest Options:
      --frozen                   Do not sync dependencies, assuming local dependencies are up-to-date
  -w, --watch                    Monitor the file system and automatically check files
      --patch-file <PATCH_FILE>  The patch file to check. Only valid when the selector resolves to a single package
      --explain                  Whether to explain the error code with details
      --fmt                      Check whether the code is properly formatted
      --json                     Output one complete JSON result to stdout
  [PATH]...                  Filesystem path to a package directory, `.mbt` / `.mbt.md` selector, or standalone `.mbtx` file

Common Options:
      --target-dir <TARGET_DIR>  The target directory. Defaults to `<project-root>/_build`, or `<source-dir>/_build/<file-name>` for a standalone file
  -q, --quiet                    Suppress output
  -v, --verbose                  Increase verbosity
      --trace                    Trace the execution of the program
      --dry-run                  Do not actually run the command

exit=0


````

### docs/verification.json

````text
[
  {
    "command": "moon fmt",
    "exit_code": 0,
    "stdout": "",
    "stderr": "Finished. moon: ran 8 tasks, now up to date\n"
  },
  {
    "command": "make check",
    "exit_code": 0,
    "stdout": "moon check --target native\nmoon check --target js\n",
    "stderr": "Finished. moon: ran 1 task, now up to date\nFinished. moon: ran 1 task, now up to date\n"
  },
  {
    "command": "make test",
    "exit_code": 0,
    "stdout": "moon test --target native\nTotal tests: 1, passed: 1, failed: 0.\nmoon test --target js\nTotal tests: 1, passed: 1, failed: 0.\n",
    "stderr": ""
  },
  {
    "command": "make build-native",
    "exit_code": 0,
    "stdout": "moon build --target native\n",
    "stderr": "Finished. moon: ran 5 tasks, now up to date\n"
  },
  {
    "command": "make run-cli",
    "exit_code": 0,
    "stdout": "moon run cli/main --target native\nSplitEasy: MoonBit shared core ready.\n",
    "stderr": ""
  },
  {
    "command": "make build-web",
    "exit_code": 0,
    "stdout": "bash web/build.sh\n已生成 web/spliteasy.js\n",
    "stderr": "Finished. moon: no work to do\n"
  },
  {
    "command": "make build-web",
    "exit_code": 0,
    "stdout": "bash web/build.sh\n已生成 web/spliteasy.js\n",
    "stderr": "Finished. moon: no work to do\n"
  },
  {
    "command": "bash -n web/build.sh",
    "exit_code": 0,
    "stdout": "",
    "stderr": ""
  },
  {
    "command": "moonc -v",
    "exit_code": 0,
    "stdout": "v0.10.15+943464bfa (2026-10-12)\n",
    "stderr": ""
  },
  {
    "command": "node --version",
    "exit_code": 0,
    "stdout": "v24.19.0\n",
    "stderr": ""
  },
  {
    "command": "failure injection: mock moon exits 23; bash web/build.sh",
    "exit_code": 23,
    "expected_exit_code": 23,
    "passed": true,
    "stale_artifact_removed": true
  },
  {
    "command": "bash web/build.sh (restore after failure injection)",
    "exit_code": 0,
    "stdout": "已生成 web/spliteasy.js\n",
    "stderr": "Finished. moon: no work to do\n"
  }
]

````

### examples/.gitkeep

````text

````

### fixtures/.gitkeep

````text

````

### moon.mod

````text
name = "spliteasy/spliteasy"

version = "0.1.0"

readme = "README.md"

license = "MIT"

preferred_target = "native"

supported_targets = "+native+js"

````

### shared/bootstrap.mbt

````text
///|
/// Stage 1: prove both entrypoints use the same pure MoonBit package.
pub fn startup_message() -> String {
  "SplitEasy: MoonBit shared core ready."
}

````

### shared/bootstrap_test.mbt

````text
///|
test "shared package is available" {
  assert_eq(@shared.startup_message(), "SplitEasy: MoonBit shared core ready.")
}

````

### shared/moon.pkg

````text
supported_targets = "+native+js"

````

### web/build.sh

````text
#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"
# Remove the published copy first so a failed build cannot leave a stale success.
rm -f web/spliteasy.js
moon build --target js --release
artifact="_build/js/release/build/web/web.js"
if [[ ! -s "$artifact" ]]; then
  echo "未找到 MoonBit JS 产物：$artifact" >&2
  exit 1
fi
cp "$artifact" web/spliteasy.js
echo "已生成 web/spliteasy.js"

````

### web/dom.mbt

````text
///|
/// Host bridge only: textContent treats the message as plain text.
extern "js" fn set_status(message : String) -> Unit =
  #| (message) => { document.getElementById("status").textContent = message; }

````

### web/index.html

````text
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>SplitEasy · 工程验证</title>
  <style>
    body { margin: 0; background: #f4f7f8; color: #182b31; font: 16px/1.6 system-ui, sans-serif; }
    main { max-width: 640px; margin: 48px auto; padding: 24px; }
    section { padding: 24px; background: white; border-radius: 16px; }
    h1 { margin-top: 0; }
  </style>
</head>
<body>
  <main><section>
    <h1>SplitEasy · AA 分账器</h1>
    <p>阶段 1：验证 MoonBit 编译产物和共享核心加载。</p>
    <p id="status" role="status">等待 MoonBit 程序启动……</p>
    <noscript>请启用 JavaScript 后重新打开页面。</noscript>
  </section></main>
  <script src="spliteasy.js" defer></script>
</body>
</html>

````

### web/main.mbt

````text
///|
fn main {
  set_status(@shared.startup_message())
}

````

### web/moon.pkg

````text
import {
  "spliteasy/spliteasy/shared",
}

pkgtype(kind: "executable")

supported_targets = "js"

options(
  link: { "js": { "format": "iife" } },
)

````

### web/spliteasy.js

````text
(() => {
  const _M0FP39spliteasy9spliteasy3web11set__status = (message) => { document.getElementById("status").textContent = message; };
  (() => {
    _M0FP39spliteasy9spliteasy3web11set__status("SplitEasy: MoonBit shared core ready.");
  })();
})();

````

## 4. 需要运行的命令

Linux/macOS 或 WSL，解压后进入 spliteasy 目录，逐条运行：

```bash
export PATH="$HOME/.moon/bin:$PATH"
moon version
moon --help
moon build --help
moon test --help
moon check --help
make check
make test
make build-native
make run-cli
make build-web
make build-web
python3 -m http.server 8000 --directory web
```

未安装 MoonBit 时，先按 README 从官方网站安装；不要覆盖已有工具链目录。
服务器启动后访问 http://localhost:8000；停止服务器按 Ctrl+C。
Windows 命令行未验证，建议 WSL 或安装后按平台调整 Bash/Make。

## 5. 每条命令的预期输出

| 命令 | 预期 |
|---|---|
| export PATH | 无输出 |
| moon version | 工具链版本，退出 0 |
| moon --help | 总帮助，退出 0 |
| moon build --help | 构建帮助，退出 0 |
| moon test --help | 测试帮助，退出 0 |
| moon check --help | 检查帮助，退出 0 |
| make check | Native 和 JS 均无错误，退出 0 |
| make test | 两个后端各 1 项通过、0 失败 |
| make build-native | 生成 Native 可执行文件，退出 0 |
| make run-cli | SplitEasy: MoonBit shared core ready. |
| make build-web（两次） | 每次生成 web/spliteasy.js，退出 0 |
| python3 -m http.server ... | 显示监听地址；持续运行直到 Ctrl+C |

## 6. 实际运行结果

moon 0.1.20261012 (748b63c 2026-10-12)，moonc v0.10.15+943464bfa (2026-10-12)。
所有五条环境验证命令退出 0，完整输出在 docs/toolchain.txt。
最终 make check、make test、make build-native、make run-cli、make build-web 均退出 0。
Native 和 JS 各 1 项冒烟测试通过。make build-web 连续运行两次成功。
模拟编译器退出 23 时，脚本返回 23，旧 web/spliteasy.js 被移除；之后真实构建成功恢复产物。
Node 模拟 DOM 执行 IIFE 成功写入启动信息；这不等同真实浏览器验收。
完整命令、stdout、stderr、退出码见 docs/verification.json。

## 7. 未验证事项

- 真实桌面浏览器、真实手机、浏览器断网加载、file:// 兼容性。
- 用户 Windows 电脑安装与构建。
- 公开 GitHub 仓库、远程提交、Actions、Pages、在线演示。
- 赛事规则、报名和交流群要求。本阶段未核查官方参赛信息。
- 阶段 2 及以后全部业务功能。

## 8. 错误与修复

安装 tar 属主恢复失败，使用 TAR_OPTIONS=--no-same-owner 修复。
父目录执行 moon fmt 失败，切换工程目录后修复。
测试隐式导入警告，改为显式 @shared 调用后消除。
IIFE 首次构建出现 TypeScript 声明仅支持 ESM 的提示，不影响 JS 产物。
浏览器程序缺失且下载失败，所以浏览器验收留空；未删改任何失败测试。

## 9. 中文技术说明

shared 相当于两种入口共用的发动机。目前先检查发动机能否被两端调用。
Native 入口在终端打印共享消息；网页入口调用同一个函数，再由一个 JS FFI 桥接写入页面。
网页 spliteasy.js 由 MoonBit 编译生成。FFI 只操作 textContent，不包含分账算法。
把 web 标记为仅 JS、cli 标记为仅 Native，使各后端不会错误编译另一端的入口。
当前无需第三方模块、API Key 或网络请求来运行启动示例。

## 10. 本阶段验收标准

- [x] 查阅官方 stable 模块、包、FFI、Native CLI 文档。
- [x] 真实记录 moon 版本及四份帮助输出。
- [x] 工程使用 moon.mod / moon.pkg。
- [x] shared 在 Native/JS 后端均检查、测试通过。
- [x] Native 实际构建并运行。
- [x] JS IIFE 实际生成，Node 模拟 DOM 执行成功。
- [x] 构建脚本可重复运行，失败返回非零并清除旧发布产物。
- [x] 本地 Git 初始化，文档和完整源码交付。
- [ ] 真实浏览器和手机验收。
- [ ] 公开 GitHub 仓库（当前只建立本地 Git）。

结论：终端双端工程骨架验收通过；完整阶段验收仍有上述待验证项。

## 11. Git commit 建议

```bash
git add .
git commit -m "chore: bootstrap SplitEasy MoonBit native and JS targets"
```

尚未实际执行 commit，没有伪造用户身份或提交记录。
生成的 web/spliteasy.js 在交付包内便于检查，Git 通过 .gitignore 排除；构建时重新生成。
若从压缩包恢复到新位置且没有 .git，请先执行 git init -b main。

## 12. 下一阶段预告

等待用户确认后，阶段 2 才实现 Int64 整数分解析、Ledger/Payment/Share、Equal/Exact 模式、数据校验及测试。
内部交付截止仍为 2026-10-24 23:59（Asia/Shanghai）。
