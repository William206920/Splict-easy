# SplitEasy V3.1 阶段 2 交付报告

## 1. 本阶段完成内容

用户授权“做下一阶段”后，实现阶段 2 数据模型与校验，工程版本为 0.2.0。产品需求版本仍为 V3.1。

- 金额从元文本精确转换为 Int64 整数分；完全不使用浮点数。
- 非负金额安全相加，在计算前检测溢出。
- 定义 SplitMode、Share、Payment、Ledger、Transfer。
- 校验人员、付款人、两种模式字段互斥、份额、金额合计、歧义和溢出。
- 返回中文首个错误，消费序号从 1 开始。
- 付款人允许不参与消费；0 元份额允许；消费总额必须大于 0。
- 原阶段 1 测试保留，新增 40 项测试，当前每个后端共 41 项。

未实现阶段 3 的平均分配、尾差分配、余额计算和转账算法。

## 2. 新增或修改文件列表

- `moon.mod`
- `shared/moon.pkg`
- `shared/ledger.mbt`
- `shared/money.mbt`
- `shared/validate.mbt`
- `shared/ledger_test.mbt`
- `shared/money_test.mbt`
- `shared/validate_test.mbt`
- `README.md`
- `AI_USAGE.md`
- `CHANGELOG.md`
- `docs/stage2-verification.json`
- `docs/STAGE2_REPORT.md`

网页仍是阶段 1 启动页；web/spliteasy.js 已由 MoonBit 重新构建，不手写。
历史阶段 1 报告和日志作为历史记录保留，不改写其当时结果。

## 3. 所有文件完整内容

压缩包包含全部当前工程文件；以下逐项提供完整文本。
本报告不递归嵌入自身；_build 和 Git 内部元数据不属于源码交付。

### .github/workflows/.gitkeep

`````text

`````

### .gitignore

`````text
/_build/
/target/
/.mooncakes/
/web/spliteasy.js
*.log
.DS_Store

`````

### AI_USAGE.md

`````text
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

## 2026-10-15 · 阶段 2

用户明确指示“做下一阶段”，授权阶段 2；未报告完成浏览器或手机实测。
AI 实现金额解析、安全加法、数据模型、数据校验及相关测试和文档。
参照官方 stable 类型可见性文档，并直接检查已安装标准库 API，使用当前真实编译器验证。
金额从十进制字符逐位累积为 Int64 分，不经过 Float/Double 或 JS Number。
累计之前检查上界，覆盖份额合计和账单总消费合计的溢出。
新增对超过 JS 安全整数范围的金额和 Int64 最大值的双端测试。

实现过程：
- 首次本阶段构建未设置 PATH，moon 无法找到；后续显式加入 ~/.moon/bin。
- 初版 derive 生成隐式方法提升警告；增加显式 pub extend 声明修复。
- 初版 trim_space/to_string 出现弃用警告；最终改用 Char.is_whitespace 扫描 Unicode 姓名边界，同时避免分配临时字符串。
- 最终实际运行命令和结果见 docs/stage2-verification.json。
- 原有阶段 1 测试保留，没有删除失败测试，没有使用 --update 改写测试预期。

本阶段只验证模式和金额数据合法性；尚未执行平均分配、余额计算、转账或黄金结算测试。
浏览器页面没有新增业务功能，真实手机/浏览器验收仍待进行。
未创建公开远程仓库，未提交或部署，没有人工验收记录。

`````

### CHANGELOG.md

`````text
# Changelog

## 0.2.0 · 2026-10-15

- 阶段 2：Int64 整数分金额解析与安全加法。
- 新增 Ledger、Payment、Share、SplitMode、Transfer 数据模型。
- 新增账单、人员、模式、份额和溢出校验。
- 共 41 项测试覆盖 Native 和 JS，包括超过 JS 安全整数范围的金额。
- 浏览器、手机及分账算法仍待后续验证和实现。

## 0.1.0 · 2026-10-15

- 阶段 1：建立 MoonBit 共享包、Native/JS 入口和可重复网页构建脚本。
- 本版本仅为工程骨架，不提供实际分账功能。

`````

### LICENSE

`````text
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

`````

### Makefile

`````text
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

`````

### README.md

`````text
# SplitEasy · AA 分账器

MoonBit 黑客松项目，产品规范 V3.1。当前已完成阶段 2：数据模型、金额解析和账单校验；尚未实现分账算法和记账界面。
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

- shared：纯 MoonBit 共享包，包含金额解析、数据模型、账单校验和自动化测试。
- cli/core：Native 适配包，当前转发共享启动信息。
- cli/main：Native 可执行入口。
- web：JS 可执行入口、DOM FFI、HTML 和构建脚本。
- fixtures、examples、.github/workflows：保留后续阶段目录。
- docs：实际验证日志及阶段交付记录。

只创建当前阶段所需文件；分账算法、文本解析、AI、CI、部署在后续阶段完成。
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

## 阶段 2：金额和校验

全部业务金额是 Int64 整数分，不用浮点数。

| 输入 | 解析结果（分） |
|---|---:|
| `300` | 30000 |
| `300.50` | 30050 |
| `0.29` | 29 |
| `0` | 0（可用于个人份额，不能用于消费总额） |
| `92233720368547758.07` | 9223372036854775807（Int64 上限） |

金额文本格式为 `[0-9]+(\.[0-9]{1,2})?`，允许前导零。
拒绝正负号、首尾空白、科学计数法、千分位、货币符号、全角数字和超过两位小数。
不进行自动四舍五入。返回 `Result[Int64, String]`，错误是中文。
金额运算前检查范围，账单总消费和份额合计也不能超出 Int64 上限。

公开 API：

- `parse_money(String) -> Result[Int64, String]`：元文本转换成整数分。
- `checked_add_cents(Int64, Int64) -> Result[Int64, String]`：非负金额安全相加。
- `validate_ledger(Ledger) -> Result[Unit, String]`：只校验、不修改输入、不执行结算。
- 类型：`SplitMode`、`Share`、`Payment`、`Ledger`、`Transfer`。

平均模式只允许 participants，且至少 1 人；shares 必须为空。
实际金额模式只允许 shares，且至少 1 条；participants 必须为空。
实际金额份额允许 0；未列入 shares 的人员视为不参与该笔消费。
付款人必须在总人员名单内，但不要求参与当前消费。
姓名非空且唯一，拒绝 Unicode 空白姓名及首尾空白，不会静默修改姓名。
有人员、无消费的账单可以作为草稿通过校验；非空 ambiguous 会阻止处理。
遇到多个错误时按人员和消费声明顺序返回第一个错误，消费序号从 1 开始。
日期和说明本阶段原样保留，不校验日期格式；姓名中的内部空格暂不限制，高级文本解析器后续单独约束。

网页仍是阶段 1 启动页，阶段 2 的新增能力通过 MoonBit 测试验证。
执行 `make test` 后 Native 和 JS 应各通过 41 项测试。
完整交付说明与源码见 docs/STAGE2_REPORT.md，实际命令记录见 docs/stage2-verification.json。

`````

### cli/core/moon.pkg

`````text
import {
  "spliteasy/spliteasy/shared",
}

supported_targets = "native"

`````

### cli/core/runner.mbt

`````text
///|
/// Stage 1 only. Argument parsing and IO belong to stage 7.
pub fn startup_message() -> String {
  @shared.startup_message()
}

`````

### cli/main/main.mbt

`````text
///|
fn main {
  println(@core.startup_message())
}

`````

### cli/main/moon.pkg

`````text
import {
  "spliteasy/spliteasy/cli/core",
}

pkgtype(kind: "executable")

supported_targets = "native"

`````

### docs/STAGE1_REPORT.md

`````text
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

`````

### docs/architecture.md

`````text
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

`````

### docs/browser-verification.json

`````text
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

`````

### docs/stage2-verification.json

`````text
[
  {
    "command": "moon version",
    "exit_code": 0,
    "stdout": "moon 0.1.20261012 (748b63c 2026-10-12)\n\nFeature flags enabled: rr_moon_mod,rr_moon_pkg\n",
    "stderr": ""
  },
  {
    "command": "moonc -v",
    "exit_code": 0,
    "stdout": "v0.10.15+943464bfa (2026-10-12)\n",
    "stderr": ""
  },
  {
    "command": "moon fmt",
    "exit_code": 0,
    "stdout": "",
    "stderr": "Finished. moon: ran 2 tasks, now up to date\n"
  },
  {
    "command": "make check",
    "exit_code": 0,
    "stdout": "moon check --target native\nmoon check --target js\n",
    "stderr": "Finished. moon: no work to do\nFinished. moon: no work to do\n"
  },
  {
    "command": "make test",
    "exit_code": 0,
    "stdout": "moon test --target native\nTotal tests: 41, passed: 41, failed: 0.\nmoon test --target js\nTotal tests: 41, passed: 41, failed: 0.\n",
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
    "stderr": "Typescript declaration file is only supported for ESM format for now\nFinished. moon: ran 3 tasks, now up to date\n"
  }
]

`````

### docs/toolchain.txt

`````text
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


`````

### docs/verification.json

`````text
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

`````

### examples/.gitkeep

`````text

`````

### fixtures/.gitkeep

`````text

`````

### moon.mod

`````text
name = "spliteasy/spliteasy"

version = "0.2.0"

readme = "README.md"

license = "MIT"

preferred_target = "native"

supported_targets = "+native+js"

`````

### shared/bootstrap.mbt

`````text
///|
/// Stage 1: prove both entrypoints use the same pure MoonBit package.
pub fn startup_message() -> String {
  "SplitEasy: MoonBit shared core ready."
}

`````

### shared/bootstrap_test.mbt

`````text
///|
test "shared package is available" {
  assert_eq(@shared.startup_message(), "SplitEasy: MoonBit shared core ready.")
}

`````

### shared/ledger.mbt

`````text
///|
/// Each payment chooses exactly one allocation mode.
pub(all) enum SplitMode {
  Equal
  Exact
} derive(Debug, Eq)

///|
pub extend SplitMode with @debug.Debug::{to_repr}

///|
pub extend SplitMode with Eq::{equal, not_equal}

///|
pub(all) struct Share {
  person : String
  amount_cents : Int64
} derive(Debug)

///|
pub extend Share with @debug.Debug::{to_repr}

///|
/// Untrusted input: always call validate_ledger before using a ledger.
pub(all) struct Payment {
  payer : String
  amount_cents : Int64
  split_mode : SplitMode
  participants : Array[String]
  shares : Array[Share]
  description : String
  date : String
} derive(Debug)

///|
pub extend Payment with @debug.Debug::{to_repr}

///|
pub(all) struct Ledger {
  people : Array[String]
  payments : Array[Payment]
  ambiguous : Array[String]
} derive(Debug)

///|
pub extend Ledger with @debug.Debug::{to_repr}

///|
/// Declared for the shared contract; settlement is implemented in stage 3.
pub(all) struct Transfer {
  from : String
  to : String
  amount_cents : Int64
} derive(Debug)

///|
pub extend Transfer with @debug.Debug::{to_repr}

`````

### shared/ledger_test.mbt

`````text
///|
test "public models preserve all fields" {
  let share : @shared.Share = { person: "小明", amount_cents: 29L, }
  let payment : @shared.Payment = {
    payer: "小红",
    amount_cents: 29L,
    split_mode: Exact,
    participants: [],
    shares: [share],
    description: "奶茶",
    date: "2026-10-15",
  }
  let ledger : @shared.Ledger = {
    people: ["小明", "小红"],
    payments: [payment],
    ambiguous: [],
  }
  assert_eq(ledger.payments[0].shares[0].amount_cents, 29L)
  assert_eq(ledger.payments[0].shares[0].person, "小明")
  assert_eq(payment.amount_cents, 29L)
  assert_eq(payment.payer, "小红")
  assert_true(payment.split_mode == @shared.Exact)
  assert_true(payment.participants.is_empty())
  assert_eq(payment.description, "奶茶")
  assert_eq(payment.date, "2026-10-15")
  assert_eq(ledger.people[0], "小明")
  assert_true(ledger.ambiguous.is_empty())
}

///|
test "transfer model is integer cents" {
  let transfer : @shared.Transfer = {
    from: "小明",
    to: "小红",
    amount_cents: 9007199254740993L,
  }
  assert_eq(transfer.from, "小明")
  assert_eq(transfer.to, "小红")
  assert_eq(transfer.amount_cents, 9007199254740993L)
}

`````

### shared/money.mbt

`````text
///|
/// Accept ASCII digits with an optional decimal point and 1-2 fractional digits.
/// Zero is valid here (e.g. an exact share); payments separately require > 0.
/// No signs, whitespace, separators, exponent notation, or floating point.
pub fn parse_money(input : String) -> Result[Int64, String] {
  if input.is_empty() {
    return Err("金额不能为空")
  }
  let mut value = 0L
  let mut decimal = false
  let mut integer_digits = 0
  let mut fraction_digits = 0
  for ch in input.iter() {
    if ch == '.' {
      if decimal || integer_digits == 0 {
        return Err("金额格式错误：请输入整数或最多两位小数")
      }
      decimal = true
    } else if ch >= '0' && ch <= '9' {
      if decimal {
        fraction_digits = fraction_digits + 1
        if fraction_digits > 2 {
          return Err("金额最多支持两位小数")
        }
      } else {
        integer_digits = integer_digits + 1
      }
      let digit = (ch.to_int() - 48).to_int64()
      if value > (9223372036854775807L - digit) / 10L {
        return Err("金额超出 Int64 整数分范围")
      }
      value = value * 10L + digit
    } else {
      return Err("金额格式错误：仅支持非负数字和小数点")
    }
  }
  if decimal && fraction_digits == 0 {
    return Err("小数点后必须有一到两位数字")
  }
  let scale = if fraction_digits == 0 {
    100L
  } else if fraction_digits == 1 {
    10L
  } else {
    1L
  }
  if value > 9223372036854775807L / scale {
    return Err("金额超出 Int64 整数分范围")
  }
  Ok(value * scale)
}

///|
/// For nonnegative cent amounts only. Check before addition, never after wraparound.
pub fn checked_add_cents(a : Int64, b : Int64) -> Result[Int64, String] {
  if a < 0L || b < 0L {
    return Err("金额相加时不能包含负数")
  }
  if a > 9223372036854775807L - b {
    return Err("金额合计超出 Int64 整数分范围")
  }
  Ok(a + b)
}

`````

### shared/money_test.mbt

`````text
///|
fn expect_money(input : String, expected : Int64) -> Unit raise {
  match @shared.parse_money(input) {
    Ok(value) => assert_eq(value, expected)
    Err(message) => fail("unexpected error for \{input}: \{message}")
  }
}

///|
fn expect_money_error(input : String, expected : String) -> Unit raise {
  match @shared.parse_money(input) {
    Err(message) => assert_eq(message, expected)
    Ok(_) => fail("invalid money accepted: \{input}")
  }
}

///|
test "money whole yuan" {
  expect_money("300", 30000L)
  expect_money("0012", 1200L)
}

///|
test "money decimal precision" {
  expect_money("300.50", 30050L)
  expect_money("0.29", 29L)
  expect_money("0.01", 1L)
  expect_money("12.3", 1230L)
}

///|
test "money zero valid for shares" {
  expect_money("0", 0L)
  expect_money("0.0", 0L)
  expect_money("0.00", 0L)
}

///|
test "money beyond JS safe integer stays exact" {
  expect_money("90071992547409.93", 9007199254740993L)
}

///|
test "money Int64 cent maximum" {
  expect_money("92233720368547758.07", 9223372036854775807L)
  expect_money("92233720368547758", 9223372036854775800L)
  expect_money("9223372036854775.8", 922337203685477580L)
}

///|
test "money overflow at cent boundary" {
  expect_money_error(
    "92233720368547758.08", "金额超出 Int64 整数分范围",
  )
  expect_money_error("92233720368547759", "金额超出 Int64 整数分范围")
  expect_money_error(
    "9223372036854775808", "金额超出 Int64 整数分范围",
  )
  expect_money_error(
    "999999999999999999999999999.00", "金额超出 Int64 整数分范围",
  )
}

///|
test "money overflow when scaling a single fractional digit" {
  expect_money_error(
    "92233720368547758.1", "金额超出 Int64 整数分范围",
  )
}

///|
test "money rejects signs and whitespace" {
  for input in ["-1", "+1", " 1", "1 ", "\t1", "1\n", "-0.00"] {
    expect_money_error(
      input, "金额格式错误：仅支持非负数字和小数点",
    )
  }
}

///|
test "money rejects unsupported numeric formats" {
  for
    input in [
      "1e2", "1,000", "NaN", "Infinity", "￥12", "１２.３４", "1/2",
    ] {
    expect_money_error(
      input, "金额格式错误：仅支持非负数字和小数点",
    )
  }
}

///|
test "money rejects malformed decimal" {
  for input in [".5", ".", "1..2", "1.2.3"] {
    expect_money_error(
      input, "金额格式错误：请输入整数或最多两位小数",
    )
  }
  expect_money_error("1.", "小数点后必须有一到两位数字")
  expect_money_error("1.001", "金额最多支持两位小数")
  expect_money_error("", "金额不能为空")
}

///|
test "checked addition accepts maximum and zero" {
  match @shared.checked_add_cents(9223372036854775806L, 1L) {
    Ok(value) => assert_eq(value, 9223372036854775807L)
    Err(message) => fail(message)
  }
  match @shared.checked_add_cents(9223372036854775807L, 0L) {
    Ok(value) => assert_eq(value, 9223372036854775807L)
    Err(message) => fail(message)
  }
}

///|
test "checked addition rejects overflow and negatives" {
  for (a, b) in [(9223372036854775807L, 1L), (1L, 9223372036854775807L)] {
    match @shared.checked_add_cents(a, b) {
      Err(message) =>
        assert_eq(message, "金额合计超出 Int64 整数分范围")
      Ok(_) => fail("overflow accepted")
    }
  }
  for (a, b) in [(-1L, 0L), (0L, -1L), (-9223372036854775808L, 1L)] {
    match @shared.checked_add_cents(a, b) {
      Err(message) => assert_eq(message, "金额相加时不能包含负数")
      Ok(_) => fail("negative accepted")
    }
  }
}

`````

### shared/moon.pkg

`````text
import {
  "moonbitlang/core/debug",
}

supported_targets = "+native+js"

`````

### shared/validate.mbt

`````text
///|
fn has_person(people : Array[String], name : String) -> Bool {
  for person in people {
    if person == name {
      return true
    }
  }
  false
}

///|
/// Return the first Chinese error in declaration order. Do not modify input.
/// Empty payments are allowed for a draft, but a people list is required.
pub fn validate_ledger(ledger : Ledger) -> Result[Unit, String] {
  if ledger.people.is_empty() {
    return Err("参与人员不能为空")
  }
  let seen : Array[String] = []
  for i, person in ledger.people {
    let mut first = true
    let mut leading_space = false
    let mut trailing_space = false
    let mut only_space = true
    for ch in person.iter() {
      if first {
        leading_space = ch.is_whitespace()
        first = false
      }
      trailing_space = ch.is_whitespace()
      if !trailing_space {
        only_space = false
      }
    }
    if only_space {
      return Err("第 \{i + 1} 位人员的姓名不能为空")
    }
    if leading_space || trailing_space {
      return Err("第 \{i + 1} 位人员的姓名首尾不能有空白")
    }
    if has_person(seen, person) {
      return Err("人员姓名重复：\{person}")
    }
    seen.push(person)
  }
  if !ledger.ambiguous.is_empty() {
    return Err("账单存在歧义：\{ledger.ambiguous[0]}")
  }
  let mut total = 0L
  for i, payment in ledger.payments {
    let prefix = "第 \{i + 1} 笔消费："
    if !has_person(ledger.people, payment.payer) {
      return Err(prefix + "未知付款人：" + payment.payer)
    }
    if payment.amount_cents <= 0L {
      return Err(prefix + "消费总金额必须大于零")
    }
    match payment.split_mode {
      Equal => {
        if !payment.shares.is_empty() {
          return Err(
            prefix + "平均分摊不能同时填写实际金额份额",
          )
        }
        if payment.participants.is_empty() {
          return Err(prefix + "平均分摊至少需要一位参与者")
        }
        let participants : Array[String] = []
        for name in payment.participants {
          if !has_person(ledger.people, name) {
            return Err(prefix + "未知参与者：" + name)
          }
          if has_person(participants, name) {
            return Err(prefix + "参与者重复：" + name)
          }
          participants.push(name)
        }
      }
      Exact => {
        if !payment.participants.is_empty() {
          return Err(
            prefix + "按实际金额分摊不能同时填写平均参与者",
          )
        }
        if payment.shares.is_empty() {
          return Err(prefix + "按实际金额分摊至少需要一条份额")
        }
        let shares_seen : Array[String] = []
        let mut sum = 0L
        for share in payment.shares {
          if !has_person(ledger.people, share.person) {
            return Err(prefix + "未知份额人员：" + share.person)
          }
          if has_person(shares_seen, share.person) {
            return Err(prefix + "份额人员重复：" + share.person)
          }
          if share.amount_cents < 0L {
            return Err(
              prefix + "个人分摊金额不能为负数：" + share.person,
            )
          }
          shares_seen.push(share.person)
          sum = match checked_add_cents(sum, share.amount_cents) {
            Ok(value) => value
            Err(message) => return Err(prefix + message)
          }
        }
        if sum != payment.amount_cents {
          return Err(
            prefix + "个人分摊金额合计必须等于消费总金额",
          )
        }
      }
    }
    total = match checked_add_cents(total, payment.amount_cents) {
      Ok(value) => value
      Err(message) => return Err(prefix + message)
    }
  }
  Ok(())
}

`````

### shared/validate_test.mbt

`````text
///|
fn equal_payment() -> @shared.Payment {
  {
    payer: "小明",
    amount_cents: 20000L,
    split_mode: Equal,
    participants: ["小明", "小红"],
    shares: [],
    description: "晚餐",
    date: "",
  }
}

///|
fn exact_payment() -> @shared.Payment {
  {
    payer: "小红",
    amount_cents: 7500L,
    split_mode: Exact,
    participants: [],
    shares: [
      { person: "小明", amount_cents: 1200L, },
      { person: "小红", amount_cents: 1500L, },
      { person: "小刚", amount_cents: 1800L, },
      { person: "小美", amount_cents: 1400L, },
      { person: "小李", amount_cents: 1600L, },
    ],
    description: "奶茶",
    date: "2026-10-15",
  }
}

///|
fn ledger_with(payments : Array[@shared.Payment]) -> @shared.Ledger {
  {
    people: ["小明", "小红", "小刚", "小美", "小李"],
    payments,
    ambiguous: [],
  }
}

///|
fn expect_valid(ledger : @shared.Ledger) -> Unit raise {
  match @shared.validate_ledger(ledger) {
    Ok(_) => ()
    Err(message) => fail(message)
  }
}

///|
fn expect_invalid(ledger : @shared.Ledger, expected : String) -> Unit raise {
  match @shared.validate_ledger(ledger) {
    Err(message) => assert_eq(message, expected)
    Ok(_) => fail("invalid ledger accepted")
  }
}

///|
test "validate draft with no payments" {
  expect_valid(ledger_with([]))
}

///|
test "validate empty people and blank names" {
  expect_invalid(
    { people: [], payments: [], ambiguous: [], },
    "参与人员不能为空",
  )
  for name in ["", " ", "\t\n\r"] {
    expect_invalid(
      { people: [name], payments: [], ambiguous: [], },
      "第 1 位人员的姓名不能为空",
    )
  }
}

///|
test "validate duplicate and boundary spaces" {
  expect_invalid(
    { people: ["小明", "小明"], payments: [], ambiguous: [], },
    "人员姓名重复：小明",
  )
  expect_invalid(
    { people: ["小明", " 小红"], payments: [], ambiguous: [], },
    "第 2 位人员的姓名首尾不能有空白",
  )
}

///|
test "validate ambiguous ledger blocks processing" {
  expect_invalid(
    { ..ledger_with([]), ambiguous: ["奶茶由谁付款？", "还有歧义"], },
    "账单存在歧义：奶茶由谁付款？",
  )
}

///|
test "validate unknown payer" {
  expect_invalid(
    ledger_with([{ ..equal_payment(), payer: "陌生人", }]),
    "第 1 笔消费：未知付款人：陌生人",
  )
}

///|
test "validate positive payment amount" {
  for amount in [0L, -1L, -9223372036854775808L] {
    expect_invalid(
      ledger_with([{ ..equal_payment(), amount_cents: amount, }]),
      "第 1 笔消费：消费总金额必须大于零",
    )
  }
}

///|
test "validate equal payment" {
  expect_valid(ledger_with([equal_payment()]))
}

///|
test "validate equal needs participants" {
  expect_invalid(
    ledger_with([{ ..equal_payment(), participants: [], }]),
    "第 1 笔消费：平均分摊至少需要一位参与者",
  )
}

///|
test "validate equal rejects conflicting shares" {
  expect_invalid(
    ledger_with([
      { ..equal_payment(), shares: [{ person: "小明", amount_cents: 0L, }], },
    ]),
    "第 1 笔消费：平均分摊不能同时填写实际金额份额",
  )
}

///|
test "validate equal rejects unknown or duplicate participants" {
  expect_invalid(
    ledger_with([{ ..equal_payment(), participants: ["未知"], }]),
    "第 1 笔消费：未知参与者：未知",
  )
  expect_invalid(
    ledger_with([{ ..equal_payment(), participants: ["小明", "小明"], }]),
    "第 1 笔消费：参与者重复：小明",
  )
}

///|
test "validate payer need not participate" {
  expect_valid(ledger_with([{ ..equal_payment(), participants: ["小红"], }]))
  expect_valid(
    ledger_with([
      {
        ..exact_payment(),
        payer: "小红",
        shares: [{ person: "小明", amount_cents: 7500L, }],
      },
    ]),
  )
}

///|
test "validate exact five person milk tea" {
  expect_valid(ledger_with([exact_payment()]))
}

///|
test "validate exact rejects conflicting participants" {
  expect_invalid(
    ledger_with([{ ..exact_payment(), participants: ["小明"], }]),
    "第 1 笔消费：按实际金额分摊不能同时填写平均参与者",
  )
}

///|
test "validate exact needs shares" {
  expect_invalid(
    ledger_with([{ ..exact_payment(), shares: [], }]),
    "第 1 笔消费：按实际金额分摊至少需要一条份额",
  )
}

///|
test "validate exact rejects unknown or duplicate person" {
  expect_invalid(
    ledger_with([
      {
        ..exact_payment(),
        shares: [{ person: "未知", amount_cents: 7500L, }],
      },
    ]),
    "第 1 笔消费：未知份额人员：未知",
  )
  expect_invalid(
    ledger_with([
      {
        ..exact_payment(),
        shares: [
          { person: "小明", amount_cents: 7500L, },
          { person: "小明", amount_cents: 0L, },
        ],
      },
    ]),
    "第 1 笔消费：份额人员重复：小明",
  )
}

///|
test "validate exact negative share" {
  expect_invalid(
    ledger_with([
      { ..exact_payment(), shares: [{ person: "小明", amount_cents: -1L, }], },
    ]),
    "第 1 笔消费：个人分摊金额不能为负数：小明",
  )
}

///|
test "validate exact zero share and omitted people" {
  expect_valid(
    ledger_with([
      {
        ..exact_payment(),
        shares: [
          { person: "小明", amount_cents: 7500L, },
          { person: "小红", amount_cents: 0L, },
        ],
      },
    ]),
  )
}

///|
test "validate exact sum mismatch in both directions" {
  for amount in [7499L, 7501L] {
    expect_invalid(
      ledger_with([
        {
          ..exact_payment(),
          shares: [{ person: "小明", amount_cents: amount, }],
        },
      ]),
      "第 1 笔消费：个人分摊金额合计必须等于消费总金额",
    )
  }
}

///|
test "validate exact sum overflow before comparison" {
  expect_invalid(
    ledger_with([
      {
        ..exact_payment(),
        amount_cents: 9223372036854775807L,
        shares: [
          { person: "小明", amount_cents: 9223372036854775807L, },
          { person: "小红", amount_cents: 1L, },
        ],
      },
    ]),
    "第 1 笔消费：金额合计超出 Int64 整数分范围",
  )
}

///|
test "validate ledger total overflow" {
  expect_invalid(
    ledger_with([
      { ..equal_payment(), amount_cents: 9223372036854775807L, },
      { ..equal_payment(), amount_cents: 1L, },
    ]),
    "第 2 笔消费：金额合计超出 Int64 整数分范围",
  )
}

///|
test "validate total at maximum" {
  expect_valid(
    ledger_with([
      { ..equal_payment(), amount_cents: 9223372036854775806L, },
      { ..equal_payment(), amount_cents: 1L, },
    ]),
  )
}

///|
test "validate mixed modes and repeat payer" {
  expect_valid(
    ledger_with([equal_payment(), { ..exact_payment(), payer: "小明", }]),
  )
}

///|
test "validate reports payment index deterministically without mutation" {
  let payment = { ..equal_payment(), payer: "未知", }
  let ledger = ledger_with([equal_payment(), payment])
  expect_invalid(ledger, "第 2 笔消费：未知付款人：未知")
  expect_invalid(ledger, "第 2 笔消费：未知付款人：未知")
  assert_eq(ledger.payments.length(), 2)
  assert_eq(ledger.payments[1].payer, "未知")
  assert_eq(ledger.people[0], "小明")
}

///|
test "validate Unicode blank names and boundary whitespace" {
  for name in ["\u{3000}", "\u{00A0}", "\u{2003}\u{2028}"] {
    expect_invalid(
      { people: [name], payments: [], ambiguous: [], },
      "第 1 位人员的姓名不能为空",
    )
  }
  for name in ["小明\u{3000}", "\u{00A0}小明"] {
    expect_invalid(
      { people: [name], payments: [], ambiguous: [], },
      "第 1 位人员的姓名首尾不能有空白",
    )
  }
}

///|
test "validate exact maximum and JS unsafe integer boundary" {
  for amount in [9007199254740993L, 9223372036854775807L] {
    expect_valid(
      ledger_with([
        {
          ..exact_payment(),
          amount_cents: amount,
          shares: [{ person: "小明", amount_cents: amount, }],
        },
      ]),
    )
  }
}

///|
test "validate single cent with multiple equal participants" {
  expect_valid(ledger_with([{ ..equal_payment(), amount_cents: 1L, }]))
}

`````

### web/build.sh

`````text
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

`````

### web/dom.mbt

`````text
///|
/// Host bridge only: textContent treats the message as plain text.
extern "js" fn set_status(message : String) -> Unit =
  #| (message) => { document.getElementById("status").textContent = message; }

`````

### web/index.html

`````text
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

`````

### web/main.mbt

`````text
///|
fn main {
  set_status(@shared.startup_message())
}

`````

### web/moon.pkg

`````text
import {
  "spliteasy/spliteasy/shared",
}

pkgtype(kind: "executable")

supported_targets = "js"

options(
  link: { "js": { "format": "iife" } },
)

`````

### web/spliteasy.js

`````text
(() => {
  const _M0FP39spliteasy9spliteasy3web11set__status = (message) => { document.getElementById("status").textContent = message; };
  (() => {
    _M0FP39spliteasy9spliteasy3web11set__status("SplitEasy: MoonBit shared core ready.");
  })();
})();

`````

## 4. 需要运行的命令

解压后进入 spliteasy 根目录，在已安装 MoonBit 的 Linux/macOS/WSL 环境逐条运行：

```bash
export PATH="$HOME/.moon/bin:$PATH"
moon version
moonc -v
moon fmt
make check
make test
make build-native
make run-cli
make build-web
```

Windows 原生命令行未实测；可使用 WSL，安装方法见 README。
阶段 2 验证通过编译器和测试完成，浏览器不会出现新增的表单或结算能力。

## 5. 每条命令预期输出

| 命令 | 预期输出或行为 |
|---|---|
| export PATH | 无输出，当前终端可以找到 moon |
| moon version | 已安装的 moon 版本 |
| moonc -v | 已安装的编译器版本 |
| moon fmt | 格式化成功，退出 0 |
| make check | Native 和 JS 检查均成功，退出 0 |
| make test | Native 和 JS 各显示 Total tests: 41, passed: 41, failed: 0. |
| make build-native | Native 构建成功，退出 0 |
| make run-cli | SplitEasy: MoonBit shared core ready. |
| make build-web | 已生成 web/spliteasy.js，退出 0 |

IIFE 构建可能提示 TypeScript 声明仅支持 ESM；本项目不需要 TypeScript 声明，不影响 JS 生成。
不要使用 moon test --update 改写本阶段正确预期来掩盖实现问题。

## 6. 实际运行结果

实际工具链：moon 0.1.20261012 (748b63c 2026-10-12)，moonc v0.10.15+943464bfa (2026-10-12)。
上述命令均实际执行，最终退出码均为 0；检查无编译警告。
Native 和 JS 各 41 项通过、0 失败。
Native 程序实际运行并打印共享启动信息；网页 JS 产物实际生成。
完整 stdout、stderr、退出码见 docs/stage2-verification.json。

测试覆盖：
- 300、300.50、0.29、一位小数、零、前导零。
- 金额负号、正号、空白、空字符串、非法字符、全角数字、指数、千分位、小数位错误。
- 9007199254740993 分：超过 JS 安全整数边界，双端仍精确。
- 9223372036854775807 分：Int64 上限，以及上限+1、缩放溢出、累加溢出。
- 公共模型构造、读取、人员顺序、Transfer 大整数金额。
- 空名单、空白姓名（包括 Unicode 空白）、首尾空白、重名、未知付款人。
- Equal/Exact 互斥字段、缺少参与者/份额、未知人员、重复人员。
- 正消费金额、负份额、零份额、付款人不参与、未参与人员省略。
- 精确份额合计过多或不足、份额合计溢出、账单总消费溢出及上限。
- 有人员无消费的草稿、歧义拒绝、多笔混合模式合法性、重复付款人。
- 错误消费序号、重复调用结果确定及输入保留。

五人奶茶测试在本阶段只验证模型和 7500 分份额合计；不把它宣传为黄金结算测试。

## 7. 未验证事项

- 真实浏览器、手机、file:// 和断网行为仍未由用户反馈。
- Windows 原生 MoonBit/Make/Bash 环境。
- 阶段 3 黄金结算测试、尾差、净额、转账及后续功能。
- JSON 序列化/解析和网页表单接入。
- GitHub 公开仓库、commit、CI、Pages、赛事报名及规则核验。

## 8. 错误与修复

- 本阶段首条 moon 命令缺少 PATH，返回 command not found；后续显式 export PATH 后成功。
- derive 的隐式方法提升触发新工具链警告：按编译器建议增加 pub extend。
- trim_space/to_string 属弃用 API：最终使用 Char.is_whitespace 检查姓名首尾和空白姓名，兼容 Unicode。
- 没有删除任何失败测试或修改正确预期。首次完整测试为每端 38 项；追加 Unicode 与边界用例后为每端 41 项，全部通过。
- IIFE 首次构建关于 TypeScript 的提示属于已有工具链限制，JS 产物生成成功。

## 9. 中文技术说明

金额解析像手工读数：逐个读取数字，用整数乘 10 再加当前数字；按小数位数补足到“分”。
每次运算之前先判断会不会超过 Int64 上限，避免溢出后再检查。
`0.29` 直接变为 29 分，不会经过可能有舍入误差的浮点数。

| API/模型 | 用途 |
|---|---|
| parse_money | 元文本转为 Int64 分；允许 0，不允许负号或空白 |
| checked_add_cents | 只对非负金额执行带上界检查的加法 |
| SplitMode | Equal 或 Exact，后续 JSON 再映射为 equal/exact |
| Share | 姓名及个人应承担的整数分 |
| Payment | 付款人、消费金额、模式、参与者/份额、说明、日期 |
| Ledger | 总人员、消费数组、歧义数组 |
| Transfer | 转出人、收款人和整数分；本阶段只定义模型 |
| validate_ledger | 返回 Ok(()) 或首个中文错误，不计算结算、不修改输入 |

校验规则补充：
1. 允许有人员、无消费的草稿；没有人员则拒绝。
2. 实际金额模式可以省略不参与的人，或显式写 0 元；仍至少有 1 条份额。
3. 任何非空 ambiguous 数组阻止处理，避免把含糊输入当成有效账单。
4. 所有消费总额也必须能装进 Int64，保证后续总消费输出有明确上界。
5. 姓名不自动修剪；首尾空白直接提示，避免悄悄改变人员身份。内部空格允许，高级文本语法的限制在阶段 4 实现。
6. 日期和说明本阶段原样保存，不额外强制 ISO 日期；未做序列化。
7. 校验按声明顺序返回首个错误，单个错误即可修正后重新检查。
8. 当前用数组顺序扫描姓名，适合小型 AA 账单；人员查找/去重最坏为平方级，不宣称大规模高性能。
9. pub(all) 允许前端和 CLI 构造数据；它不代表数据已校验，使用前必须调用 validate_ledger。数据修改后也应重新校验。

## 10. 本阶段验收标准

- [x] 全部金额为 Int64 整数分，无浮点业务计算。
- [x] 十进制金额转换精确，格式错误和溢出被拒绝。
- [x] Ledger、Payment、Share、SplitMode、Transfer 可跨包构造和读取。
- [x] Equal/Exact 字段互斥和人员合法性校验通过。
- [x] 负消费、零消费、负份额、份额不符及合计溢出被拒绝。
- [x] 零份额、付款人不参与、多笔不同模式数据可合法通过。
- [x] Native/JS 各 41 项测试通过，双端检查和构建成功。
- [x] 中文错误含正确的消费序号。
- [x] 未提前实现阶段 3。

阶段 2 的代码验收通过；历史浏览器、手机及公开仓库待办不标记完成。

## 11. Git commit 建议

```bash
git add moon.mod shared README.md AI_USAGE.md CHANGELOG.md docs/stage2-verification.json docs/STAGE2_REPORT.md
git commit -m "feat: add Int64 money parsing and ledger validation"
```

未实际创建 commit 或推送，未虚构用户身份。
如果是解压后的新目录且没有 Git 元数据，先 git init -b main；此前阶段文件尚未提交时可先分别提交阶段 1，或用 git add . 建立合并基线并如实描述提交范围。
压缩包内包含可再生的 web/spliteasy.js，Git 仍通过 .gitignore 排除。

## 12. 下一阶段预告

等待用户确认后执行阶段 3：平均分摊、尾差、精确份额汇总、混合净额、确定性贪心转账，以及两个黄金结算测试。
内部交付截止继续为 2026-10-24 23:59（Asia/Shanghai）。
