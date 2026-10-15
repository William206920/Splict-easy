# SplitEasy V3.1 阶段 3 交付报告

## 1. 本阶段完成内容

用户授权“继续下一阶段吧”后，仅执行阶段 3。工程版本为 0.3.0，产品需求版本仍为 V3.1。

- 平均分摊和按人员声明顺序分配尾差。
- 按实际整数分分摊，保留显式零份额。
- 多笔不同分摊模式统一汇总每人已付、应付、净额。
- 每轮重选最大债权/债务的确定性贪心转账，同额按人员声明顺序。
- 校验先行、总额与已付/应付守恒检查、输入保留和独立转账工作数组。
- 两个黄金结算测试通过。
- 新增 23 项测试，保留前 41 项；Native/JS 各 64 项通过。
- 一项测试内另外遍历 375 组混合账单，检查金额守恒与转账回放后归零。

## 2. 新增或修改文件列表

- `shared/split.mbt`
- `shared/split_test.mbt`
- `shared/ledger.mbt`
- `moon.mod`
- `README.md`
- `AI_USAGE.md`
- `CHANGELOG.md`
- `docs/stage3-verification.json`
- `docs/BROWSER_FOLLOWUP.md`
- `docs/STAGE3_REPORT.md`

web/spliteasy.js 由 MoonBit 重新生成，网页/CLI 仍显示启动信息。
将已有阶段 1 浏览器补测报告一并带入工程文档，没有新增手机实机验收。

## 3. 所有文件完整内容

压缩包包含全部工程文件。以下提供当前工程文件的完整原文；历史阶段报告已在压缩包内保留，不将它们再次递归嵌入本报告。
本报告本身不递归嵌入；_build 缓存和 Git 内部元数据不属于源码交付。

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

## 2026-10-15 · 阶段 3

用户授权“继续下一阶段吧”。AI 实现 shared/split.mbt、核心结果类型和 23 项新增测试，并维护文档。
本阶段所有分摊、余额和转账业务逻辑均由 MoonBit 实现，没有手写业务 JavaScript。
AI 沿用用户指定的平均尾差规则和每轮重选最大债权/债务的贪心算法，同额保留人员声明顺序。
未承诺全局最少转账；用明确反例测试记录局限。

Native/JS 首次阶段 3 全量检查和测试均通过，各 64 项；一个测试内含 375 组账单及转账回放。
未删除原测试，未使用 --update 改写预期；两个黄金测试按用户给定正确预期逐字段断言。
金额合计检查沿用阶段 2；在求净额前分别累计已付和应付，通过总消费上界保证减法/债务取反安全。
实际最终版本的构建、测试、命令输出和退出码见 docs/stage3-verification.json。

阶段 1 补充浏览器验证已由 AI 使用真实 Chrome for Testing 无头引擎执行，手机部分仅屏幕/触摸能力模拟，未做真实设备验收。
测试容器安装中文字体后目视检查显示正常；未修改产品页面、未增加 CDN。
HTTP 页面断网刷新不支持，file:// 只在该测试环境通过，不能泛化为实机兼容性。

本阶段不实现文本解析、格式渲染、业务网页、CLI 参数 IO、AI API、CI 或部署。
未创建 Git commit 或推送，没有虚构人工审查和手机实测记录。

`````

### CHANGELOG.md

`````text
# Changelog

## 0.3.0 · 2026-10-15

- 阶段 3：平均分摊与尾差、实际金额分摊、多笔混合余额和确定性贪心转账。
- 新增 PersonBalance、BalanceSheet、Settlement 核心结果类型。
- 两个黄金测试验证金额和转账顺序；Native/JS 各 64 项测试通过。
- 增加 375 组混合账单守恒与转账回放检查，以及 Int64 上限、同额顺序和贪心非全局最优用例。

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

MoonBit 黑客松项目，产品规范 V3.1。当前已完成阶段 3：数据模型、金额校验、平均/实际金额分摊、混合结算和确定性转账；尚未实现业务网页表单。
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

- shared：纯 MoonBit 共享包，包含金额解析、数据模型、账单校验、分摊结算和自动化测试。
- cli/core：Native 适配包，当前转发共享启动信息。
- cli/main：Native 可执行入口。
- web：JS 可执行入口、DOM FFI、HTML 和构建脚本。
- fixtures、examples、.github/workflows：保留后续阶段目录。
- docs：实际验证日志及阶段交付记录。

只创建当前阶段所需文件；文本解析、业务网页、AI、CI、部署在后续阶段完成。
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
阶段 2 当时每个后端有 41 项测试；当前阶段 3 的测试总数见下文。
完整交付说明与源码见 docs/STAGE2_REPORT.md，实际命令记录见 docs/stage2-verification.json。

## 阶段 3：分摊与统一结算

新增公开 API：

| API | 结果 |
|---|---|
| `allocate_payment(people, payment)` | 校验后返回逐人整数分份额 |
| `calculate_balances(ledger)` | 校验后返回总消费及每人已付、应付、净额 |
| `settle_ledger(ledger)` | 校验后返回总消费、余额数组和转账数组 |

三个 API 均返回 `Result[..., String]`，错误为中文，不依赖 DOM、网络或文件系统。
结果类型是 `PersonBalance`、`BalanceSheet`、`Settlement`；这是核心数据，HTML/Markdown/JSON 输出将在阶段 5 实现。

平均模式按总人员名单 Ledger.people 的相对顺序选出参与者，不依赖勾选或输入数组顺序。
A 分由 n 人分：前 n-rem 人承担 base 分，最后 rem 人承担 base+1 分。
其中 base=A/n、rem=A%n；允许金额分数小于人数，前面部分人的份额可为零。
实际金额模式保留给定整数分，输出也按总人员名单排序；省略的人不参与，显式零份额保留。
每人的净额 = 已付 - 应付，正数应收、负数应付。

转账每轮重新选择余额最大的债权人和欠款最多的债务人，同额时选总名单中靠前者。
这是确定性贪心算法，用于尽量减少转账次数，不保证数学意义上的全局最少笔数。
例如债权 13、8 分，债务 8、7、6 分时，当前算法产生 4 笔，而另一种方案可以 3 笔；测试明确保留了这个局限。

金额先分开累计已付和应付，所有非负加法检查溢出；总消费不超过 Int64 上限。
因此每人净额落在 [-Int64.MAX_VALUE, Int64.MAX_VALUE] 内，做差和债务取反均安全。
每笔转账后至少一人的剩余余额归零，最终全部归零；原账单与结果余额不被转账过程修改。
当前使用顺序扫描，适用于小型 AA 账单，不宣称大规模最优性能。

黄金测试 A：总消费 460.00 元；净额 +181.67、+15.00、-78.33、-118.34 元。
转账依次为小美→小明 118.34、小刚→小明 63.33、小刚→小红 15.00 元。

黄金测试 B：总消费 275.00 元；净额 +148.00、+20.00、-58.00、-54.00、-56.00 元。
转账依次为小刚→小明 58.00、小李→小明 56.00、小美→小明 34.00、小美→小红 20.00 元。

执行 `make test`，Native 和 JS 各应显示 64 项通过，其中一个测试遍历 375 组账单。
两个黄金测试本阶段以结构化账单输入验证，不包含尚未实现的高级文本解析。
原始命令结果见 docs/stage3-verification.json，完整交付说明见 docs/STAGE3_REPORT.md。

浏览器补充验证：已在 Linux Chrome for Testing 133 上验证阶段 1 启动页和手机尺寸模拟；真实手机仍未验证。
通过 HTTP 打开的启动页尚不支持断网刷新，不能把保留静态显示当作离线分账验收。

阶段 1 浏览器补测的完整记录见 docs/BROWSER_FOLLOWUP.md；早先 browser-verification.json 保留初次验证时的历史状态。

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

### docs/BROWSER_FOLLOWUP.md

`````text
# SplitEasy 阶段 1 浏览器补充验证报告

结论：已代为完成真实 Chrome 浏览器引擎自动化验证，以及手机屏幕/触摸能力模拟验证；没有真实手机设备验收。

## 验证范围

- 对象：原始 SplitEasy-stage1.zip 中的 index.html 和 MoonBit 编译生成的 spliteasy.js。
- 环境：Linux、Playwright、Google Chrome for Testing 133.0.6943.16，无头浏览器。
- 未使用用户的电脑、手机或浏览器会话。
- 测试浏览器来自 Google 官方下载站。不是对当前最新版 Chrome 的兼容性承诺。
- 未修改网页源码，未进入下一开发阶段。

| 检查 | 结果 |
|---|---|
| 桌面 1280×800，通过本地 HTTP 加载 | 通过 |
| 手机竖屏模拟 390×844 | 通过 |
| 手机横屏模拟 844×390 | 通过 |
| 窄屏手机模拟 320×640 | 通过 |
| MoonBit 启动信息 | 四种尺寸均正确显示 |
| 页面横向溢出 | 四种尺寸均无 |
| 正文计算字号 | 16px |
| JavaScript/控制台错误 | 四种尺寸均无 |
| 页面和脚本请求失败 | 四种尺寸均无 |
| 外部网络请求 | 未观察到 |
| 中文显示 | 补齐测试容器中文字体后目视正常 |
| 已加载页面断网后保留显示 | 通过，仅检查静态启动页 |
| file:// 本地打开及断网刷新 | 当前测试浏览器通过 |
| HTTP 页面断网刷新 | 不支持，观察到 ERR_INTERNET_DISCONNECTED |

HTTP 离线刷新不支持是当前没有 Service Worker/离线缓存的实际限制；不把它写为通过。
file:// 的成功只适用于本次 Linux Chrome 测试环境，不代表所有浏览器及手机均兼容。
页面尚无消费输入或分账交互，不能验证断网分账、复制、草稿或触摸操作。

## 目视检查与环境修复

首轮截图中文字显示方框，确认测试容器没有中文字体。
从 Noto 官方仓库安装 Noto Sans CJK SC 字体后重新运行同一套测试，结果通过，手机竖屏截图中文字正常。
这项修复只影响测试环境，没有为网页增加 CDN 或外部字体请求。
截图仅用于内部视觉检查，不作为本报告的交付附件。

## 仍需要真实设备完成的检查

- iPhone Safari、Android Chrome 或用户实际使用的系统浏览器。
- 真实手机触摸、系统字号缩放、地址栏变化和实际设备字体。
- 用户 Windows 电脑与本地防火墙、同一 Wi-Fi 的访问链路。
- 阶段 6 完成后的业务交互、断网计算和剪贴板权限。

因此，阶段 1 的桌面浏览器引擎及手机尺寸模拟检查已补齐；真实手机验收保持“未验证”。
历史交付包中早先记录的“浏览器未验证”是当时状态，本报告是后续补充结果。

## 原始结果

```json
{
  "tested_at": "2026-10-15T05:02:05.945Z",
  "source": "Original SplitEasy-stage1.zip web files",
  "engine": "Google Chrome for Testing headless",
  "browser_version": "133.0.6943.16",
  "real_phone_tested": false,
  "real_windows_tested": false,
  "cases": [
    {
      "name": "desktop",
      "profile": {
        "viewport": {
          "width": 1280,
          "height": 800
        }
      },
      "httpStatus": 200,
      "state": {
        "title": "SplitEasy · 工程验证",
        "lang": "zh-CN",
        "status": "SplitEasy: MoonBit shared core ready.",
        "heading": "SplitEasy · AA 分账器",
        "viewportWidth": 1280,
        "scrollWidth": 1280,
        "fontSize": "16px",
        "statusBox": {
          "x": 344,
          "y": 195.890625,
          "width": 592,
          "height": 25.59375,
          "top": 195.890625,
          "right": 936,
          "bottom": 221.484375,
          "left": 344
        }
      },
      "consoleErrors": [],
      "failedRequests": [],
      "externalRequests": [],
      "offlineLoadedPageRetained": true,
      "passed": true
    },
    {
      "name": "mobile_portrait_emulation",
      "profile": {
        "viewport": {
          "width": 390,
          "height": 844
        },
        "isMobile": true,
        "hasTouch": true,
        "deviceScaleFactor": 3
      },
      "httpStatus": 200,
      "state": {
        "title": "SplitEasy · 工程验证",
        "lang": "zh-CN",
        "status": "SplitEasy: MoonBit shared core ready.",
        "heading": "SplitEasy · AA 分账器",
        "viewportWidth": 390,
        "scrollWidth": 390,
        "fontSize": "16px",
        "statusBox": {
          "x": 48,
          "y": 221.484375,
          "width": 294,
          "height": 51.1875,
          "top": 221.484375,
          "right": 342,
          "bottom": 272.671875,
          "left": 48
        }
      },
      "consoleErrors": [],
      "failedRequests": [],
      "externalRequests": [],
      "offlineLoadedPageRetained": true,
      "passed": true
    },
    {
      "name": "mobile_landscape_emulation",
      "profile": {
        "viewport": {
          "width": 844,
          "height": 390
        },
        "isMobile": true,
        "hasTouch": true,
        "deviceScaleFactor": 3
      },
      "httpStatus": 200,
      "state": {
        "title": "SplitEasy · 工程验证",
        "lang": "zh-CN",
        "status": "SplitEasy: MoonBit shared core ready.",
        "heading": "SplitEasy · AA 分账器",
        "viewportWidth": 844,
        "scrollWidth": 844,
        "fontSize": "16px",
        "statusBox": {
          "x": 126,
          "y": 195.890625,
          "width": 592,
          "height": 25.59375,
          "top": 195.890625,
          "right": 718,
          "bottom": 221.484375,
          "left": 126
        }
      },
      "consoleErrors": [],
      "failedRequests": [],
      "externalRequests": [],
      "offlineLoadedPageRetained": true,
      "passed": true
    },
    {
      "name": "narrow_mobile_emulation",
      "profile": {
        "viewport": {
          "width": 320,
          "height": 640
        },
        "isMobile": true,
        "hasTouch": true,
        "deviceScaleFactor": 2
      },
      "httpStatus": 200,
      "state": {
        "title": "SplitEasy · 工程验证",
        "lang": "zh-CN",
        "status": "SplitEasy: MoonBit shared core ready.",
        "heading": "SplitEasy · AA 分账器",
        "viewportWidth": 320,
        "scrollWidth": 320,
        "fontSize": "16px",
        "statusBox": {
          "x": 48,
          "y": 259.875,
          "width": 224,
          "height": 51.1875,
          "top": 259.875,
          "right": 272,
          "bottom": 311.0625,
          "left": 48
        }
      },
      "consoleErrors": [],
      "failedRequests": [],
      "externalRequests": [],
      "offlineLoadedPageRetained": true,
      "passed": true
    },
    {
      "name": "file_url_online_and_offline_reload",
      "passed": true,
      "consoleErrors": []
    },
    {
      "name": "http_offline_reload_without_service_worker",
      "offlineReloadSupported": false,
      "observedError": "page.reload: net::ERR_INTERNET_DISCONNECTED\nCall log:\n\u001b[2m  - waiting for navigation until \"load\"\u001b[22m\n",
      "expectedLimitationObserved": true
    }
  ],
  "source_hashes": {
    "index.html": "7a5bd0c58238ff6717e6b5ae50565c74413b5e95bb127ec62e2a5a1b86bf2fbc",
    "spliteasy.js": "ef9c9f53975108a3d6b9c243bd656a909e90a3928f3b372618c6c4b9e13bbaa1"
  },
  "serverRequests": [
    "/",
    "/spliteasy.js",
    "/",
    "/spliteasy.js",
    "/",
    "/spliteasy.js",
    "/",
    "/spliteasy.js",
    "/",
    "/spliteasy.js"
  ],
  "passed": true
}
```

## 可复现测试脚本

需要 Node.js、Playwright 和可运行的 Chromium/Chrome，脚本默认路径为本次环境路径。
复现时可设置 SPLITEASY_WEB_ROOT 为解压后 web 目录，SPLITEASY_CHROME 为浏览器可执行路径；同时调整 require 路径为本机 Playwright 安装路径。

```javascript
const {chromium}=require('/opt/codex/runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const http=require('http');const fs=require('fs');const path=require('path');const assert=require('assert/strict');const crypto=require('crypto');
(async()=>{
 const root=process.env.SPLITEASY_WEB_ROOT||'/tmp/spliteasy-stage1-browser/spliteasy/web';
 const out=__dirname;const requests=[];
 const server=http.createServer((req,res)=>{
  requests.push(req.url);const name=req.url==='/'?'index.html':req.url.slice(1);
  if(name==='favicon.ico'){res.writeHead(204).end();return;}
  if(!['index.html','spliteasy.js'].includes(name)){res.writeHead(404).end();return;}
  res.setHeader('Content-Type',name.endsWith('.js')?'text/javascript':'text/html; charset=utf-8');
  fs.createReadStream(path.join(root,name)).pipe(res);
 });
 await new Promise(r=>server.listen(0,'127.0.0.1',r));let browser;
 const result={tested_at:new Date().toISOString(),source:'Original SplitEasy-stage1.zip web files',engine:'Google Chrome for Testing headless',browser_version:null,real_phone_tested:false,real_windows_tested:false,cases:[],source_hashes:{}};
 for(const name of ['index.html','spliteasy.js'])result.source_hashes[name]=crypto.createHash('sha256').update(fs.readFileSync(path.join(root,name))).digest('hex');
 try{
  browser=await chromium.launch({executablePath:process.env.SPLITEASY_CHROME||'/tmp/spliteasy-chrome/chrome-headless-shell-linux64/chrome-headless-shell',headless:true,args:['--no-sandbox']});
  result.browser_version=browser.version();const base=`http://127.0.0.1:${server.address().port}`;
  const expected='SplitEasy: MoonBit shared core ready.';
  const profiles=[{name:'desktop',viewport:{width:1280,height:800}},{name:'mobile_portrait_emulation',viewport:{width:390,height:844},isMobile:true,hasTouch:true,deviceScaleFactor:3},{name:'mobile_landscape_emulation',viewport:{width:844,height:390},isMobile:true,hasTouch:true,deviceScaleFactor:3},{name:'narrow_mobile_emulation',viewport:{width:320,height:640},isMobile:true,hasTouch:true,deviceScaleFactor:2}];
  for(const profile of profiles){
   const {name,...options}=profile;const context=await browser.newContext(options);const page=await context.newPage();const errors=[];const failed=[];const external=[];
   page.on('pageerror',e=>errors.push(e.message));page.on('console',msg=>{if(msg.type()==='error')errors.push(msg.text());});
   page.on('requestfailed',req=>failed.push({url:req.url(),error:req.failure()}));page.on('request',req=>{if(!req.url().startsWith(base))external.push(req.url());});
   const response=await page.goto(base);await page.waitForFunction(()=>document.getElementById('status').textContent==='SplitEasy: MoonBit shared core ready.');
   const state=await page.evaluate(()=>({title:document.title,lang:document.documentElement.lang,status:document.getElementById('status').textContent,heading:document.querySelector('h1').textContent,viewportWidth:innerWidth,scrollWidth:document.documentElement.scrollWidth,fontSize:getComputedStyle(document.body).fontSize,statusBox:document.getElementById('status').getBoundingClientRect().toJSON()}));
   assert.equal(response.status(),200);assert.equal(state.status,expected);assert.equal(state.lang,'zh-CN');assert.ok(state.scrollWidth<=state.viewportWidth);assert.equal(state.fontSize,'16px');assert.deepEqual(errors,[]);assert.deepEqual(failed,[]);assert.deepEqual(external,[]);
   // Internal visual QA only; screenshots are not deliverables.
   await page.screenshot({path:path.join('/tmp',`spliteasy-${name}.png`),fullPage:true});
   await context.setOffline(true);const retained=await page.locator('#status').innerText();assert.equal(retained,expected);
   result.cases.push({name,profile:options,httpStatus:response.status(),state,consoleErrors:errors,failedRequests:failed,externalRequests:external,offlineLoadedPageRetained:retained===expected,passed:true});await context.close();
  }
  const fileContext=await browser.newContext();const filePage=await fileContext.newPage();const fileErrors=[];filePage.on('pageerror',e=>fileErrors.push(e.message));
  await filePage.goto('file://'+path.join(root,'index.html'));assert.equal(await filePage.locator('#status').innerText(),expected);await fileContext.setOffline(true);await filePage.reload();assert.equal(await filePage.locator('#status').innerText(),expected);assert.deepEqual(fileErrors,[]);
  result.cases.push({name:'file_url_online_and_offline_reload',passed:true,consoleErrors:fileErrors});await fileContext.close();
  const offlineContext=await browser.newContext();const offlinePage=await offlineContext.newPage();await offlinePage.goto(base);await offlineContext.setOffline(true);let blocked=false;let reloadError='';
  try{await offlinePage.reload({timeout:10000});}catch(e){blocked=true;reloadError=e.message;}
  assert.ok(blocked,'HTTP offline reload should not be advertised as cached offline support');
  result.cases.push({name:'http_offline_reload_without_service_worker',offlineReloadSupported:false,observedError:reloadError,expectedLimitationObserved:true});await offlineContext.close();
  result.serverRequests=requests;result.passed=true;
 }catch(e){result.passed=false;result.error=String(e);process.exitCode=1;}
 finally{if(browser)await browser.close();await new Promise(r=>server.close(r));fs.writeFileSync(path.join(out,'results.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result,null,2));}
})().catch(e=>{console.error(e);process.exitCode=1;});

```

`````

### docs/STAGE1_REPORT.md

历史完整报告见压缩包内同名文件，内容未更改。

### docs/STAGE2_REPORT.md

历史完整报告见压缩包内同名文件，内容未更改。

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

### docs/stage3-verification.json

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
    "stderr": "Finished. moon: ran 3 tasks, now up to date\n"
  },
  {
    "command": "make check",
    "exit_code": 0,
    "stdout": "moon check --target native\nmoon check --target js\n",
    "stderr": "Finished. moon: ran 4 tasks, now up to date\nFinished. moon: ran 4 tasks, now up to date\n"
  },
  {
    "command": "make test",
    "exit_code": 0,
    "stdout": "moon test --target native\nTotal tests: 64, passed: 64, failed: 0.\nmoon test --target js\nTotal tests: 64, passed: 64, failed: 0.\n",
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

version = "0.3.0"

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
/// A positive transfer from a debtor to a creditor, expressed in integer cents.
pub(all) struct Transfer {
  from : String
  to : String
  amount_cents : Int64
} derive(Debug)

///|
pub extend Transfer with @debug.Debug::{to_repr}

///|
/// Always follows Ledger.people order. Positive balance means receivable.
pub(all) struct PersonBalance {
  person : String
  paid_cents : Int64
  owed_cents : Int64
  balance_cents : Int64
} derive(Debug)

///|
pub extend PersonBalance with @debug.Debug::{to_repr}

///|
pub(all) struct BalanceSheet {
  total_cents : Int64
  balances : Array[PersonBalance]
} derive(Debug)

///|
pub extend BalanceSheet with @debug.Debug::{to_repr}

///|
/// Core settlement data only; formatted reports belong to stage 5.
pub(all) struct Settlement {
  total_cents : Int64
  balances : Array[PersonBalance]
  transfers : Array[Transfer]
} derive(Debug)

///|
pub extend Settlement with @debug.Debug::{to_repr}

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

### shared/split.mbt

`````text
///|
/// Call only after validate_ledger. Allocate in Ledger.people order, not UI order.
fn allocate_validated(
  people : Array[String],
  payment : Payment,
) -> Array[Share] {
  let allocated : Array[Share] = []
  match payment.split_mode {
    Equal => {
      let n = payment.participants.length().to_int64()
      let base = payment.amount_cents / n
      let remainder = payment.amount_cents % n
      let mut position = 0L
      for person in people {
        if has_person(payment.participants, person) {
          let extra = if position >= n - remainder { 1L } else { 0L }
          allocated.push({ person, amount_cents: base + extra, })
          position = position + 1L
        }
      }
    }
    Exact =>
      for person in people {
        for share in payment.shares {
          if share.person == person {
            allocated.push({ person, amount_cents: share.amount_cents, })
          }
        }
      }
  }
  allocated
}

///|
/// Validate a standalone payment against the supplied declaration order.
pub fn allocate_payment(
  people : Array[String],
  payment : Payment,
) -> Result[Array[Share], String] {
  match validate_ledger({ people, payments: [payment], ambiguous: [], }) {
    Err(message) => Err(message)
    Ok(_) => Ok(allocate_validated(people, payment))
  }
}

///|
fn person_index(people : Array[String], name : String) -> Int32 {
  for i, person in people {
    if person == name {
      return i
    }
  }
  -1
}

///|
/// Validate every call, then sum paid/owed separately with checked additions.
pub fn calculate_balances(ledger : Ledger) -> Result[BalanceSheet, String] {
  match validate_ledger(ledger) {
    Err(message) => return Err(message)
    Ok(_) => ()
  }
  let paid : Array[Int64] = Array::make(ledger.people.length(), 0L)
  let owed : Array[Int64] = Array::make(ledger.people.length(), 0L)
  let mut total = 0L
  for payment in ledger.payments {
    total = match checked_add_cents(total, payment.amount_cents) {
      Ok(value) => value
      Err(message) => return Err(message)
    }
    let payer = person_index(ledger.people, payment.payer)
    if payer < 0 {
      return Err("内部错误：付款人索引无效")
    }
    paid[payer] = match checked_add_cents(paid[payer], payment.amount_cents) {
      Ok(value) => value
      Err(message) => return Err(message)
    }
    for share in allocate_validated(ledger.people, payment) {
      let person = person_index(ledger.people, share.person)
      if person < 0 {
        return Err("内部错误：份额人员索引无效")
      }
      owed[person] = match checked_add_cents(owed[person], share.amount_cents) {
        Ok(value) => value
        Err(message) => return Err(message)
      }
    }
  }
  let balances : Array[PersonBalance] = []
  let mut paid_total = 0L
  let mut owed_total = 0L
  for i, person in ledger.people {
    paid_total = match checked_add_cents(paid_total, paid[i]) {
      Ok(value) => value
      Err(message) => return Err(message)
    }
    owed_total = match checked_add_cents(owed_total, owed[i]) {
      Ok(value) => value
      Err(message) => return Err(message)
    }
    // Both operands lie in [0, total] and total <= Int64.MAX_VALUE.
    // Their difference lies in [-MAX_VALUE, MAX_VALUE], so subtraction is safe.
    balances.push({
      person,
      paid_cents: paid[i],
      owed_cents: owed[i],
      balance_cents: paid[i] - owed[i],
    })
  }
  if paid_total != total || owed_total != total {
    return Err("内部错误：已付、应付与消费总额不守恒")
  }
  Ok({ total_cents: total, balances, })
}

///|
/// Largest creditor/debtor each round. Strict comparison keeps declaration ties.
/// Greedy reduces transfers but does not guarantee a global minimum count.
fn generate_transfers(
  balances : Array[PersonBalance],
) -> Result[Array[Transfer], String] {
  let remaining = balances.map(fn(balance) { balance.balance_cents })
  let transfers : Array[Transfer] = []
  while true {
    let mut creditor = -1
    let mut debtor = -1
    let mut credit = 0L
    let mut debt = 0L
    for i, value in remaining {
      if value > credit {
        creditor = i
        credit = value
      }
      if value < debt {
        debtor = i
        debt = value
      }
    }
    if creditor == -1 && debtor == -1 {
      break
    }
    if creditor < 0 || debtor < 0 || creditor == debtor {
      return Err("内部错误：余额不守恒，无法完成转账")
    }
    // Validated total bounds every balance, so debt can never be Int64.MIN_VALUE.
    let amount = if credit < -debt { credit } else { -debt }
    if amount <= 0L {
      return Err("内部错误：转账金额必须大于零")
    }
    transfers.push({
      from: balances[debtor].person,
      to: balances[creditor].person,
      amount_cents: amount,
    })
    remaining[creditor] = credit - amount
    remaining[debtor] = debt + amount
  }
  for value in remaining {
    if value != 0L {
      return Err("内部错误：结算后余额未归零")
    }
  }
  Ok(transfers)
}

///|
/// Public entrypoint: never settle unvalidated or ambiguous input.
pub fn settle_ledger(ledger : Ledger) -> Result[Settlement, String] {
  let sheet = match calculate_balances(ledger) {
    Ok(value) => value
    Err(message) => return Err(message)
  }
  let transfers = match generate_transfers(sheet.balances) {
    Ok(value) => value
    Err(message) => return Err(message)
  }
  Ok({ total_cents: sheet.total_cents, balances: sheet.balances, transfers, })
}

`````

### shared/split_test.mbt

`````text
///|
fn stage3_ledger(
  people : Array[String],
  payments : Array[@shared.Payment],
) -> @shared.Ledger {
  { people, payments, ambiguous: [], }
}

///|
fn equal_bill(
  payer : String,
  amount : Int64,
  participants : Array[String],
) -> @shared.Payment {
  {
    payer,
    amount_cents: amount,
    split_mode: Equal,
    participants,
    shares: [],
    description: "平均",
    date: "",
  }
}

///|
fn exact_bill(
  payer : String,
  amount : Int64,
  shares : Array[@shared.Share],
) -> @shared.Payment {
  {
    payer,
    amount_cents: amount,
    split_mode: Exact,
    participants: [],
    shares,
    description: "实际金额",
    date: "",
  }
}

///|
fn must_settle(ledger : @shared.Ledger) -> @shared.Settlement raise {
  match @shared.settle_ledger(ledger) {
    Ok(value) => value
    Err(message) => fail(message)
  }
}

///|
fn must_allocate(
  people : Array[String],
  payment : @shared.Payment,
) -> Array[@shared.Share] raise {
  match @shared.allocate_payment(people, payment) {
    Ok(value) => value
    Err(message) => fail(message)
  }
}

///|
fn check_shares(
  actual : Array[@shared.Share],
  names : Array[String],
  amounts : Array[Int64],
) -> Unit raise {
  assert_eq(actual.length(), names.length())
  assert_eq(actual.length(), amounts.length())
  for i, share in actual {
    assert_eq(share.person, names[i])
    assert_eq(share.amount_cents, amounts[i])
  }
}

///|
fn check_balances(
  actual : Array[@shared.PersonBalance],
  names : Array[String],
  paid : Array[Int64],
  owed : Array[Int64],
  net : Array[Int64],
) -> Unit raise {
  assert_eq(actual.length(), names.length())
  for i, balance in actual {
    assert_eq(balance.person, names[i])
    assert_eq(balance.paid_cents, paid[i])
    assert_eq(balance.owed_cents, owed[i])
    assert_eq(balance.balance_cents, net[i])
  }
}

///|
fn check_transfers(
  actual : Array[@shared.Transfer],
  expected : Array[(String, String, Int64)],
) -> Unit raise {
  assert_eq(actual.length(), expected.length())
  for i, transfer in actual {
    let (from, to, amount) = expected[i]
    assert_eq(transfer.from, from)
    assert_eq(transfer.to, to)
    assert_eq(transfer.amount_cents, amount)
  }
}

///|
fn test_person_index(
  balances : Array[@shared.PersonBalance],
  person : String,
) -> Int32 raise {
  for i, balance in balances {
    if balance.person == person {
      return i
    }
  }
  fail("unknown person in transfers")
}

///|
/// Independent replay checks conservation and legal directions for every transfer.
fn check_settlement_invariants(result : @shared.Settlement) -> Unit raise {
  let remaining = result.balances.map(fn(balance) { balance.balance_cents })
  let mut paid = 0L
  let mut owed = 0L
  let mut credit = 0L
  let mut debt = 0L
  let mut nonzero = 0
  for balance in result.balances {
    assert_true(balance.paid_cents >= 0L)
    assert_true(balance.owed_cents >= 0L)
    assert_eq(balance.balance_cents, balance.paid_cents - balance.owed_cents)
    paid = paid + balance.paid_cents
    owed = owed + balance.owed_cents
    if balance.balance_cents > 0L {
      credit = credit + balance.balance_cents
      nonzero = nonzero + 1
    } else if balance.balance_cents < 0L {
      debt = debt - balance.balance_cents
      nonzero = nonzero + 1
    }
  }
  assert_eq(paid, result.total_cents)
  assert_eq(owed, result.total_cents)
  assert_eq(credit, debt)
  for transfer in result.transfers {
    assert_true(transfer.from != transfer.to)
    assert_true(transfer.amount_cents > 0L)
    let from = test_person_index(result.balances, transfer.from)
    let to = test_person_index(result.balances, transfer.to)
    assert_true(remaining[from] < 0L)
    assert_true(remaining[to] > 0L)
    assert_true(transfer.amount_cents <= -remaining[from])
    assert_true(transfer.amount_cents <= remaining[to])
    remaining[from] = remaining[from] + transfer.amount_cents
    remaining[to] = remaining[to] - transfer.amount_cents
  }
  for balance in remaining {
    assert_eq(balance, 0L)
  }
  if nonzero == 0 {
    assert_eq(result.transfers.length(), 0)
  } else {
    assert_true(result.transfers.length() <= nonzero - 1)
  }
}

///|
test "equal allocation remainder goes to last declared participants" {
  let names = ["A", "B", "C"]
  check_shares(
    must_allocate(names, equal_bill("A", 10000L, ["C", "A", "B"])),
    names,
    [3333L, 3333L, 3334L],
  )
}

///|
test "equal allocation subset uses ledger order" {
  check_shares(
    must_allocate(["A", "B", "C", "D"], equal_bill("A", 5L, ["D", "B", "C"])),
    ["B", "C", "D"],
    [1L, 2L, 2L],
  )
}

///|
test "equal allocation divisible and single person" {
  check_shares(
    must_allocate(["A", "B"], equal_bill("A", 10L, ["A", "B"])),
    ["A", "B"],
    [5L, 5L],
  )
  check_shares(
    must_allocate(["A"], equal_bill("A", 9223372036854775807L, ["A"])),
    ["A"],
    [9223372036854775807L],
  )
}

///|
test "equal allocation less cents than participants" {
  check_shares(
    must_allocate(["A", "B", "C"], equal_bill("A", 1L, ["A", "B", "C"])),
    ["A", "B", "C"],
    [0L, 0L, 1L],
  )
}

///|
test "exact allocation preserves values and orders by ledger" {
  let bill = exact_bill("A", 75L, [
    { person: "C", amount_cents: 50L, },
    { person: "A", amount_cents: 25L, },
    { person: "B", amount_cents: 0L, },
  ])
  check_shares(must_allocate(["A", "B", "C", "D"], bill), ["A", "B", "C"], [
    25L, 0L, 50L,
  ])
  assert_eq(bill.shares[0].person, "C")
}

///|
test "allocation validates empty or unknown input before division" {
  for
    bill in [
      equal_bill("A", 1L, []),
      equal_bill("A", 1L, ["unknown"]),
      exact_bill("A", 1L, []),
    ] {
    match @shared.allocate_payment(["A"], bill) {
      Err(_) => ()
      Ok(_) => fail("invalid allocation accepted")
    }
  }
}

///|
test "golden A four person dinner" {
  let names = ["小明", "小红", "小刚", "小美"]
  let ledger = stage3_ledger(names, [
    equal_bill("小明", 30000L, names),
    equal_bill("小红", 12000L, names),
    equal_bill("小刚", 4000L, ["小明", "小刚", "小美"]),
  ])
  let result = must_settle(ledger)
  assert_eq(result.total_cents, 46000L)
  check_balances(
    result.balances,
    names,
    [30000L, 12000L, 4000L, 0L],
    [11833L, 10500L, 11833L, 11834L],
    [18167L, 1500L, -7833L, -11834L],
  )
  check_transfers(result.transfers, [
    ("小美", "小明", 11834L),
    ("小刚", "小明", 6333L),
    ("小刚", "小红", 1500L),
  ])
  check_settlement_invariants(result)
}

///|
test "golden B five person mixed dinner and milk tea" {
  let names = ["小明", "小红", "小刚", "小美", "小李"]
  let ledger = stage3_ledger(names, [
    equal_bill("小明", 20000L, names),
    exact_bill("小红", 7500L, [
      { person: "小明", amount_cents: 1200L, },
      { person: "小红", amount_cents: 1500L, },
      { person: "小刚", amount_cents: 1800L, },
      { person: "小美", amount_cents: 1400L, },
      { person: "小李", amount_cents: 1600L, },
    ]),
  ])
  let result = must_settle(ledger)
  assert_eq(result.total_cents, 27500L)
  check_balances(
    result.balances,
    names,
    [20000L, 7500L, 0L, 0L, 0L],
    [5200L, 5500L, 5800L, 5400L, 5600L],
    [14800L, 2000L, -5800L, -5400L, -5600L],
  )
  check_transfers(result.transfers, [
    ("小刚", "小明", 5800L),
    ("小李", "小明", 5600L),
    ("小美", "小明", 3400L),
    ("小美", "小红", 2000L),
  ])
  check_settlement_invariants(result)
}

///|
test "no payments produces all zero and no transfers" {
  let result = must_settle(stage3_ledger(["A", "B"], []))
  check_balances(result.balances, ["A", "B"], [0L, 0L], [0L, 0L], [0L, 0L])
  assert_eq(result.total_cents, 0L)
  check_settlement_invariants(result)
}

///|
test "self payment and already balanced ledger need no transfers" {
  for
    ledger in [
      stage3_ledger(["A"], [equal_bill("A", 100L, ["A"])]),
      stage3_ledger(["A", "B"], [
        equal_bill("A", 10L, ["A", "B"]),
        equal_bill("B", 10L, ["A", "B"]),
      ]),
    ] {
    let result = must_settle(ledger)
    assert_eq(result.transfers.length(), 0)
    check_settlement_invariants(result)
  }
}

///|
test "payer outside consumers and zero shares" {
  let result = must_settle(
    stage3_ledger(["A", "B", "C"], [
      exact_bill("A", 100L, [
        { person: "B", amount_cents: 100L, },
        { person: "C", amount_cents: 0L, },
      ]),
    ]),
  )
  check_balances(
    result.balances,
    ["A", "B", "C"],
    [100L, 0L, 0L],
    [0L, 100L, 0L],
    [100L, -100L, 0L],
  )
  check_transfers(result.transfers, [("B", "A", 100L)])
  check_settlement_invariants(result)
}

///|
test "equal payer outside consumers" {
  let result = must_settle(
    stage3_ledger(["A", "B", "C"], [equal_bill("A", 3L, ["C", "B"])]),
  )
  check_balances(result.balances, ["A", "B", "C"], [3L, 0L, 0L], [0L, 1L, 2L], [
    3L, -1L, -2L,
  ])
  check_transfers(result.transfers, [("C", "A", 2L), ("B", "A", 1L)])
}

///|
test "tie break follows people declaration for both signs" {
  let names = ["C2", "D2", "C1", "D1"]
  let ledger = stage3_ledger(names, [
    exact_bill("C1", 10L, [{ person: "D1", amount_cents: 10L, }]),
    exact_bill("C2", 10L, [{ person: "D2", amount_cents: 10L, }]),
  ])
  let result = must_settle(ledger)
  check_transfers(result.transfers, [("D2", "C2", 10L), ("D1", "C1", 10L)])
  check_settlement_invariants(result)
}

///|
test "largest creditor is chosen anew each round" {
  let result = must_settle(
    stage3_ledger(["C1", "C2", "D1", "D2", "D3"], [
      exact_bill("C1", 10L, [
        { person: "D1", amount_cents: 7L, },
        { person: "D2", amount_cents: 3L, },
      ]),
      exact_bill("C2", 8L, [
        { person: "D2", amount_cents: 3L, },
        { person: "D3", amount_cents: 5L, },
      ]),
    ]),
  )
  check_transfers(result.transfers, [
    ("D1", "C1", 7L),
    ("D2", "C2", 6L),
    ("D3", "C1", 3L),
    ("D3", "C2", 2L),
  ])
  check_settlement_invariants(result)
}

///|
test "repeat payer accumulates both allocation modes" {
  let result = must_settle(
    stage3_ledger(["A", "B"], [
      equal_bill("A", 100L, ["A", "B"]),
      exact_bill("A", 75L, [{ person: "B", amount_cents: 75L, }]),
    ]),
  )
  check_balances(result.balances, ["A", "B"], [175L, 0L], [50L, 125L], [
    125L, -125L,
  ])
  check_transfers(result.transfers, [("B", "A", 125L)])
  check_settlement_invariants(result)
}

///|
test "maximum cent amount stays exact during transfers" {
  let result = must_settle(
    stage3_ledger(["A", "B"], [
      exact_bill("A", 9223372036854775807L, [
        { person: "B", amount_cents: 9223372036854775807L, },
      ]),
    ]),
  )
  check_transfers(result.transfers, [("B", "A", 9223372036854775807L)])
  check_settlement_invariants(result)
}

///|
test "maximum equal amount allocates without overflow" {
  let result = must_settle(
    stage3_ledger(["A", "B"], [
      equal_bill("A", 9223372036854775807L, ["A", "B"]),
    ]),
  )
  check_balances(
    result.balances,
    ["A", "B"],
    [9223372036854775807L, 0L],
    [4611686018427387903L, 4611686018427387904L],
    [4611686018427387904L, -4611686018427387904L],
  )
  check_settlement_invariants(result)
}

///|
test "JS unsafe integer boundary survives balance computation" {
  let result = must_settle(
    stage3_ledger(["A", "B"], [
      exact_bill("A", 9007199254740993L, [
        { person: "B", amount_cents: 9007199254740993L, },
      ]),
    ]),
  )
  check_transfers(result.transfers, [("B", "A", 9007199254740993L)])
  check_settlement_invariants(result)
}

///|
test "public settlement rejects overflow and ambiguity" {
  let overflow = stage3_ledger(["A"], [
    equal_bill("A", 9223372036854775807L, ["A"]),
    equal_bill("A", 1L, ["A"]),
  ])
  match @shared.settle_ledger(overflow) {
    Err(message) =>
      assert_eq(
        message, "第 2 笔消费：金额合计超出 Int64 整数分范围",
      )
    Ok(_) => fail("overflow accepted")
  }
  match
    @shared.settle_ledger({
      ..stage3_ledger(["A"], []),
      ambiguous: ["付款人不明"],
    }) {
    Err(message) => assert_eq(message, "账单存在歧义：付款人不明")
    Ok(_) => fail("ambiguity accepted")
  }
}

///|
test "public balance and settlement revalidate bad inputs" {
  let ledger = stage3_ledger(["A", "B"], [
    exact_bill("A", 100L, [{ person: "B", amount_cents: 99L, }]),
  ])
  match @shared.calculate_balances(ledger) {
    Err(message) =>
      assert_eq(
        message, "第 1 笔消费：个人分摊金额合计必须等于消费总金额",
      )
    Ok(_) => fail("invalid balance input accepted")
  }
  match @shared.settle_ledger(stage3_ledger([], [])) {
    Err(message) => assert_eq(message, "参与人员不能为空")
    Ok(_) => fail("empty people accepted")
  }
}

///|
test "settlement deterministic and input independent from output mutation" {
  let people = ["A", "B", "C"]
  let participants = ["C", "A", "B"]
  let ledger = stage3_ledger(people, [equal_bill("A", 10000L, participants)])
  let first = must_settle(ledger)
  for _ in 0..<5 {
    let next = must_settle(ledger)
    check_transfers(next.transfers, [("C", "A", 3334L), ("B", "A", 3333L)])
    check_settlement_invariants(next)
  }
  first.transfers.clear()
  first.balances.clear()
  assert_eq(people[0], "A")
  assert_eq(participants[0], "C")
  assert_eq(ledger.payments[0].amount_cents, 10000L)
  assert_eq(must_settle(ledger).transfers.length(), 2)
}

///|
test "greedy does not promise global minimum count" {
  let result = must_settle(
    stage3_ledger(["C1", "C2", "D1", "D2", "D3"], [
      exact_bill("C1", 13L, [
        { person: "D2", amount_cents: 7L, },
        { person: "D3", amount_cents: 6L, },
      ]),
      exact_bill("C2", 8L, [{ person: "D1", amount_cents: 8L, }]),
    ]),
  )
  check_transfers(result.transfers, [
    ("D1", "C1", 8L),
    ("D2", "C2", 7L),
    ("D3", "C1", 5L),
    ("D3", "C2", 1L),
  ])
  check_settlement_invariants(result)
  // A different 3-transfer solution exists: D1->C2 8, D2->C1 7, D3->C1 6.
}

///|
test "bounded mixed ledgers conserve and fully settle across 375 cases" {
  let all_names = ["A", "B", "C", "D", "E"]
  let mut cases = 0
  for n in 1..<6 {
    let names : Array[String] = []
    for i in 0..<n {
      names.push(all_names[i])
    }
    for amount in 1..<26 {
      for payer in 0..<n {
        let ledger = stage3_ledger(names, [
          equal_bill(names[payer], amount.to_int64(), names),
          exact_bill(names[(payer + 1) % n], (amount + 2).to_int64(), [
            {
              person: names[(payer + 2) % n],
              amount_cents: (amount + 2).to_int64(),
            },
          ]),
        ])
        check_settlement_invariants(must_settle(ledger))
        cases = cases + 1
      }
    }
  }
  assert_eq(cases, 375)
}

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

解压后进入 spliteasy 根目录，使用已安装的 MoonBit 工具链：

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

Windows 原生命令行尚未实测，可使用 WSL。环境要求见 README。
黄金测试以结构化数据执行；高级文本语法将在阶段 4 接入，不能用当前 CLI 执行 split 命令。

## 5. 每条命令的预期输出

| 命令 | 预期 |
|---|---|
| export PATH | 无输出，当前终端能找到 moon |
| moon version | 已安装 moon 版本，退出 0 |
| moonc -v | 编译器版本，退出 0 |
| moon fmt | 格式化成功，退出 0 |
| make check | Native/JS 无错误，退出 0 |
| make test | 两个后端各显示 Total tests: 64, passed: 64, failed: 0. |
| make build-native | Native 构建成功，退出 0 |
| make run-cli | SplitEasy: MoonBit shared core ready. |
| make build-web | 已生成 web/spliteasy.js，退出 0 |

IIFE 构建仍可能出现 TypeScript 声明仅支持 ESM 的提示，不影响当前 JS 构建。

## 6. 实际运行结果

实际环境：moon 0.1.20261012 (748b63c 2026-10-12)，moonc v0.10.15+943464bfa (2026-10-12)。
全部上述检查、测试和构建命令实际退出 0，Native/JS 均 64 项通过、0 失败。
Native 启动程序实际运行，JS IIFE 产物实际生成。
命令及 stdout、stderr、退出码保存在 docs/stage3-verification.json。

### 黄金测试 A：四人晚餐

总消费 460.00 元。

| 人员 | 已付 | 应付 | 净额 |
|---|---:|---:|---:|
| 小明 | 300.00 | 118.33 | +181.67 |
| 小红 | 120.00 | 105.00 | +15.00 |
| 小刚 | 40.00 | 118.33 | -78.33 |
| 小美 | 0.00 | 118.34 | -118.34 |

转账顺序：小美→小明 118.34；小刚→小明 63.33；小刚→小红 15.00 元。
所有金额与顺序均在两个后端逐字段断言通过。

### 黄金测试 B：五人混合分摊

总消费 275.00 元。

| 人员 | 已付 | 应付 | 净额 |
|---|---:|---:|---:|
| 小明 | 200.00 | 52.00 | +148.00 |
| 小红 | 75.00 | 55.00 | +20.00 |
| 小刚 | 0.00 | 58.00 | -58.00 |
| 小美 | 0.00 | 54.00 | -54.00 |
| 小李 | 0.00 | 56.00 | -56.00 |

转账顺序：小刚→小明 58.00；小李→小明 56.00；小美→小明 34.00；小美→小红 20.00 元。
所有金额与顺序均在两个后端逐字段断言通过。

### 其他验证

- 10000 分三人分为 3333、3333、3334；参与者数组打乱后仍按总名单分配。
- 子集分摊、可分尽、单人、金额分数小于人数。
- Exact 输入顺序打乱、显式零份额、人员省略、付款人不消费。
- 无消费、已平账、自付自消费时没有多余转账。
- 多笔同一付款人、每轮最大债权人重新选择、同额双方顺序。
- Int64 最大值、超过 JS 安全整数范围的金额，双端精确。
- 溢出和歧义通过公开入口拒绝，非法份额和空人员拒绝。
- 重复执行得到相同转账，输出数组修改不改变原账单或下次结果。
- 375 组小账单的已付/应付守恒、净额守恒、转账方向、正金额、无自转账、回放后全归零。
- 当前贪心算法可能比其他方案多一笔的反例，确保不宣传全局最优。

## 7. 未验证事项

- 阶段 4 文本输入解析；当前黄金测试不包含文本解析器。
- 阶段 5 HTML、Markdown、JSON 输出与完整报表。
- 业务网页、消费表单、复制结果、本地草稿、CLI 文件和参数 IO、AI、CI、Pages。
- 真实手机、用户 Windows 系统、本地网络和系统剪贴板行为。
- 大规模账单性能、全局最少笔数算法；当前不承诺这些能力。
- GitHub 远程仓库、提交、赛事资格与报名。

阶段 1 的真实 Chrome 引擎和手机尺寸模拟已补测通过，详见 docs/BROWSER_FOLLOWUP.md；它不能替代真实手机。

## 8. 错误及修复说明

本阶段首次编译检查和新增测试即通过，无失败断言需要修正。
沿用当前工具链语法、显式 pub extend，最终检查无编译警告。
保留全部旧测试，新增测试未使用 --update 改写预期。
网页 IIFE 构建的 TypeScript 声明提示仍为已知工具链限制，没有将其伪装成运行失败或删除日志。
浏览器此前的字体修复只发生在测试容器，网页源码没有新增字体下载或 CDN。

## 9. 简单中文技术解释

先把每笔消费转换为各人的份额，再把每人付出的钱和该承担的钱分别相加。
净额 = 已付 - 应付。正数是应收钱，负数是应付钱。

平均分摊按 Ledger.people 中的相对顺序选择参与者，余下几分钱分给最后几位。
所以用户勾选参与者的先后不会悄悄改变尾差归属。
实际金额分摊保留原整数分，输出仍按总名单排序。

转账每轮重新找到应收最多的人和欠钱最多的人，转双方可结清的较小金额。
同额时不覆盖先找到的人，因此保持名单顺序。
每轮至少结清一人，若有 k 个非零余额，最多产生 k-1 笔，零余额不会转账。
这不保证数学意义上的全局最少笔数：债权为 13、8，债务为 8、7、6 时，本算法 4 笔，另有 3 笔方案。

所有已付、应付及总消费都用非负整数安全累加，总消费不大于 Int64.MAX_VALUE。
因此每人净额在 [-MAX_VALUE, MAX_VALUE] 以内，减法不会越界，也不可能出现无法取反的 Int64.MIN_VALUE。
转账使用净额数组的副本，原始已付、应付和净额保留供后续报表使用。

| API/类型 | 用途 |
|---|---|
| allocate_payment | 校验一笔消费并返回逐人份额 |
| calculate_balances | 每次先校验，再计算总消费和余额数组 |
| settle_ledger | 先校验和算余额，再生成确定性的转账 |
| PersonBalance | 姓名、已付、应付、净额，金额均为 Int64 分 |
| BalanceSheet | 总消费和按名单排序的余额数组 |
| Settlement | 总消费、原余额数组、确定顺序的转账数组 |

Settlement 是核心数据，不是阶段 5 的格式化报表；网页和 CLI 未来直接复用这些 MoonBit API。
当前采用顺序扫描，适合小型 AA 账单，不宣称大规模最优效率。

## 10. 本阶段验收标准

- [x] 平均分摊符合“前少后多”的尾差规则。
- [x] 实际金额分摊保留精确金额，零份额允许。
- [x] 支持付款人不参与、重复付款人、多笔混合模式。
- [x] 每人已付、应付、净额及总消费准确。
- [x] 贪心每轮重新选择最大余额，同额按人员声明顺序。
- [x] 两个黄金测试的金额与转账顺序完全符合方案。
- [x] 正金额、无自转账、守恒和回放后归零检查通过。
- [x] 大整数、Int64 边界和非法输入验证通过。
- [x] Native/JS 各 64 项测试通过，检查和构建成功。
- [x] 业务逻辑仅在 shared MoonBit 包，未提前进入阶段 4。

## 11. Git commit 建议

```bash
git add shared/ledger.mbt shared/split.mbt shared/split_test.mbt moon.mod README.md AI_USAGE.md CHANGELOG.md docs/stage3-verification.json docs/STAGE3_REPORT.md docs/BROWSER_FOLLOWUP.md
git commit -m "feat: implement mixed expense settlement and golden tests"
```

尚未实际提交或推送。此前阶段尚未提交时，这条命令不足以建立完整基线，应先提交阶段 1/2，或 git add . 后用如实描述合并范围的提交说明。
从压缩包恢复新目录时不含 Git 内部元数据；需要先 git init -b main。

## 12. 下一阶段预告

等待用户确认后执行阶段 4：高级文本格式、@ 指定、! 排除、= 实际金额、行号与中文错误。
本阶段停止，不提前开发解析器。
内部交付截止继续为 2026-10-24 23:59（Asia/Shanghai）。
