# SplitEasy V3.1 阶段 5 交付报告

## 1. 本阶段完成内容

用户指示“下一阶段”，本次只执行阶段 5：渲染与总装。
工程版本 0.5.0；产品需求版本仍为 V3.1。

- SettlementReport/PaymentReport 统一报告与 ReportFormat 输出类型。
- 结构化 Ledger 和高级文本均可走同一总入口生成 HTML、Markdown、JSON。
- 完整消费明细、逐人实际份额、总消费、已付/应付/净额、确定性转账、无消费/无转账提示。
- HTML 所有用户文本与错误转义，应收绿、应付红；提供完整文档及 DOM 片段两种形式。
- Markdown 表格、换行、特殊符号和原始 HTML 转义。
- JSON 固定 schema 和顺序，金额直接写 Int64 十进制整数数字，不经过浮点数。
- 精确元金额显示，覆盖负数与 Int64 最小值。
- 新增 21 项测试，保留旧 100 项；两个后端各 121 项通过。
- 独立黄金文件比对、Python JSON 大整数/控制字符回读、Native/JS 输出逐字一致。
- 真实 Chrome 无头引擎完成 12 组离线 HTML 页面检查，以及三种尺寸的安全错误片段检查。

不提前实现阶段 6 的人员和消费填表界面。

## 2. 新增或修改文件列表

- `shared/ledger.mbt`
- `shared/money.mbt`
- `shared/money_test.mbt`
- `shared/solve.mbt`
- `shared/solve_test.mbt`
- `shared/render_html.mbt`
- `shared/render_md.mbt`
- `shared/render_json.mbt`
- `shared/render_test.mbt`
- `examples/report/moon.pkg`
- `examples/report/main.mbt`
- `scripts/verify_reports.py`
- `scripts/verify_report_browser.cjs`
- `fixtures/expected_dinner.md`
- `fixtures/expected_mixed.json`
- `Makefile`
- `moon.mod`
- `README.md`
- `AI_USAGE.md`
- `CHANGELOG.md`
- `docs/output-format.md`
- `docs/stage5-verification.json`
- `docs/STAGE5_REPORT.md`
- `docs/generated/（全部生成样例与独立验证记录）`

web/spliteasy.js 由 MoonBit 重新生成；业务网页和正式 CLI 仍待后续阶段。
examples/report 只是预设数据的固定输出器，不含 CLI 参数解析或文件 IO。

## 3. 所有文件完整内容

压缩包内有全部当前工程文件。下面提供完整文本原文；历史阶段报告保留在压缩包内，不再次递归嵌入。
本报告自身不递归嵌入。Git 内部元数据和 _build 缓存不属于源码交付。
生成的 HTML/JSON 样例也按原文收录，截图只作内部视觉检查，没有作为附件保存。

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

## 2026-10-15 · 阶段 4

用户指示“下一阶段”，授权文本解析。AI 实现 shared/textparser.mbt、36 项新增测试、文本样例及文档。
为避免重复业务规则，将单笔校验提取为私有 validate_payment_data；原 validate_ledger 的中文错误与消费序号保留，旧 64 项测试继续通过。
解析器在逐行处理时复用单笔规则、检查总消费溢出，最后再调用总账单校验。
文本只转换为已校验 Ledger，不调用外部模型，不联网，也不做文件 IO。

实际错误与修复：
- 首次编译时范围表达式 marker_index + 1..<end 的优先级不符合预期，显式改为 (marker_index + 1)..<end。
- replace_all 需要 old/new 标签，改用 replace_all(old=..., new=...)。
- 修复后旧测试全部通过；首轮新增测试共 99 项通过，补充首个冒号边界测试后共 100 项通过。
- 没有失败断言被删除，没有 --update 改写正确预期。

最终 Native/JS 各 100 项通过，两个文本黄金测试逐字段验证净额和转账。
实际命令、标准输出、标准错误与退出码见 docs/stage4-verification.json。
文本语法的保留符号、空白规范、无日期/注释/转义/逗号简写等限制均明确写入 docs/text-format.md。
样例文件随交付包提供；当前 shared 测试以相同文本字面量执行，不把它宣称成 CLI 文件 IO 测试。
本阶段未实现输出格式、业务网页、完整 CLI、AI、CI 或部署；真实手机仍未验证。

## 2026-10-15 · 阶段 5

用户指示“下一阶段”，授权统一报表、渲染和总装。
AI 实现 SettlementReport/PaymentReport/ReportFormat、共享总入口和三种渲染，新增 21 项测试及示例/验证脚本。
所有分账与格式化逻辑在 shared MoonBit；Python/浏览器脚本只作独立验证，不参与产品业务计算。
JSON 按固定 schema 直接写 Int64 十进制数字，未经过 Double 或 JS Number；所有用户字符串正确转义。
Native 与 JS 的 121 项测试通过，Markdown 晚餐和 JSON 混合案例使用事先写定的完整预期逐字比较。
Python json 独立回读 Int64.MAX_VALUE 和 JS 安全整数外金额，全部控制字符、中文和 emoji 回读通过。
examples/report 的 Native/JS 全部输出字符串逐字一致；它没有实现正式 CLI 的参数和文件 IO。

问题与修复：
- 初版 JSON 转义调用 UInt16.to_char 返回 Char?，补充固定十六进制 ASCII 数字范围内的 unwrap 后编译通过。
- 目视检查发现手机表格姓名逐字换行，调整最小姓名列宽和数字列换行规则，再次运行输出及浏览器验证。
- 未填写日期在 HTML 中显示“未填写”，JSON/报告仍保留空字符串，不编造日期。

真实 Chrome for Testing 133 无头引擎完成 12 组离线 HTML 文档检查，以及三种尺寸下的安全错误片段检查。
覆盖注入字符串不会生成 script/img 元素、无弹窗、无外部网络请求、页面不横向溢出，应收/应付颜色正确。
截图只用于内部视觉检查，没有把模拟截图当作手机实测证据或保存为交付附件。
真实手机、用户 Windows、业务网页、完整 CLI、AI、CI 和部署仍待后续完成。
最终实际命令输出见 docs/stage5-verification.json，独立验证数据见 docs/generated。
未删除旧测试或使用 --update 修改正确预期，未实际提交 Git 或推送。

`````

### CHANGELOG.md

`````text
# Changelog

## 0.5.0 · 2026-10-15

- 阶段 5：SettlementReport 和共享总入口，支持 HTML、Markdown、JSON。
- 增加安全文本转义、精确金额显示、无转账和错误提示。
- JSON 直接输出 Int64 十进制整数，固定 schema 和顺序。
- Native/JS 各 121 项测试通过；独立黄金比对、JSON 精度回读、12 组真实浏览器引擎页面检查通过。
- 提供固定演示包、验证脚本和生成的 HTML/Markdown/JSON 样例；业务表单尚未实现。

## 0.4.0 · 2026-10-15

- 阶段 4：高级文本解析、@ 指定、! 排除、= 实际金额及原始行号错误。
- LF/CRLF/CR、文件开头 BOM、Unicode 空白分词。
- 提取私有单笔消费校验以复用规则，保持原公开校验行为。
- 新增 36 项测试，Native/JS 各 100 项通过，包括文本到结算的两个黄金案例。
- 新增正常/错误文本样例与详细语法文档；CLI 文件 IO 尚未接入。

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
.PHONY: test check build-native build-web run-cli verify-reports

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

verify-reports:
	python3 scripts/verify_reports.py --target native
	python3 scripts/verify_reports.py --target js

`````

### README.md

`````text
# SplitEasy · AA 分账器

MoonBit 黑客松项目，产品规范 V3.1。当前已完成阶段 5：统一报表及 HTML、Markdown、JSON 输出已接通文本和结构化账单；尚未实现业务网页表单。
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

只创建当前阶段所需文件；业务网页、CLI 文件与参数 IO、AI、CI、部署在后续阶段完成。
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
日期和说明本阶段原样保留，不校验日期格式；姓名中的内部空格暂不限制，高级文本解析器单独约束姓名不得有空白和保留符号。

网页仍是阶段 1 启动页，阶段 2 的新增能力通过 MoonBit 测试验证。
阶段 2 当时每个后端有 41 项测试；当前阶段的测试总数见下文。
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

阶段 3 当时 Native 和 JS 各 64 项通过，其中一个测试遍历 375 组账单；当前阶段 4 总数见下文。
阶段 3 的黄金测试使用结构化输入；阶段 4 追加了文本到结算的黄金测试。
原始命令结果见 docs/stage3-verification.json，完整交付说明见 docs/STAGE3_REPORT.md。

浏览器补充验证：已在 Linux Chrome for Testing 133 上验证阶段 1 启动页和手机尺寸模拟；真实手机仍未验证。
通过 HTTP 打开的启动页尚不支持断网刷新，不能把保留静态显示当作离线分账验收。

阶段 1 浏览器补测的完整记录见 docs/BROWSER_FOLLOWUP.md；早先 browser-verification.json 保留初次验证时的历史状态。

## 阶段 4：高级文本模式

公开 API：`parse_text(String) -> Result[Ledger, String]`，解析成功的账单可直接传给 `settle_ledger`。

```text
人：小明 小红 小刚 小美 小李
小明 200 晚餐
小红 75 奶茶 =小明:12 小红:15 小刚:18 小美:14 小李:16
```

| 写法 | 含义 |
|---|---|
| `小明 100 晚餐` | 默认全员平均 |
| `小明 100 晚餐 @小明 小红` | 仅指定人员平均 |
| `小明 100 晚餐 !小红` | 排除指定人员，其余平均 |
| `小明 75 奶茶 =小明:12 小红:15 小刚:18 小美:14 小李:16` | 按实际金额分摊 |

每笔消费只能使用一次 @、! 或 =，不得重复或混用。一个标记后可列多个人，用空白分隔。
名单首行使用 `人：` 或 `人:`；姓名不支持空白及 @、!、=、英文/中文冒号。
消费说明至少一个词，允许空白，多个空白会归一为一个普通空格；说明中也不能把 @、!、= 当作普通字符。
`姓名:金额` 使用英文冒号，冒号两侧不插空白。金额单位为元，精度和范围沿用阶段 2。
空行忽略但保留行号；支持 LF/CRLF/CR 换行和文件开头的 BOM。
错误返回原始行号，例如 `第 3 行：个人分摊金额合计必须等于消费总金额`，不返回部分账单。
日期字段当前设为空字符串；本语法没有日期、注释、引号分组、转义和逗号列表简写。
普通用户后续仍优先使用表单，不需要学习此语法。

阶段 4 当时 Native 和 JS 各 100 项通过；当前阶段测试总数见下文。文本输入两个黄金案例均已接通结算验证。
完整语法见 docs/text-format.md；示例见 fixtures/bills_dinner.txt、fixtures/bills_mixed.txt、examples/text_modes.txt。
实际命令记录见 docs/stage4-verification.json，阶段交付见 docs/STAGE4_REPORT.md。
当前 CLI 仍是工程启动入口；文件读取和 split/check 命令将在阶段 7 实现。

## 阶段 5：统一报表和三种输出

`build_report` 生成统一 `SettlementReport`，包含总消费、逐笔说明/日期/实际份额、每人已付/应付/净额及转账清单。
报告与原账单数组分离；请通过核心入口生成报告，不要修改报告数组后继续把它当成原结算结果。

| API | 用途 |
|---|---|
| `report_from_text(text)` | 文本 → 已校验结算报告 |
| `solve_ledger(ledger, format)` | 结构化账单 → 指定格式 |
| `solve_text(text, format)` | 文本 → 指定格式 |
| `render_report(report, format)` | 已生成报告 → 指定格式 |
| `render_html(report)` | 可嵌入 DOM 的安全 HTML 片段 |
| `render_html_document(report)` | 可离线打开的完整 HTML 文档 |
| `render_text_html(text)` | 安全 HTML 片段或带行号的错误提示 |

`ReportFormat` 支持 `Markdown`、`Html`、`Json`。
solve/report 构建函数返回 `Result[..., String]`，失败保留中文错误；HTML 错误提示通过 `render_error_html` 转义。
HTML 对所有姓名、说明、日期和转账姓名转义，应收绿、应付红，附有文字标识。
Markdown 处理管道符、反斜杠、换行、HTML 和其他 Markdown 特殊符号。
JSON 固定 schema_version=1、固定字段顺序和数组顺序，金额为十进制整数分数字，不用浮点数转换。
JSON 消费者必须无损读取 64 位整数；普通 JS JSON.parse 会将数字转为 Number，不能直接用于读取大额金额。
当前只实现报表 JSON 输出，账单 JSON 输入另在后续阶段接入，两个 schema 不等同。
结算完成提示表示计算完成，不表示实际付款已经完成。

当前 `make test` 在 Native/JS 各 121 项通过。
执行 `make verify-reports` 可独立核对完整黄金文件、64 位 JSON 精度、全部控制字符回读和 Native/JS 输出逐字一致性。
该命令需要 Python 3，先运行 Native 再运行 JS，报告样例生成在 docs/generated。
固定演示包 examples/report 只输出预设案例，不是阶段 7 的正式 CLI。

可直接打开 docs/generated/dinner_html.html 或 mixed_html.html 查看真实生成的结算单。
示例含总消费、逐笔消费与份额、余额、转账及无转账提示；HTML 无脚本或外部资源。
生成报告已在 Linux Chrome for Testing 133 的桌面、390px 和 320px 手机尺寸下离线检查，12 组页面通过。
真实手机仍未验证；此处离线验证针对已生成的静态报表，不代表业务网页断网记账已完成。

详细契约见 docs/output-format.md，实际最终验证见 docs/stage5-verification.json。

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

### docs/STAGE3_REPORT.md

历史完整报告见压缩包内同名文件，内容未更改。

### docs/STAGE4_REPORT.md

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

### docs/generated/browser-verification.json

`````text
{
  "browser": "133.0.6943.16",
  "engine": "Linux Chrome headless",
  "realPhoneTested": false,
  "cases": [
    {
      "profile": "desktop",
      "viewport": {
        "width": 1280,
        "height": 800
      },
      "file": "dinner_html.html",
      "offlineLoaded": true,
      "noPageOverflow": true,
      "noScriptOrImageInjection": true,
      "externalRequests": [],
      "errors": [],
      "passed": true
    },
    {
      "profile": "desktop",
      "viewport": {
        "width": 1280,
        "height": 800
      },
      "file": "mixed_html.html",
      "offlineLoaded": true,
      "noPageOverflow": true,
      "noScriptOrImageInjection": true,
      "externalRequests": [],
      "errors": [],
      "passed": true
    },
    {
      "profile": "desktop",
      "viewport": {
        "width": 1280,
        "height": 800
      },
      "file": "special_html.html",
      "offlineLoaded": true,
      "noPageOverflow": true,
      "noScriptOrImageInjection": true,
      "externalRequests": [],
      "errors": [],
      "passed": true
    },
    {
      "profile": "desktop",
      "viewport": {
        "width": 1280,
        "height": 800
      },
      "file": "no_transfer_html.html",
      "offlineLoaded": true,
      "noPageOverflow": true,
      "noScriptOrImageInjection": true,
      "externalRequests": [],
      "errors": [],
      "passed": true
    },
    {
      "profile": "mobile_emulation",
      "viewport": {
        "width": 390,
        "height": 844
      },
      "file": "dinner_html.html",
      "offlineLoaded": true,
      "noPageOverflow": true,
      "noScriptOrImageInjection": true,
      "externalRequests": [],
      "errors": [],
      "passed": true
    },
    {
      "profile": "mobile_emulation",
      "viewport": {
        "width": 390,
        "height": 844
      },
      "file": "mixed_html.html",
      "offlineLoaded": true,
      "noPageOverflow": true,
      "noScriptOrImageInjection": true,
      "externalRequests": [],
      "errors": [],
      "passed": true
    },
    {
      "profile": "mobile_emulation",
      "viewport": {
        "width": 390,
        "height": 844
      },
      "file": "special_html.html",
      "offlineLoaded": true,
      "noPageOverflow": true,
      "noScriptOrImageInjection": true,
      "externalRequests": [],
      "errors": [],
      "passed": true
    },
    {
      "profile": "mobile_emulation",
      "viewport": {
        "width": 390,
        "height": 844
      },
      "file": "no_transfer_html.html",
      "offlineLoaded": true,
      "noPageOverflow": true,
      "noScriptOrImageInjection": true,
      "externalRequests": [],
      "errors": [],
      "passed": true
    },
    {
      "profile": "narrow_mobile_emulation",
      "viewport": {
        "width": 320,
        "height": 640
      },
      "file": "dinner_html.html",
      "offlineLoaded": true,
      "noPageOverflow": true,
      "noScriptOrImageInjection": true,
      "externalRequests": [],
      "errors": [],
      "passed": true
    },
    {
      "profile": "narrow_mobile_emulation",
      "viewport": {
        "width": 320,
        "height": 640
      },
      "file": "mixed_html.html",
      "offlineLoaded": true,
      "noPageOverflow": true,
      "noScriptOrImageInjection": true,
      "externalRequests": [],
      "errors": [],
      "passed": true
    },
    {
      "profile": "narrow_mobile_emulation",
      "viewport": {
        "width": 320,
        "height": 640
      },
      "file": "special_html.html",
      "offlineLoaded": true,
      "noPageOverflow": true,
      "noScriptOrImageInjection": true,
      "externalRequests": [],
      "errors": [],
      "passed": true
    },
    {
      "profile": "narrow_mobile_emulation",
      "viewport": {
        "width": 320,
        "height": 640
      },
      "file": "no_transfer_html.html",
      "offlineLoaded": true,
      "noPageOverflow": true,
      "noScriptOrImageInjection": true,
      "externalRequests": [],
      "errors": [],
      "passed": true
    }
  ],
  "errorHtmlSafeInAllProfiles": true,
  "passed": true
}

`````

### docs/generated/dinner_html.html

`````text
<!doctype html>
<html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>SplitEasy 结算单</title>
<style>body{margin:0;background:#f4f7f8;color:#182b31;font:16px/1.6 system-ui,sans-serif}main{max-width:640px;margin:auto;padding:20px}article{background:white;border-radius:12px;padding:16px;margin:12px 0}h1,h2,h3,p,li,td,th{overflow-wrap:anywhere}table{width:100%;border-collapse:collapse;background:white}td,th{padding:8px;text-align:left;border-bottom:1px solid #dce5e8;vertical-align:top}th{white-space:nowrap}td:first-child,th:first-child{min-width:3em;white-space:pre-wrap}td:nth-child(2),td:nth-child(3){white-space:nowrap}td:last-child{overflow-wrap:normal}.table-scroll{overflow-x:auto}article h3,article p,li{white-space:pre-wrap}</style></head><body><main>
<section class="spliteasy-report" aria-label="SplitEasy 结算单">
<h1>SplitEasy 结算单</h1>
<p>总消费：<strong>460.00 元</strong></p>
<h2>消费明细</h2>
<article><h3>第 1 笔：晚餐</h3>
<p>付款人：小明；金额：300.00 元；分摊方式：平均分摊</p>
<p>日期：未填写</p>
<ul>
<li>小明：75.00 元</li>
<li>小红：75.00 元</li>
<li>小刚：75.00 元</li>
<li>小美：75.00 元</li>
</ul></article>
<article><h3>第 2 笔：加菜</h3>
<p>付款人：小红；金额：120.00 元；分摊方式：平均分摊</p>
<p>日期：未填写</p>
<ul>
<li>小明：30.00 元</li>
<li>小红：30.00 元</li>
<li>小刚：30.00 元</li>
<li>小美：30.00 元</li>
</ul></article>
<article><h3>第 3 笔：饮料</h3>
<p>付款人：小刚；金额：40.00 元；分摊方式：平均分摊</p>
<p>日期：未填写</p>
<ul>
<li>小明：13.33 元</li>
<li>小刚：13.33 元</li>
<li>小美：13.34 元</li>
</ul></article>
<h2>每人净额</h2>
<div class="table-scroll"><table><thead><tr><th>人员</th><th>已付（元）</th><th>应付（元）</th><th>净额（元）</th></tr></thead><tbody>
<tr><td>小明</td><td>300.00</td><td>118.33</td><td style="color:#15803d">应收 +181.67</td></tr>
<tr><td>小红</td><td>120.00</td><td>105.00</td><td style="color:#15803d">应收 +15.00</td></tr>
<tr><td>小刚</td><td>40.00</td><td>118.33</td><td style="color:#b91c1c">应付 -78.33</td></tr>
<tr><td>小美</td><td>0.00</td><td>118.34</td><td style="color:#b91c1c">应付 -118.34</td></tr>
</tbody></table></div>
<h2>转账清单</h2>
<ol>
<li>小美 → 小明：118.34 元</li>
<li>小刚 → 小明：63.33 元</li>
<li>小刚 → 小红：15.00 元</li>
</ol>
<p>结算计算完成。转账清单仅为建议，不代表已经完成付款。</p>
</section>
</main></body></html>

`````

### docs/generated/dinner_markdown.md

`````text
# SplitEasy 结算单

总消费：460.00 元

## 消费明细

| 序号 | 消费 | 付款人 | 金额（元） | 分摊方式 | 日期 |
|---|---|---|---:|---|---|
| 1 | 晚餐 | 小明 | 300.00 | 平均分摊 |  |
| 2 | 加菜 | 小红 | 120.00 | 平均分摊 |  |
| 3 | 饮料 | 小刚 | 40.00 | 平均分摊 |  |

第 1 笔分摊：小明 75.00 元；小红 75.00 元；小刚 75.00 元；小美 75.00 元

第 2 笔分摊：小明 30.00 元；小红 30.00 元；小刚 30.00 元；小美 30.00 元

第 3 笔分摊：小明 13.33 元；小刚 13.33 元；小美 13.34 元

## 每人净额

| 人员 | 已付（元） | 应付（元） | 净额（元） |
|---|---:|---:|---:|
| 小明 | 300.00 | 118.33 | +181.67 |
| 小红 | 120.00 | 105.00 | +15.00 |
| 小刚 | 40.00 | 118.33 | -78.33 |
| 小美 | 0.00 | 118.34 | -118.34 |

## 转账清单

1. 小美 → 小明：118.34 元
2. 小刚 → 小明：63.33 元
3. 小刚 → 小红：15.00 元

结算计算完成。转账清单仅为建议，不代表已经完成付款。

`````

### docs/generated/error_html.html

`````text
<div class="spliteasy-error" role="alert"><strong>无法结算：</strong>第 2 行：未知付款人：&lt;script&gt;</div>
`````

### docs/generated/large_json.json

`````text
{"schema_version":1,"total_cents":9007199254740993,"balances":[{"person":"A","paid_cents":9007199254740993,"owed_cents":0,"balance_cents":9007199254740993},{"person":"B","paid_cents":0,"owed_cents":9007199254740993,"balance_cents":-9007199254740993}],"transfers":[{"from":"B","to":"A","amount_cents":9007199254740993}],"payments":[{"payer":"A","amount_cents":9007199254740993,"split_mode":"exact","description":"茶","date":"","shares":[{"person":"B","amount_cents":9007199254740993}]}]}

`````

### docs/generated/max_json.json

`````text
{"schema_version":1,"total_cents":9223372036854775807,"balances":[{"person":"A","paid_cents":9223372036854775807,"owed_cents":0,"balance_cents":9223372036854775807},{"person":"B","paid_cents":0,"owed_cents":9223372036854775807,"balance_cents":-9223372036854775807}],"transfers":[{"from":"B","to":"A","amount_cents":9223372036854775807}],"payments":[{"payer":"A","amount_cents":9223372036854775807,"split_mode":"exact","description":"茶","date":"","shares":[{"person":"B","amount_cents":9223372036854775807}]}]}

`````

### docs/generated/mixed_html.html

`````text
<!doctype html>
<html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>SplitEasy 结算单</title>
<style>body{margin:0;background:#f4f7f8;color:#182b31;font:16px/1.6 system-ui,sans-serif}main{max-width:640px;margin:auto;padding:20px}article{background:white;border-radius:12px;padding:16px;margin:12px 0}h1,h2,h3,p,li,td,th{overflow-wrap:anywhere}table{width:100%;border-collapse:collapse;background:white}td,th{padding:8px;text-align:left;border-bottom:1px solid #dce5e8;vertical-align:top}th{white-space:nowrap}td:first-child,th:first-child{min-width:3em;white-space:pre-wrap}td:nth-child(2),td:nth-child(3){white-space:nowrap}td:last-child{overflow-wrap:normal}.table-scroll{overflow-x:auto}article h3,article p,li{white-space:pre-wrap}</style></head><body><main>
<section class="spliteasy-report" aria-label="SplitEasy 结算单">
<h1>SplitEasy 结算单</h1>
<p>总消费：<strong>275.00 元</strong></p>
<h2>消费明细</h2>
<article><h3>第 1 笔：晚餐</h3>
<p>付款人：小明；金额：200.00 元；分摊方式：平均分摊</p>
<p>日期：未填写</p>
<ul>
<li>小明：40.00 元</li>
<li>小红：40.00 元</li>
<li>小刚：40.00 元</li>
<li>小美：40.00 元</li>
<li>小李：40.00 元</li>
</ul></article>
<article><h3>第 2 笔：奶茶</h3>
<p>付款人：小红；金额：75.00 元；分摊方式：按实际金额分摊</p>
<p>日期：未填写</p>
<ul>
<li>小明：12.00 元</li>
<li>小红：15.00 元</li>
<li>小刚：18.00 元</li>
<li>小美：14.00 元</li>
<li>小李：16.00 元</li>
</ul></article>
<h2>每人净额</h2>
<div class="table-scroll"><table><thead><tr><th>人员</th><th>已付（元）</th><th>应付（元）</th><th>净额（元）</th></tr></thead><tbody>
<tr><td>小明</td><td>200.00</td><td>52.00</td><td style="color:#15803d">应收 +148.00</td></tr>
<tr><td>小红</td><td>75.00</td><td>55.00</td><td style="color:#15803d">应收 +20.00</td></tr>
<tr><td>小刚</td><td>0.00</td><td>58.00</td><td style="color:#b91c1c">应付 -58.00</td></tr>
<tr><td>小美</td><td>0.00</td><td>54.00</td><td style="color:#b91c1c">应付 -54.00</td></tr>
<tr><td>小李</td><td>0.00</td><td>56.00</td><td style="color:#b91c1c">应付 -56.00</td></tr>
</tbody></table></div>
<h2>转账清单</h2>
<ol>
<li>小刚 → 小明：58.00 元</li>
<li>小李 → 小明：56.00 元</li>
<li>小美 → 小明：34.00 元</li>
<li>小美 → 小红：20.00 元</li>
</ol>
<p>结算计算完成。转账清单仅为建议，不代表已经完成付款。</p>
</section>
</main></body></html>

`````

### docs/generated/mixed_json.json

`````text
{"schema_version":1,"total_cents":27500,"balances":[{"person":"小明","paid_cents":20000,"owed_cents":5200,"balance_cents":14800},{"person":"小红","paid_cents":7500,"owed_cents":5500,"balance_cents":2000},{"person":"小刚","paid_cents":0,"owed_cents":5800,"balance_cents":-5800},{"person":"小美","paid_cents":0,"owed_cents":5400,"balance_cents":-5400},{"person":"小李","paid_cents":0,"owed_cents":5600,"balance_cents":-5600}],"transfers":[{"from":"小刚","to":"小明","amount_cents":5800},{"from":"小李","to":"小明","amount_cents":5600},{"from":"小美","to":"小明","amount_cents":3400},{"from":"小美","to":"小红","amount_cents":2000}],"payments":[{"payer":"小明","amount_cents":20000,"split_mode":"equal","description":"晚餐","date":"","shares":[{"person":"小明","amount_cents":4000},{"person":"小红","amount_cents":4000},{"person":"小刚","amount_cents":4000},{"person":"小美","amount_cents":4000},{"person":"小李","amount_cents":4000}]},{"payer":"小红","amount_cents":7500,"split_mode":"exact","description":"奶茶","date":"","shares":[{"person":"小明","amount_cents":1200},{"person":"小红","amount_cents":1500},{"person":"小刚","amount_cents":1800},{"person":"小美","amount_cents":1400},{"person":"小李","amount_cents":1600}]}]}

`````

### docs/generated/no_transfer_html.html

`````text
<!doctype html>
<html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>SplitEasy 结算单</title>
<style>body{margin:0;background:#f4f7f8;color:#182b31;font:16px/1.6 system-ui,sans-serif}main{max-width:640px;margin:auto;padding:20px}article{background:white;border-radius:12px;padding:16px;margin:12px 0}h1,h2,h3,p,li,td,th{overflow-wrap:anywhere}table{width:100%;border-collapse:collapse;background:white}td,th{padding:8px;text-align:left;border-bottom:1px solid #dce5e8;vertical-align:top}th{white-space:nowrap}td:first-child,th:first-child{min-width:3em;white-space:pre-wrap}td:nth-child(2),td:nth-child(3){white-space:nowrap}td:last-child{overflow-wrap:normal}.table-scroll{overflow-x:auto}article h3,article p,li{white-space:pre-wrap}</style></head><body><main>
<section class="spliteasy-report" aria-label="SplitEasy 结算单">
<h1>SplitEasy 结算单</h1>
<p>总消费：<strong>1.00 元</strong></p>
<h2>消费明细</h2>
<article><h3>第 1 笔：自用</h3>
<p>付款人：A；金额：1.00 元；分摊方式：平均分摊</p>
<p>日期：未填写</p>
<ul>
<li>A：1.00 元</li>
</ul></article>
<h2>每人净额</h2>
<div class="table-scroll"><table><thead><tr><th>人员</th><th>已付（元）</th><th>应付（元）</th><th>净额（元）</th></tr></thead><tbody>
<tr><td>A</td><td>1.00</td><td>1.00</td><td style="color:#475569">已平账 0.00</td></tr>
</tbody></table></div>
<h2>转账清单</h2>
<p>无需转账，所有人已平账。</p>
<p>结算计算完成。转账清单仅为建议，不代表已经完成付款。</p>
</section>
</main></body></html>

`````

### docs/generated/outputs-native.json

`````text
{
  "dinner_markdown": "# SplitEasy 结算单\n\n总消费：460.00 元\n\n## 消费明细\n\n| 序号 | 消费 | 付款人 | 金额（元） | 分摊方式 | 日期 |\n|---|---|---|---:|---|---|\n| 1 | 晚餐 | 小明 | 300.00 | 平均分摊 |  |\n| 2 | 加菜 | 小红 | 120.00 | 平均分摊 |  |\n| 3 | 饮料 | 小刚 | 40.00 | 平均分摊 |  |\n\n第 1 笔分摊：小明 75.00 元；小红 75.00 元；小刚 75.00 元；小美 75.00 元\n\n第 2 笔分摊：小明 30.00 元；小红 30.00 元；小刚 30.00 元；小美 30.00 元\n\n第 3 笔分摊：小明 13.33 元；小刚 13.33 元；小美 13.34 元\n\n## 每人净额\n\n| 人员 | 已付（元） | 应付（元） | 净额（元） |\n|---|---:|---:|---:|\n| 小明 | 300.00 | 118.33 | +181.67 |\n| 小红 | 120.00 | 105.00 | +15.00 |\n| 小刚 | 40.00 | 118.33 | -78.33 |\n| 小美 | 0.00 | 118.34 | -118.34 |\n\n## 转账清单\n\n1. 小美 → 小明：118.34 元\n2. 小刚 → 小明：63.33 元\n3. 小刚 → 小红：15.00 元\n\n结算计算完成。转账清单仅为建议，不代表已经完成付款。\n",
  "mixed_json": "{\"schema_version\":1,\"total_cents\":27500,\"balances\":[{\"person\":\"小明\",\"paid_cents\":20000,\"owed_cents\":5200,\"balance_cents\":14800},{\"person\":\"小红\",\"paid_cents\":7500,\"owed_cents\":5500,\"balance_cents\":2000},{\"person\":\"小刚\",\"paid_cents\":0,\"owed_cents\":5800,\"balance_cents\":-5800},{\"person\":\"小美\",\"paid_cents\":0,\"owed_cents\":5400,\"balance_cents\":-5400},{\"person\":\"小李\",\"paid_cents\":0,\"owed_cents\":5600,\"balance_cents\":-5600}],\"transfers\":[{\"from\":\"小刚\",\"to\":\"小明\",\"amount_cents\":5800},{\"from\":\"小李\",\"to\":\"小明\",\"amount_cents\":5600},{\"from\":\"小美\",\"to\":\"小明\",\"amount_cents\":3400},{\"from\":\"小美\",\"to\":\"小红\",\"amount_cents\":2000}],\"payments\":[{\"payer\":\"小明\",\"amount_cents\":20000,\"split_mode\":\"equal\",\"description\":\"晚餐\",\"date\":\"\",\"shares\":[{\"person\":\"小明\",\"amount_cents\":4000},{\"person\":\"小红\",\"amount_cents\":4000},{\"person\":\"小刚\",\"amount_cents\":4000},{\"person\":\"小美\",\"amount_cents\":4000},{\"person\":\"小李\",\"amount_cents\":4000}]},{\"payer\":\"小红\",\"amount_cents\":7500,\"split_mode\":\"exact\",\"description\":\"奶茶\",\"date\":\"\",\"shares\":[{\"person\":\"小明\",\"amount_cents\":1200},{\"person\":\"小红\",\"amount_cents\":1500},{\"person\":\"小刚\",\"amount_cents\":1800},{\"person\":\"小美\",\"amount_cents\":1400},{\"person\":\"小李\",\"amount_cents\":1600}]}]}\n",
  "dinner_html": "<!doctype html>\n<html lang=\"zh-CN\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><title>SplitEasy 结算单</title>\n<style>body{margin:0;background:#f4f7f8;color:#182b31;font:16px/1.6 system-ui,sans-serif}main{max-width:640px;margin:auto;padding:20px}article{background:white;border-radius:12px;padding:16px;margin:12px 0}h1,h2,h3,p,li,td,th{overflow-wrap:anywhere}table{width:100%;border-collapse:collapse;background:white}td,th{padding:8px;text-align:left;border-bottom:1px solid #dce5e8;vertical-align:top}th{white-space:nowrap}td:first-child,th:first-child{min-width:3em;white-space:pre-wrap}td:nth-child(2),td:nth-child(3){white-space:nowrap}td:last-child{overflow-wrap:normal}.table-scroll{overflow-x:auto}article h3,article p,li{white-space:pre-wrap}</style></head><body><main>\n<section class=\"spliteasy-report\" aria-label=\"SplitEasy 结算单\">\n<h1>SplitEasy 结算单</h1>\n<p>总消费：<strong>460.00 元</strong></p>\n<h2>消费明细</h2>\n<article><h3>第 1 笔：晚餐</h3>\n<p>付款人：小明；金额：300.00 元；分摊方式：平均分摊</p>\n<p>日期：未填写</p>\n<ul>\n<li>小明：75.00 元</li>\n<li>小红：75.00 元</li>\n<li>小刚：75.00 元</li>\n<li>小美：75.00 元</li>\n</ul></article>\n<article><h3>第 2 笔：加菜</h3>\n<p>付款人：小红；金额：120.00 元；分摊方式：平均分摊</p>\n<p>日期：未填写</p>\n<ul>\n<li>小明：30.00 元</li>\n<li>小红：30.00 元</li>\n<li>小刚：30.00 元</li>\n<li>小美：30.00 元</li>\n</ul></article>\n<article><h3>第 3 笔：饮料</h3>\n<p>付款人：小刚；金额：40.00 元；分摊方式：平均分摊</p>\n<p>日期：未填写</p>\n<ul>\n<li>小明：13.33 元</li>\n<li>小刚：13.33 元</li>\n<li>小美：13.34 元</li>\n</ul></article>\n<h2>每人净额</h2>\n<div class=\"table-scroll\"><table><thead><tr><th>人员</th><th>已付（元）</th><th>应付（元）</th><th>净额（元）</th></tr></thead><tbody>\n<tr><td>小明</td><td>300.00</td><td>118.33</td><td style=\"color:#15803d\">应收 +181.67</td></tr>\n<tr><td>小红</td><td>120.00</td><td>105.00</td><td style=\"color:#15803d\">应收 +15.00</td></tr>\n<tr><td>小刚</td><td>40.00</td><td>118.33</td><td style=\"color:#b91c1c\">应付 -78.33</td></tr>\n<tr><td>小美</td><td>0.00</td><td>118.34</td><td style=\"color:#b91c1c\">应付 -118.34</td></tr>\n</tbody></table></div>\n<h2>转账清单</h2>\n<ol>\n<li>小美 → 小明：118.34 元</li>\n<li>小刚 → 小明：63.33 元</li>\n<li>小刚 → 小红：15.00 元</li>\n</ol>\n<p>结算计算完成。转账清单仅为建议，不代表已经完成付款。</p>\n</section>\n</main></body></html>\n",
  "mixed_html": "<!doctype html>\n<html lang=\"zh-CN\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><title>SplitEasy 结算单</title>\n<style>body{margin:0;background:#f4f7f8;color:#182b31;font:16px/1.6 system-ui,sans-serif}main{max-width:640px;margin:auto;padding:20px}article{background:white;border-radius:12px;padding:16px;margin:12px 0}h1,h2,h3,p,li,td,th{overflow-wrap:anywhere}table{width:100%;border-collapse:collapse;background:white}td,th{padding:8px;text-align:left;border-bottom:1px solid #dce5e8;vertical-align:top}th{white-space:nowrap}td:first-child,th:first-child{min-width:3em;white-space:pre-wrap}td:nth-child(2),td:nth-child(3){white-space:nowrap}td:last-child{overflow-wrap:normal}.table-scroll{overflow-x:auto}article h3,article p,li{white-space:pre-wrap}</style></head><body><main>\n<section class=\"spliteasy-report\" aria-label=\"SplitEasy 结算单\">\n<h1>SplitEasy 结算单</h1>\n<p>总消费：<strong>275.00 元</strong></p>\n<h2>消费明细</h2>\n<article><h3>第 1 笔：晚餐</h3>\n<p>付款人：小明；金额：200.00 元；分摊方式：平均分摊</p>\n<p>日期：未填写</p>\n<ul>\n<li>小明：40.00 元</li>\n<li>小红：40.00 元</li>\n<li>小刚：40.00 元</li>\n<li>小美：40.00 元</li>\n<li>小李：40.00 元</li>\n</ul></article>\n<article><h3>第 2 笔：奶茶</h3>\n<p>付款人：小红；金额：75.00 元；分摊方式：按实际金额分摊</p>\n<p>日期：未填写</p>\n<ul>\n<li>小明：12.00 元</li>\n<li>小红：15.00 元</li>\n<li>小刚：18.00 元</li>\n<li>小美：14.00 元</li>\n<li>小李：16.00 元</li>\n</ul></article>\n<h2>每人净额</h2>\n<div class=\"table-scroll\"><table><thead><tr><th>人员</th><th>已付（元）</th><th>应付（元）</th><th>净额（元）</th></tr></thead><tbody>\n<tr><td>小明</td><td>200.00</td><td>52.00</td><td style=\"color:#15803d\">应收 +148.00</td></tr>\n<tr><td>小红</td><td>75.00</td><td>55.00</td><td style=\"color:#15803d\">应收 +20.00</td></tr>\n<tr><td>小刚</td><td>0.00</td><td>58.00</td><td style=\"color:#b91c1c\">应付 -58.00</td></tr>\n<tr><td>小美</td><td>0.00</td><td>54.00</td><td style=\"color:#b91c1c\">应付 -54.00</td></tr>\n<tr><td>小李</td><td>0.00</td><td>56.00</td><td style=\"color:#b91c1c\">应付 -56.00</td></tr>\n</tbody></table></div>\n<h2>转账清单</h2>\n<ol>\n<li>小刚 → 小明：58.00 元</li>\n<li>小李 → 小明：56.00 元</li>\n<li>小美 → 小明：34.00 元</li>\n<li>小美 → 小红：20.00 元</li>\n</ol>\n<p>结算计算完成。转账清单仅为建议，不代表已经完成付款。</p>\n</section>\n</main></body></html>\n",
  "max_json": "{\"schema_version\":1,\"total_cents\":9223372036854775807,\"balances\":[{\"person\":\"A\",\"paid_cents\":9223372036854775807,\"owed_cents\":0,\"balance_cents\":9223372036854775807},{\"person\":\"B\",\"paid_cents\":0,\"owed_cents\":9223372036854775807,\"balance_cents\":-9223372036854775807}],\"transfers\":[{\"from\":\"B\",\"to\":\"A\",\"amount_cents\":9223372036854775807}],\"payments\":[{\"payer\":\"A\",\"amount_cents\":9223372036854775807,\"split_mode\":\"exact\",\"description\":\"茶\",\"date\":\"\",\"shares\":[{\"person\":\"B\",\"amount_cents\":9223372036854775807}]}]}\n",
  "large_json": "{\"schema_version\":1,\"total_cents\":9007199254740993,\"balances\":[{\"person\":\"A\",\"paid_cents\":9007199254740993,\"owed_cents\":0,\"balance_cents\":9007199254740993},{\"person\":\"B\",\"paid_cents\":0,\"owed_cents\":9007199254740993,\"balance_cents\":-9007199254740993}],\"transfers\":[{\"from\":\"B\",\"to\":\"A\",\"amount_cents\":9007199254740993}],\"payments\":[{\"payer\":\"A\",\"amount_cents\":9007199254740993,\"split_mode\":\"exact\",\"description\":\"茶\",\"date\":\"\",\"shares\":[{\"person\":\"B\",\"amount_cents\":9007199254740993}]}]}\n",
  "special_html": "<!doctype html>\n<html lang=\"zh-CN\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><title>SplitEasy 结算单</title>\n<style>body{margin:0;background:#f4f7f8;color:#182b31;font:16px/1.6 system-ui,sans-serif}main{max-width:640px;margin:auto;padding:20px}article{background:white;border-radius:12px;padding:16px;margin:12px 0}h1,h2,h3,p,li,td,th{overflow-wrap:anywhere}table{width:100%;border-collapse:collapse;background:white}td,th{padding:8px;text-align:left;border-bottom:1px solid #dce5e8;vertical-align:top}th{white-space:nowrap}td:first-child,th:first-child{min-width:3em;white-space:pre-wrap}td:nth-child(2),td:nth-child(3){white-space:nowrap}td:last-child{overflow-wrap:normal}.table-scroll{overflow-x:auto}article h3,article p,li{white-space:pre-wrap}</style></head><body><main>\n<section class=\"spliteasy-report\" aria-label=\"SplitEasy 结算单\">\n<h1>SplitEasy 结算单</h1>\n<p>总消费：<strong>0.29 元</strong></p>\n<h2>消费明细</h2>\n<article><h3>第 1 笔：茶&lt;/h3&gt;&lt;script&gt;alert(1)&lt;/script&gt;&amp;&quot;&#39;|\n第二行</h3>\n<p>付款人：&lt;img/src=x/onerror=alert(1)&gt;；金额：0.29 元；分摊方式：按实际金额分摊</p>\n<p>日期：&lt;/p&gt;&lt;img/src=x/onerror=alert(2)&gt;</p>\n<ul>\n<li>B|*_[x]：0.29 元</li>\n</ul></article>\n<h2>每人净额</h2>\n<div class=\"table-scroll\"><table><thead><tr><th>人员</th><th>已付（元）</th><th>应付（元）</th><th>净额（元）</th></tr></thead><tbody>\n<tr><td>&lt;img/src=x/onerror=alert(1)&gt;</td><td>0.29</td><td>0.00</td><td style=\"color:#15803d\">应收 +0.29</td></tr>\n<tr><td>B|*_[x]</td><td>0.00</td><td>0.29</td><td style=\"color:#b91c1c\">应付 -0.29</td></tr>\n</tbody></table></div>\n<h2>转账清单</h2>\n<ol>\n<li>B|*_[x] → &lt;img/src=x/onerror=alert(1)&gt;：0.29 元</li>\n</ol>\n<p>结算计算完成。转账清单仅为建议，不代表已经完成付款。</p>\n</section>\n</main></body></html>\n",
  "special_markdown": "# SplitEasy 结算单\n\n总消费：0.29 元\n\n## 消费明细\n\n| 序号 | 消费 | 付款人 | 金额（元） | 分摊方式 | 日期 |\n|---|---|---|---:|---|---|\n| 1 | 茶&lt;/h3&gt;&lt;script&gt;alert\\(1\\)&lt;/script&gt;&amp;\"'\\|<br>第二行 | &lt;img/src=x/onerror=alert\\(1\\)&gt; | 0.29 | 按实际金额分摊 | &lt;/p&gt;&lt;img/src=x/onerror=alert\\(2\\)&gt; |\n\n第 1 笔分摊：B\\|\\*\\_\\[x\\] 0.29 元\n\n## 每人净额\n\n| 人员 | 已付（元） | 应付（元） | 净额（元） |\n|---|---:|---:|---:|\n| &lt;img/src=x/onerror=alert\\(1\\)&gt; | 0.29 | 0.00 | +0.29 |\n| B\\|\\*\\_\\[x\\] | 0.00 | 0.29 | -0.29 |\n\n## 转账清单\n\n1. B\\|\\*\\_\\[x\\] → &lt;img/src=x/onerror=alert\\(1\\)&gt;：0.29 元\n\n结算计算完成。转账清单仅为建议，不代表已经完成付款。\n",
  "special_json": "{\"schema_version\":1,\"total_cents\":29,\"balances\":[{\"person\":\"\\u003cimg/src=x/onerror=alert(1)\\u003e\",\"paid_cents\":29,\"owed_cents\":0,\"balance_cents\":29},{\"person\":\"B|*_[x]\",\"paid_cents\":0,\"owed_cents\":29,\"balance_cents\":-29}],\"transfers\":[{\"from\":\"B|*_[x]\",\"to\":\"\\u003cimg/src=x/onerror=alert(1)\\u003e\",\"amount_cents\":29}],\"payments\":[{\"payer\":\"\\u003cimg/src=x/onerror=alert(1)\\u003e\",\"amount_cents\":29,\"split_mode\":\"exact\",\"description\":\"茶\\u003c/h3\\u003e\\u003cscript\\u003ealert(1)\\u003c/script\\u003e\\u0026\\\"'|\\n第二行\",\"date\":\"\\u003c/p\\u003e\\u003cimg/src=x/onerror=alert(2)\\u003e\",\"shares\":[{\"person\":\"B|*_[x]\",\"amount_cents\":29}]}]}\n",
  "no_transfer_html": "<!doctype html>\n<html lang=\"zh-CN\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><title>SplitEasy 结算单</title>\n<style>body{margin:0;background:#f4f7f8;color:#182b31;font:16px/1.6 system-ui,sans-serif}main{max-width:640px;margin:auto;padding:20px}article{background:white;border-radius:12px;padding:16px;margin:12px 0}h1,h2,h3,p,li,td,th{overflow-wrap:anywhere}table{width:100%;border-collapse:collapse;background:white}td,th{padding:8px;text-align:left;border-bottom:1px solid #dce5e8;vertical-align:top}th{white-space:nowrap}td:first-child,th:first-child{min-width:3em;white-space:pre-wrap}td:nth-child(2),td:nth-child(3){white-space:nowrap}td:last-child{overflow-wrap:normal}.table-scroll{overflow-x:auto}article h3,article p,li{white-space:pre-wrap}</style></head><body><main>\n<section class=\"spliteasy-report\" aria-label=\"SplitEasy 结算单\">\n<h1>SplitEasy 结算单</h1>\n<p>总消费：<strong>1.00 元</strong></p>\n<h2>消费明细</h2>\n<article><h3>第 1 笔：自用</h3>\n<p>付款人：A；金额：1.00 元；分摊方式：平均分摊</p>\n<p>日期：未填写</p>\n<ul>\n<li>A：1.00 元</li>\n</ul></article>\n<h2>每人净额</h2>\n<div class=\"table-scroll\"><table><thead><tr><th>人员</th><th>已付（元）</th><th>应付（元）</th><th>净额（元）</th></tr></thead><tbody>\n<tr><td>A</td><td>1.00</td><td>1.00</td><td style=\"color:#475569\">已平账 0.00</td></tr>\n</tbody></table></div>\n<h2>转账清单</h2>\n<p>无需转账，所有人已平账。</p>\n<p>结算计算完成。转账清单仅为建议，不代表已经完成付款。</p>\n</section>\n</main></body></html>\n",
  "error_html": "<div class=\"spliteasy-error\" role=\"alert\"><strong>无法结算：</strong>第 2 行：未知付款人：&lt;script&gt;</div>",
  "controls_encoded": "\"\\u0000\\u0001\\u0002\\u0003\\u0004\\u0005\\u0006\\u0007\\b\\t\\n\\u000b\\f\\r\\u000e\\u000f\\u0010\\u0011\\u0012\\u0013\\u0014\\u0015\\u0016\\u0017\\u0018\\u0019\\u001a\\u001b\\u001c\\u001d\\u001e\\u001f中文😀\\u003c\\u003e\\u0026\\u2028\\u2029\""
}

`````

### docs/generated/special_html.html

`````text
<!doctype html>
<html lang="zh-CN"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>SplitEasy 结算单</title>
<style>body{margin:0;background:#f4f7f8;color:#182b31;font:16px/1.6 system-ui,sans-serif}main{max-width:640px;margin:auto;padding:20px}article{background:white;border-radius:12px;padding:16px;margin:12px 0}h1,h2,h3,p,li,td,th{overflow-wrap:anywhere}table{width:100%;border-collapse:collapse;background:white}td,th{padding:8px;text-align:left;border-bottom:1px solid #dce5e8;vertical-align:top}th{white-space:nowrap}td:first-child,th:first-child{min-width:3em;white-space:pre-wrap}td:nth-child(2),td:nth-child(3){white-space:nowrap}td:last-child{overflow-wrap:normal}.table-scroll{overflow-x:auto}article h3,article p,li{white-space:pre-wrap}</style></head><body><main>
<section class="spliteasy-report" aria-label="SplitEasy 结算单">
<h1>SplitEasy 结算单</h1>
<p>总消费：<strong>0.29 元</strong></p>
<h2>消费明细</h2>
<article><h3>第 1 笔：茶&lt;/h3&gt;&lt;script&gt;alert(1)&lt;/script&gt;&amp;&quot;&#39;|
第二行</h3>
<p>付款人：&lt;img/src=x/onerror=alert(1)&gt;；金额：0.29 元；分摊方式：按实际金额分摊</p>
<p>日期：&lt;/p&gt;&lt;img/src=x/onerror=alert(2)&gt;</p>
<ul>
<li>B|*_[x]：0.29 元</li>
</ul></article>
<h2>每人净额</h2>
<div class="table-scroll"><table><thead><tr><th>人员</th><th>已付（元）</th><th>应付（元）</th><th>净额（元）</th></tr></thead><tbody>
<tr><td>&lt;img/src=x/onerror=alert(1)&gt;</td><td>0.29</td><td>0.00</td><td style="color:#15803d">应收 +0.29</td></tr>
<tr><td>B|*_[x]</td><td>0.00</td><td>0.29</td><td style="color:#b91c1c">应付 -0.29</td></tr>
</tbody></table></div>
<h2>转账清单</h2>
<ol>
<li>B|*_[x] → &lt;img/src=x/onerror=alert(1)&gt;：0.29 元</li>
</ol>
<p>结算计算完成。转账清单仅为建议，不代表已经完成付款。</p>
</section>
</main></body></html>

`````

### docs/generated/special_json.json

`````text
{"schema_version":1,"total_cents":29,"balances":[{"person":"\u003cimg/src=x/onerror=alert(1)\u003e","paid_cents":29,"owed_cents":0,"balance_cents":29},{"person":"B|*_[x]","paid_cents":0,"owed_cents":29,"balance_cents":-29}],"transfers":[{"from":"B|*_[x]","to":"\u003cimg/src=x/onerror=alert(1)\u003e","amount_cents":29}],"payments":[{"payer":"\u003cimg/src=x/onerror=alert(1)\u003e","amount_cents":29,"split_mode":"exact","description":"茶\u003c/h3\u003e\u003cscript\u003ealert(1)\u003c/script\u003e\u0026\"'|\n第二行","date":"\u003c/p\u003e\u003cimg/src=x/onerror=alert(2)\u003e","shares":[{"person":"B|*_[x]","amount_cents":29}]}]}

`````

### docs/generated/special_markdown.md

`````text
# SplitEasy 结算单

总消费：0.29 元

## 消费明细

| 序号 | 消费 | 付款人 | 金额（元） | 分摊方式 | 日期 |
|---|---|---|---:|---|---|
| 1 | 茶&lt;/h3&gt;&lt;script&gt;alert\(1\)&lt;/script&gt;&amp;"'\|<br>第二行 | &lt;img/src=x/onerror=alert\(1\)&gt; | 0.29 | 按实际金额分摊 | &lt;/p&gt;&lt;img/src=x/onerror=alert\(2\)&gt; |

第 1 笔分摊：B\|\*\_\[x\] 0.29 元

## 每人净额

| 人员 | 已付（元） | 应付（元） | 净额（元） |
|---|---:|---:|---:|
| &lt;img/src=x/onerror=alert\(1\)&gt; | 0.29 | 0.00 | +0.29 |
| B\|\*\_\[x\] | 0.00 | 0.29 | -0.29 |

## 转账清单

1. B\|\*\_\[x\] → &lt;img/src=x/onerror=alert\(1\)&gt;：0.29 元

结算计算完成。转账清单仅为建议，不代表已经完成付款。

`````

### docs/generated/verification-js.json

`````text
{
  "target": "js",
  "golden_markdown_exact": true,
  "golden_json_exact": true,
  "int64_json_python_roundtrip": true,
  "all_control_characters_roundtrip": true,
  "special_text_roundtrip": true,
  "passed": true
}

`````

### docs/generated/verification-native.json

`````text
{
  "target": "native",
  "golden_markdown_exact": true,
  "golden_json_exact": true,
  "int64_json_python_roundtrip": true,
  "all_control_characters_roundtrip": true,
  "special_text_roundtrip": true,
  "passed": true
}

`````

### docs/output-format.md

`````text
# SplitEasy 统一报告与输出契约（阶段 5）

## 数据流

文本 → parse_text → Ledger → build_report → SettlementReport → 渲染。
结构化 Ledger 可以直接交给 build_report 或 solve_ledger。
每次构建报告都会校验并结算；无效或含歧义的账单不输出成功结果。

SettlementReport 含 total_cents、payments、balances、transfers。
PaymentReport 含 payer、amount_cents、split_mode、实际分配后的 shares、description、date。
每笔份额和余额按人员声明顺序，消费按输入顺序，转账按确定性算法顺序。
report 的字段只读，但 Array 仍可修改；调用方应把报告当作结果快照，编辑账单后重新生成。
报告不会共享源账单数组，渲染也不修改报告。

## 入口与失败处理

- build_report(Ledger) → Result[SettlementReport, String]
- report_from_text(String) → Result[SettlementReport, String]
- solve_ledger(Ledger, ReportFormat) → Result[String, String]
- solve_text(String, ReportFormat) → Result[String, String]
- render_report(SettlementReport, ReportFormat) → String
- render_text_html(String) → 安全 HTML 片段（成功或错误）。

ReportFormat 为 Markdown / Html / Json。
solve 的 Html 选项输出完整 HTML 文档；render_html 输出 DOM 片段。
render_error_html 将任何错误文本转义到 role=alert 的片段。
Markdown/JSON 的失败通过 Result.Err 返回，未来 CLI 将写 stderr 并返回非零状态。
本阶段不提前实现 CLI 参数、文件 IO 或退出码。

## HTML

完整文档自带 UTF-8、viewport 和简单响应式 CSS，无脚本、外部字体或 CDN。
包含总消费、逐笔说明、付款人、金额、分摊模式、日期、所有实际份额、每人已付/应付/净额与转账清单。
日期空字符串在 HTML 中显示“未填写”，不自动补日期。
应收绿、应付红、已平账灰，并提供文字标识。
无消费和无转账都有提示。
所有姓名、说明、日期和错误中的 & < > " ' 都转义，不放入属性、样式或脚本位置。

## Markdown

固定标题、消费明细表、逐笔实际份额、每人净额表、转账清单和计算完成提示。
用户文本的反斜杠、竖线及其他 Markdown 元字符转义；HTML 标签变为实体。
CRLF/CR/LF 统一，单元格中的换行用固定 <br> 表示，不能插入额外表格行。
正常与恶意文本均经过测试，完整晚餐黄金文件见 fixtures/expected_dinner.md。

## JSON

固定输出顺序：schema_version、total_cents、balances、transfers、payments。

```json
{"schema_version":1,"total_cents":0,"balances":[{"person":"A","paid_cents":0,"owed_cents":0,"balance_cents":0}],"transfers":[],"payments":[]}
```

balances 每项字段：person、paid_cents、owed_cents、balance_cents。
transfers 每项字段：from、to、amount_cents。
payments 每项字段：payer、amount_cents、split_mode、description、date、shares。
shares 每项字段：person、amount_cents。split_mode 为 equal / exact。
输出末尾有一个换行；不输出浮点数、科学计数或金额字符串。

金额数字写入前不转换成 Double/JS Number，因此 9223372036854775807 分能够完整输出。
使用者必须采用支持无损 64 位整数的 JSON 解析方法；普通 JS JSON.parse 不能保留安全整数范围外的数字精度。
Python 标准 json 以整数回读的独立验证脚本已覆盖这一点。
字符串中的引号、反斜杠、U+0000..U+001F 转义；< > & U+2028 U+2029 也转义以减少嵌入上下文风险。
报表 JSON 是结算输出，不是尚未接入的 Ledger 账单输入 schema。

## 精确金额显示

format_money(Int64) 按整数除 100 和余数生成固定两位小数，支持负数和 Int64 最小值，不对最小值整体取反。
format_signed_money 对正数加 +，负数保留 -，零显示 0.00。
所有计算仍是整数分；元只用于人类阅读的 HTML/Markdown。
“结算计算完成”仅指建议清单已计算，不代表已经转账付款。

## 复现验证

```bash
make test
make verify-reports
```

每个后端 121 项单元/端到端测试。
verify-reports 先 Native 再 JS：核对事先写定的黄金文件、验证 Python 无损读取大整数、全部控制字符和特殊文本，并比较两端输出逐字一致。
生成文件在 docs/generated。examples/report 是固定样例输出器，不是正式 CLI。

可选浏览器验证（需要 Node.js、Playwright 和可用 Chromium）：

```bash
node scripts/verify_report_browser.cjs
```

如果浏览器不在 Playwright 默认位置，可通过 SPLITEASY_CHROME 指定；若 Playwright 模块不在默认搜索路径，可通过 SPLITEASY_PLAYWRIGHT 指定模块路径。
真实测试使用 Linux Chrome 133，三个尺寸、四份 HTML 文档共 12 组离线页面检查，另检查三个尺寸的错误片段。
这只验证生成的静态报表，不能替代真实手机和阶段 6 的离线记账。

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

### docs/stage4-verification.json

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
    "stdout": "moon test --target native\nTotal tests: 100, passed: 100, failed: 0.\nmoon test --target js\nTotal tests: 100, passed: 100, failed: 0.\n",
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

### docs/stage5-verification.json

`````text
[
  {
    "command": "moon version",
    "environment_note": "",
    "exit_code": 0,
    "stdout": "moon 0.1.20261012 (748b63c 2026-10-12)\n\nFeature flags enabled: rr_moon_mod,rr_moon_pkg\n",
    "stderr": ""
  },
  {
    "command": "moonc -v",
    "environment_note": "",
    "exit_code": 0,
    "stdout": "v0.10.15+943464bfa (2026-10-12)\n",
    "stderr": ""
  },
  {
    "command": "moon fmt",
    "environment_note": "",
    "exit_code": 0,
    "stdout": "",
    "stderr": "Finished. moon: ran 2 tasks, now up to date\n"
  },
  {
    "command": "make check",
    "environment_note": "",
    "exit_code": 0,
    "stdout": "moon check --target native\nmoon check --target js\n",
    "stderr": "Finished. moon: ran 6 tasks, now up to date\nFinished. moon: ran 6 tasks, now up to date\n"
  },
  {
    "command": "make test",
    "environment_note": "",
    "exit_code": 0,
    "stdout": "moon test --target native\nTotal tests: 121, passed: 121, failed: 0.\nmoon test --target js\nTotal tests: 121, passed: 121, failed: 0.\n",
    "stderr": ""
  },
  {
    "command": "make build-native",
    "environment_note": "",
    "exit_code": 0,
    "stdout": "moon build --target native\n",
    "stderr": "Finished. moon: ran 8 tasks, now up to date\n"
  },
  {
    "command": "make run-cli",
    "environment_note": "",
    "exit_code": 0,
    "stdout": "moon run cli/main --target native\nSplitEasy: MoonBit shared core ready.\n",
    "stderr": ""
  },
  {
    "command": "make build-web",
    "environment_note": "",
    "exit_code": 0,
    "stdout": "bash web/build.sh\n已生成 web/spliteasy.js\n",
    "stderr": "Typescript declaration file is only supported for ESM format for now\nFinished. moon: ran 5 tasks, now up to date\n"
  },
  {
    "command": "make verify-reports",
    "environment_note": "",
    "exit_code": 0,
    "stdout": "python3 scripts/verify_reports.py --target native\n{\"target\": \"native\", \"golden_markdown_exact\": true, \"golden_json_exact\": true, \"int64_json_python_roundtrip\": true, \"all_control_characters_roundtrip\": true, \"special_text_roundtrip\": true, \"passed\": true}\npython3 scripts/verify_reports.py --target js\n{\"target\": \"js\", \"golden_markdown_exact\": true, \"golden_json_exact\": true, \"int64_json_python_roundtrip\": true, \"all_control_characters_roundtrip\": true, \"special_text_roundtrip\": true, \"passed\": true}\n",
    "stderr": ""
  },
  {
    "command": "node scripts/verify_report_browser.cjs",
    "environment_note": "SPLITEASY_CHROME set to installed Chrome for Testing 133",
    "exit_code": 0,
    "stdout": "{\"browser\":\"133.0.6943.16\",\"cases\":12,\"realPhoneTested\":false,\"passed\":true}\n",
    "stderr": ""
  }
]

`````

### docs/text-format.md

`````text
# SplitEasy 高级文本语法（阶段 4）

普通用户将使用填表网页；以下是高级输入方式。

## 文档结构

首个非空行声明全部人员，之后每个非空行是一笔消费：

```text
人：小明 小红 小刚
小明 100 晚餐
小红 30 奶茶 @小刚 小明
小刚 20 饮料 !小红
小明 45 早餐 =小明:12 小红:15 小刚:18
```

首行 `人：` 和 `人:` 均接受；冒号前后的空白可省略。
名单只能声明一次，不能在消费之后重声明或追加人员。
名字按空白分隔，顺序用于尾差与转账同额选择。
姓名暂不支持空白，也不能包含 @、!、=、:、：。
不对姓名做引号分组或转义，不能用引号表示一个带空格的姓名。

## 消费格式

```text
付款人 金额 消费说明 [分摊标记及明细]
```

付款人必须已声明；金额单位为元，必须大于零，最多两位小数。
解析为 Int64 整数分，无浮点运算。单笔、份额合计和总消费均检查溢出。
消费说明至少一个词，可有多个词，分词后用单个空格连接。
原始说明的多个空格/制表符不会逐字保留。
每笔消费的 date 设为空字符串；当前语法不解析日期。

| 模式 | 示例 | 规则 |
|---|---|---|
| 默认 | `小明 100 晚餐` | 全员平均 |
| @ | `小明 100 晚餐 @小明 小红` | 指定人员平均 |
| ! | `小明 100 晚餐 !小红` | 排除这些人，其余平均 |
| = | `小明 30 奶茶 =小明:12 小红:18` | 明确整数分份额，合计必须等于 30 元 |

每笔只出现一次标记；同类重复与不同类混用都拒绝。
标记可以紧贴后面的姓名，也可以用空白隔开，例如 @小明 与 @ 小明 等价。
标记也可以紧跟消费说明；@、!、= 因而不能在说明中充当普通字符。
多个名字/份额用空白分隔，不用逗号。
实际金额每项必须为 `姓名:金额`，使用英文冒号，冒号两侧不插空白。
名字不能重复，也不能出现未知人员。排除列表也检查未知/重复人员。
平均模式不能排除所有人；付款人可以不参与。
实际金额模式允许零份额，也允许省略未参与者。

## 换行与空白

支持 LF、Windows CRLF、单 CR，以及仅位于文件最开头的 BOM。
空行忽略，但错误行号仍按原始逻辑行从 1 计数。
支持 Unicode 空白作为分词间隔；不支持把 Unicode 行分隔符当作新的记录行。
没有人员名单的空文档报第 1 行缺少名单；只有名单、没有消费的草稿允许通过。
不支持注释、引号分组、转义、货币符号、科学计数法和逗号列表简写。

## 错误与校验

公开入口 `parse_text(String) -> Result[Ledger, String]`。
成功返回完整合法 Ledger，ambiguous 为空；失败返回第一个中文错误，不返回部分账单。

```text
第 2 行：未知付款人：小王
第 3 行：个人分摊金额合计必须等于消费总金额
第 4 行：每笔消费只能使用一次 @、! 或 = 标记，不得混用
```

金额不符、人物不明时不会猜测或自动补差额。
同一行有多种错误时按解析/校验检查顺序返回一个；修正后可以再次解析。

## 测试样例

- fixtures/bills_dinner.txt：四人晚餐黄金输入。
- fixtures/bills_mixed.txt：五人晚餐与奶茶混合黄金输入。
- examples/text_modes.txt：四种写法示例。
- fixtures/invalid/mixed_markers.txt：第 2 行标记混用错误。
- fixtures/invalid/share_mismatch.txt：第 3 行份额合计不符错误。

这批文件为后续 CLI 提供输入；当前测试将对应文本嵌入 MoonBit 用例，不依赖文件系统。
两个黄金文本已通过 parse_text → settle_ledger 的 Native/JS 双端测试。
阶段 7 才接入 check/split 命令和文件 IO。

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

### examples/report/main.mbt

`````text
///|
/// Fixed offline demonstration, not a CLI argument or file-IO implementation.
fn output(text : String, format : @shared.ReportFormat) -> String {
  match @shared.solve_text(text, format) {
    Ok(value) => value
    Err(message) => abort(message)
  }
}

///|
fn main {
  let dinner = "人：小明 小红 小刚 小美\n小明 300 晚餐\n小红 120 加菜\n小刚 40 饮料 !小红"
  let mixed = "人：小明 小红 小刚 小美 小李\n小明 200 晚餐\n小红 75 奶茶 =小明:12 小红:15 小刚:18 小美:14 小李:16"
  let large = "人：A B\nA 90071992547409.93 茶 =B:90071992547409.93"
  let max = "人：A B\nA 92233720368547758.07 茶 =B:92233720368547758.07"
  let person = "<img/src=x/onerror=alert(1)>"
  let special : @shared.Ledger = {
    people: [person, "B|*_[x]"],
    payments: [
      {
        payer: person,
        amount_cents: 29L,
        split_mode: Exact,
        participants: [],
        shares: [{ person: "B|*_[x]", amount_cents: 29L, }],
        description: "茶</h3><script>alert(1)</script>&\"'|\n第二行",
        date: "</p><img/src=x/onerror=alert(2)>",
      },
    ],
    ambiguous: [],
  }
  let special_report = match @shared.build_report(special) {
    Ok(value) => value
    Err(message) => abort(message)
  }
  let controls = StringBuilder()
  for i in 0..<32 {
    controls.write_char(i.to_char().unwrap())
  }
  controls.write_string("中文😀<>&\u{2028}\u{2029}")
  let outputs : Array[(String, String)] = [
    ("dinner_markdown", output(dinner, Markdown)),
    ("mixed_json", output(mixed, Json)),
    ("dinner_html", output(dinner, Html)),
    ("mixed_html", output(mixed, Html)),
    ("max_json", output(max, Json)),
    ("large_json", output(large, Json)),
    ("special_html", @shared.render_html_document(special_report)),
    ("special_markdown", @shared.render_markdown(special_report)),
    ("special_json", @shared.render_json(special_report)),
    ("no_transfer_html", output("人：A\nA 1 自用", Html)),
    ("error_html", @shared.render_text_html("人：A\n<script> 1 茶")),
    ("controls_encoded", @shared.quote_json(controls.to_string())),
  ]
  let result = StringBuilder()
  result.write_char('{')
  for i, entry in outputs {
    if i > 0 {
      result.write_char(',')
    }
    let (key, value) = entry
    result.write_string(
      @shared.quote_json(key) + ":" + @shared.quote_json(value),
    )
  }
  result.write_char('}')
  println(result.to_string())
}

`````

### examples/report/moon.pkg

`````text
import {
  "spliteasy/spliteasy/shared",
}

pkgtype(kind: "executable")

supported_targets = "+native+js"

`````

### examples/text_modes.txt

`````text
人：小明 小红 小刚
小明 100 晚餐
小红 30 奶茶 @小刚 小明
小刚 20 饮料 !小红
小明 45 早餐 =小明:12 小红:15 小刚:18

`````

### fixtures/.gitkeep

`````text

`````

### fixtures/bills_dinner.txt

`````text
人：小明 小红 小刚 小美
小明 300 晚餐
小红 120 加菜
小刚 40 饮料 !小红

`````

### fixtures/bills_mixed.txt

`````text
人：小明 小红 小刚 小美 小李
小明 200 晚餐
小红 75 奶茶 =小明:12 小红:15 小刚:18 小美:14 小李:16

`````

### fixtures/expected_dinner.md

`````text
# SplitEasy 结算单

总消费：460.00 元

## 消费明细

| 序号 | 消费 | 付款人 | 金额（元） | 分摊方式 | 日期 |
|---|---|---|---:|---|---|
| 1 | 晚餐 | 小明 | 300.00 | 平均分摊 |  |
| 2 | 加菜 | 小红 | 120.00 | 平均分摊 |  |
| 3 | 饮料 | 小刚 | 40.00 | 平均分摊 |  |

第 1 笔分摊：小明 75.00 元；小红 75.00 元；小刚 75.00 元；小美 75.00 元

第 2 笔分摊：小明 30.00 元；小红 30.00 元；小刚 30.00 元；小美 30.00 元

第 3 笔分摊：小明 13.33 元；小刚 13.33 元；小美 13.34 元

## 每人净额

| 人员 | 已付（元） | 应付（元） | 净额（元） |
|---|---:|---:|---:|
| 小明 | 300.00 | 118.33 | +181.67 |
| 小红 | 120.00 | 105.00 | +15.00 |
| 小刚 | 40.00 | 118.33 | -78.33 |
| 小美 | 0.00 | 118.34 | -118.34 |

## 转账清单

1. 小美 → 小明：118.34 元
2. 小刚 → 小明：63.33 元
3. 小刚 → 小红：15.00 元

结算计算完成。转账清单仅为建议，不代表已经完成付款。

`````

### fixtures/expected_mixed.json

`````text
{"schema_version":1,"total_cents":27500,"balances":[{"person":"小明","paid_cents":20000,"owed_cents":5200,"balance_cents":14800},{"person":"小红","paid_cents":7500,"owed_cents":5500,"balance_cents":2000},{"person":"小刚","paid_cents":0,"owed_cents":5800,"balance_cents":-5800},{"person":"小美","paid_cents":0,"owed_cents":5400,"balance_cents":-5400},{"person":"小李","paid_cents":0,"owed_cents":5600,"balance_cents":-5600}],"transfers":[{"from":"小刚","to":"小明","amount_cents":5800},{"from":"小李","to":"小明","amount_cents":5600},{"from":"小美","to":"小明","amount_cents":3400},{"from":"小美","to":"小红","amount_cents":2000}],"payments":[{"payer":"小明","amount_cents":20000,"split_mode":"equal","description":"晚餐","date":"","shares":[{"person":"小明","amount_cents":4000},{"person":"小红","amount_cents":4000},{"person":"小刚","amount_cents":4000},{"person":"小美","amount_cents":4000},{"person":"小李","amount_cents":4000}]},{"payer":"小红","amount_cents":7500,"split_mode":"exact","description":"奶茶","date":"","shares":[{"person":"小明","amount_cents":1200},{"person":"小红","amount_cents":1500},{"person":"小刚","amount_cents":1800},{"person":"小美","amount_cents":1400},{"person":"小李","amount_cents":1600}]}]}

`````

### fixtures/invalid/mixed_markers.txt

`````text
人：小明 小红
小明 30 奶茶 @小明 !小红

`````

### fixtures/invalid/share_mismatch.txt

`````text
人：小明 小红

小明 30 奶茶 =小明:12 小红:15

`````

### moon.mod

`````text
name = "spliteasy/spliteasy"

version = "0.5.0"

readme = "README.md"

license = "MIT"

preferred_target = "native"

supported_targets = "+native+js"

`````

### scripts/verify_report_browser.cjs

`````text
// Optional real-browser verification. Requires Playwright and Chromium/Chrome.
const {chromium}=require(process.env.SPLITEASY_PLAYWRIGHT||'playwright');
const fs=require('fs');const path=require('path');const assert=require('assert/strict');
(async()=>{
 const root=path.resolve(__dirname,'..');const generated=path.join(root,'docs/generated');
 const options={headless:true,args:['--no-sandbox']};if(process.env.SPLITEASY_CHROME)options.executablePath=process.env.SPLITEASY_CHROME;
 const browser=await chromium.launch(options);const cases=[];
 try{
  for(const [name,viewport] of [['desktop',{width:1280,height:800}],['mobile_emulation',{width:390,height:844}],['narrow_mobile_emulation',{width:320,height:640}]]){
   const context=await browser.newContext({viewport,isMobile:name!=='desktop',hasTouch:name!=='desktop'});await context.setOffline(true);
   for(const file of ['dinner_html.html','mixed_html.html','special_html.html','no_transfer_html.html']){
    const page=await context.newPage();const errors=[];const dialogs=[];const external=[];
    page.on('pageerror',e=>errors.push(e.message));page.on('dialog',async dialog=>{dialogs.push(dialog.message());await dialog.dismiss();});page.on('request',req=>{if(/^https?:/.test(req.url()))external.push(req.url());});
    await page.goto('file://'+path.join(generated,file));
    const state=await page.evaluate(()=>({viewportWidth:innerWidth,scrollWidth:document.documentElement.scrollWidth,scripts:document.scripts.length,images:document.images.length,body:document.body.innerText,balances:[...document.querySelectorAll('tbody tr')].map(row=>({person:row.cells[0].textContent,net:row.cells[3].textContent,color:getComputedStyle(row.cells[3]).color}))}));
    assert.ok(state.scrollWidth<=state.viewportWidth);assert.equal(state.scripts,0);assert.equal(state.images,0);assert.deepEqual(dialogs,[]);assert.deepEqual(errors,[]);assert.deepEqual(external,[]);
    if(file==='mixed_html.html'){
     assert.ok(state.body.includes('275.00 元'));assert.ok(state.body.includes('按实际金额分摊'));assert.ok(state.body.includes('小美 → 小红：20.00 元'));
     assert.equal(state.balances[0].color,'rgb(21, 128, 61)');assert.equal(state.balances[2].color,'rgb(185, 28, 28)');
    }
    if(file==='special_html.html')assert.ok(state.body.includes('茶</h3><script>alert(1)</script>&"\'|'));
    if(file==='no_transfer_html.html')assert.ok(state.body.includes('无需转账，所有人已平账。'));
    if(name==='mobile_emulation' && file==='mixed_html.html')await page.screenshot({path:'/tmp/spliteasy-stage5-mixed-mobile.png',fullPage:true});
    if(name==='desktop' && file==='special_html.html')await page.screenshot({path:'/tmp/spliteasy-stage5-special-desktop.png',fullPage:true});
    cases.push({profile:name,viewport,file,offlineLoaded:true,noPageOverflow:true,noScriptOrImageInjection:true,externalRequests:external,errors,passed:true});await page.close();
   }
   const page=await context.newPage();await page.setContent('<!doctype html><meta charset="utf-8">'+fs.readFileSync(path.join(generated,'error_html.html'),'utf8'));
   assert.equal(await page.locator('[role="alert"]').count(),1);assert.equal(await page.locator('script').count(),0);assert.ok((await page.locator('[role="alert"]').innerText()).includes('第 2 行：未知付款人：<script>'));await page.close();
   await context.close();
  }
  const result={browser:browser.version(),engine:'Linux Chrome headless',realPhoneTested:false,cases,errorHtmlSafeInAllProfiles:true,passed:true};fs.writeFileSync(path.join(generated,'browser-verification.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({browser:result.browser,cases:cases.length,realPhoneTested:false,passed:true}));
 }finally{await browser.close();}
})().catch(error=>{console.error(error);process.exitCode=1;});

`````

### scripts/verify_reports.py

`````text
#!/usr/bin/env python3
"""Run MoonBit's fixed demo, verify independent goldens and lossless integer JSON."""
import argparse
import json
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--target', choices=['native', 'js'], default='native')
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
run = subprocess.run(['moon', 'run', 'examples/report', '--target', args.target], cwd=root, text=True, capture_output=True)
if run.returncode:
    raise RuntimeError(run.stderr)
outputs = json.loads(run.stdout)
assert outputs['dinner_markdown'] == (root/'fixtures/expected_dinner.md').read_text()
assert outputs['mixed_json'] == (root/'fixtures/expected_mixed.json').read_text()
for key, amount in [('max_json', 9223372036854775807), ('large_json', 9007199254740993)]:
    data = json.loads(outputs[key])
    assert data['total_cents'] == amount
    assert type(data['total_cents']) is int
    assert data['balances'][0]['paid_cents'] == amount
    assert data['balances'][1]['balance_cents'] == -amount
    assert data['transfers'][0]['amount_cents'] == amount
    assert data['payments'][0]['shares'][0]['amount_cents'] == amount
special = json.loads(outputs['special_json'])
assert special['balances'][0]['person'] == '<img/src=x/onerror=alert(1)>'
assert special['payments'][0]['date'] == '</p><img/src=x/onerror=alert(2)>'
assert special['payments'][0]['description'] == '茶</h3><script>alert(1)</script>&"\'|\n第二行'
assert json.loads(outputs['controls_encoded']) == ''.join(map(chr,range(32)))+'中文😀<>&\u2028\u2029'
for key in ['dinner_html', 'mixed_html', 'special_html', 'no_transfer_html']:
    assert '<script' not in outputs[key]
    assert '<img/' not in outputs[key]
assert 'role="alert"' in outputs['error_html']
assert '<script>' not in outputs['error_html']
assert '无需转账' in outputs['no_transfer_html']
generated = root/'docs/generated'
generated.mkdir(exist_ok=True)
if args.target == 'native':
    extensions = {'dinner_markdown':'.md','mixed_json':'.json','dinner_html':'.html','mixed_html':'.html','max_json':'.json','large_json':'.json','special_html':'.html','special_markdown':'.md','special_json':'.json','no_transfer_html':'.html','error_html':'.html'}
    for key, ext in extensions.items():
        (generated/(key+ext)).write_text(outputs[key])
    (generated/'outputs-native.json').write_text(json.dumps(outputs,ensure_ascii=False,indent=2)+'\n')
else:
    assert outputs == json.loads((generated/'outputs-native.json').read_text()), 'Native and JS report bytes differ'
result = {'target':args.target,'golden_markdown_exact':True,'golden_json_exact':True,'int64_json_python_roundtrip':True,'all_control_characters_roundtrip':True,'special_text_roundtrip':True,'passed':True}
(generated/('verification-'+args.target+'.json')).write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(result,ensure_ascii=False))

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

///|
/// Read-only fields; allocated shares follow Ledger.people order.
pub struct PaymentReport {
  payer : String
  amount_cents : Int64
  split_mode : SplitMode
  shares : Array[Share]
  description : String
  date : String
} derive(Debug)

///|
pub extend PaymentReport with @debug.Debug::{to_repr}

///|
/// Created from validated input. No source arrays are reused.
pub struct SettlementReport {
  total_cents : Int64
  payments : Array[PaymentReport]
  balances : Array[PersonBalance]
  transfers : Array[Transfer]
} derive(Debug)

///|
pub extend SettlementReport with @debug.Debug::{to_repr}

///|
pub(all) enum ReportFormat {
  Markdown
  Html
  Json
} derive(Debug)

///|
pub extend ReportFormat with @debug.Debug::{to_repr}

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

///|
/// Exact two-decimal yuan display, including Int64.MIN_VALUE, without negating it.
pub fn format_money(amount : Int64) -> String {
  let whole = amount / 100L
  let remainder = amount % 100L
  let major = if whole < 0L { -whole } else { whole }
  let minor = if remainder < 0L { -remainder } else { remainder }
  let sign = if amount < 0L { "-" } else { "" }
  let padding = if minor < 10L { "0" } else { "" }
  "\{sign}\{major}.\{padding}\{minor}"
}

///|
pub fn format_signed_money(amount : Int64) -> String {
  if amount > 0L {
    "+" + format_money(amount)
  } else {
    format_money(amount)
  }
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

///|
test "money display exact decimals and signed zero" {
  for
    (amount, expected) in [
      (0L, "0.00"),
      (1L, "0.01"),
      (29L, "0.29"),
      (100L, "1.00"),
      (1230L, "12.30"),
      (-1L, "-0.01"),
      (-101L, "-1.01"),
      (9223372036854775807L, "92233720368547758.07"),
      (-9223372036854775808L, "-92233720368547758.08"),
    ] {
    assert_eq(@shared.format_money(amount), expected)
  }
  assert_eq(@shared.format_signed_money(1L), "+0.01")
  assert_eq(@shared.format_signed_money(-1L), "-0.01")
  assert_eq(@shared.format_signed_money(0L), "0.00")
}

`````

### shared/moon.pkg

`````text
import {
  "moonbitlang/core/debug",
}

supported_targets = "+native+js"

`````

### shared/render_html.mbt

`````text
///|
/// Escape every user string; never place user input into attributes or CSS.
pub fn escape_html(text : String) -> String {
  let out = StringBuilder()
  for ch in text.iter() {
    match ch {
      '&' => out.write_string("&amp;")
      '<' => out.write_string("&lt;")
      '>' => out.write_string("&gt;")
      '"' => out.write_string("&quot;")
      '\'' => out.write_string("&#39;")
      _ => out.write_char(ch)
    }
  }
  out.to_string()
}

///|
pub fn render_error_html(message : String) -> String {
  "<div class=\"spliteasy-error\" role=\"alert\"><strong>无法结算：</strong>" +
  escape_html(message) +
  "</div>"
}

///|
/// HTML fragment for embedding; all text fields, including dates, are escaped.
pub fn render_html(report : SettlementReport) -> String {
  let out = StringBuilder()
  out.write_string(
    "<section class=\"spliteasy-report\" aria-label=\"SplitEasy 结算单\">\n<h1>SplitEasy 结算单</h1>\n",
  )
  out.write_string(
    "<p>总消费：<strong>" +
    format_money(report.total_cents) +
    " 元</strong></p>\n<h2>消费明细</h2>\n",
  )
  if report.payments.is_empty() {
    out.write_string("<p>暂无消费记录。</p>\n")
  }
  for i, payment in report.payments {
    out.write_string(
      "<article><h3>第 \{i + 1} 笔：" +
      escape_html(payment.description) +
      "</h3>\n",
    )
    out.write_string(
      "<p>付款人：" +
      escape_html(payment.payer) +
      "；金额：" +
      format_money(payment.amount_cents) +
      " 元；分摊方式：" +
      mode_label(payment.split_mode) +
      "</p>\n",
    )
    out.write_string(
      "<p>日期：" +
      (if payment.date.is_empty() {
        "未填写"
      } else {
        escape_html(payment.date)
      }) +
      "</p>\n<ul>\n",
    )
    for share in payment.shares {
      out.write_string(
        "<li>" +
        escape_html(share.person) +
        "：" +
        format_money(share.amount_cents) +
        " 元</li>\n",
      )
    }
    out.write_string("</ul></article>\n")
  }
  out.write_string(
    "<h2>每人净额</h2>\n<div class=\"table-scroll\"><table><thead><tr><th>人员</th><th>已付（元）</th><th>应付（元）</th><th>净额（元）</th></tr></thead><tbody>\n",
  )
  for balance in report.balances {
    let (color, label) = if balance.balance_cents > 0L {
      ("#15803d", "应收")
    } else if balance.balance_cents < 0L {
      ("#b91c1c", "应付")
    } else {
      ("#475569", "已平账")
    }
    out.write_string(
      "<tr><td>" +
      escape_html(balance.person) +
      "</td><td>" +
      format_money(balance.paid_cents) +
      "</td><td>" +
      format_money(balance.owed_cents) +
      "</td><td style=\"color:" +
      color +
      "\">" +
      label +
      " " +
      format_signed_money(balance.balance_cents) +
      "</td></tr>\n",
    )
  }
  out.write_string("</tbody></table></div>\n<h2>转账清单</h2>\n")
  if report.transfers.is_empty() {
    out.write_string("<p>无需转账，所有人已平账。</p>\n")
  } else {
    out.write_string("<ol>\n")
    for transfer in report.transfers {
      out.write_string(
        "<li>" +
        escape_html(transfer.from) +
        " → " +
        escape_html(transfer.to) +
        "：" +
        format_money(transfer.amount_cents) +
        " 元</li>\n",
      )
    }
    out.write_string("</ol>\n")
  }
  out.write_string(
    "<p>结算计算完成。转账清单仅为建议，不代表已经完成付款。</p>\n</section>\n",
  )
  out.to_string()
}

///|
/// Standalone offline document; no scripts, external fonts, or CDN resources.
pub fn render_html_document(report : SettlementReport) -> String {
  "<!doctype html>\n<html lang=\"zh-CN\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><title>SplitEasy 结算单</title>\n<style>body{margin:0;background:#f4f7f8;color:#182b31;font:16px/1.6 system-ui,sans-serif}main{max-width:640px;margin:auto;padding:20px}article{background:white;border-radius:12px;padding:16px;margin:12px 0}h1,h2,h3,p,li,td,th{overflow-wrap:anywhere}table{width:100%;border-collapse:collapse;background:white}td,th{padding:8px;text-align:left;border-bottom:1px solid #dce5e8;vertical-align:top}th{white-space:nowrap}td:first-child,th:first-child{min-width:3em;white-space:pre-wrap}td:nth-child(2),td:nth-child(3){white-space:nowrap}td:last-child{overflow-wrap:normal}.table-scroll{overflow-x:auto}article h3,article p,li{white-space:pre-wrap}</style></head><body><main>\n" +
  render_html(report) +
  "</main></body></html>\n"
}

`````

### shared/render_json.mbt

`````text
///|
/// JSON string escaping; numeric serialization below never converts through Double.
pub fn quote_json(text : String) -> String {
  let out = StringBuilder()
  out.write_char('"')
  let hex = "0123456789abcdef"
  for ch in text.iter() {
    match ch {
      '"' => out.write_string("\\\"")
      '\\' => out.write_string("\\\\")
      '\n' => out.write_string("\\n")
      '\r' => out.write_string("\\r")
      '\t' => out.write_string("\\t")
      '\u{0008}' => out.write_string("\\b")
      '\u{000C}' => out.write_string("\\f")
      '<' => out.write_string("\\u003c")
      '>' => out.write_string("\\u003e")
      '&' => out.write_string("\\u0026")
      '\u{2028}' => out.write_string("\\u2028")
      '\u{2029}' => out.write_string("\\u2029")
      _ => {
        let code = ch.to_int()
        if code < 32 {
          out.write_string("\\u00")
          out.write_char(hex[code / 16].to_char().unwrap())
          out.write_char(hex[code % 16].to_char().unwrap())
        } else {
          out.write_char(ch)
        }
      }
    }
  }
  out.write_char('"')
  out.to_string()
}

///|
/// Stable schema/field order and integer tokens, including the full Int64 range.
/// Consumers must parse 64-bit integer tokens losslessly, not through JS Number.
pub fn render_json(report : SettlementReport) -> String {
  let out = StringBuilder()
  out.write_string(
    "{\"schema_version\":1,\"total_cents\":\{report.total_cents},\"balances\":[",
  )
  for i, balance in report.balances {
    if i > 0 {
      out.write_char(',')
    }
    out.write_string(
      "{\"person\":" +
      quote_json(balance.person) +
      ",\"paid_cents\":\{balance.paid_cents},\"owed_cents\":\{balance.owed_cents},\"balance_cents\":\{balance.balance_cents}}",
    )
  }
  out.write_string("],\"transfers\":[")
  for i, transfer in report.transfers {
    if i > 0 {
      out.write_char(',')
    }
    out.write_string(
      "{\"from\":" +
      quote_json(transfer.from) +
      ",\"to\":" +
      quote_json(transfer.to) +
      ",\"amount_cents\":\{transfer.amount_cents}}",
    )
  }
  out.write_string("],\"payments\":[")
  for i, payment in report.payments {
    if i > 0 {
      out.write_char(',')
    }
    let mode = match payment.split_mode {
      Equal => "equal"
      Exact => "exact"
    }
    out.write_string(
      "{\"payer\":" +
      quote_json(payment.payer) +
      ",\"amount_cents\":\{payment.amount_cents},\"split_mode\":" +
      quote_json(mode) +
      ",\"description\":" +
      quote_json(payment.description) +
      ",\"date\":" +
      quote_json(payment.date) +
      ",\"shares\":[",
    )
    for j, share in payment.shares {
      if j > 0 {
        out.write_char(',')
      }
      out.write_string(
        "{\"person\":" +
        quote_json(share.person) +
        ",\"amount_cents\":\{share.amount_cents}}",
      )
    }
    out.write_string("]}")
  }
  out.write_string("]}\n")
  out.to_string()
}

`````

### shared/render_md.mbt

`````text
///|
/// Escape user text for GFM tables/list text, including raw HTML and line breaks.
pub fn escape_markdown(text : String) -> String {
  let out = StringBuilder()
  let normalized = text
    .replace_all(old="\r\n", new="\n")
    .replace_all(old="\r", new="\n")
  for ch in normalized.iter() {
    match ch {
      '&' => out.write_string("&amp;")
      '<' => out.write_string("&lt;")
      '>' => out.write_string("&gt;")
      '\n' => out.write_string("<br>")
      '\t' => out.write_char(' ')
      '\\'
      | '|'
      | '*'
      | '_'
      | '['
      | ']'
      | '('
      | ')'
      | '`'
      | '#'
      | '+'
      | '-'
      | '!'
      | '~' => {
        out.write_char('\\')
        out.write_char(ch)
      }
      _ => out.write_char(ch)
    }
  }
  out.to_string()
}

///|
pub fn render_markdown(report : SettlementReport) -> String {
  let out = StringBuilder()
  out.write_string(
    "# SplitEasy 结算单\n\n总消费：" +
    format_money(report.total_cents) +
    " 元\n\n## 消费明细\n\n",
  )
  out.write_string(
    "| 序号 | 消费 | 付款人 | 金额（元） | 分摊方式 | 日期 |\n|---|---|---|---:|---|---|\n",
  )
  for i, payment in report.payments {
    out.write_string(
      "| \{i + 1} | " +
      escape_markdown(payment.description) +
      " | " +
      escape_markdown(payment.payer) +
      " | " +
      format_money(payment.amount_cents) +
      " | " +
      mode_label(payment.split_mode) +
      " | " +
      escape_markdown(payment.date) +
      " |\n",
    )
  }
  if report.payments.is_empty() {
    out.write_string("\n暂无消费记录。\n")
  }
  for i, payment in report.payments {
    out.write_string("\n第 \{i + 1} 笔分摊：")
    for j, share in payment.shares {
      if j > 0 {
        out.write_string("；")
      }
      out.write_string(
        escape_markdown(share.person) +
        " " +
        format_money(share.amount_cents) +
        " 元",
      )
    }
    out.write_string("\n")
  }
  out.write_string(
    "\n## 每人净额\n\n| 人员 | 已付（元） | 应付（元） | 净额（元） |\n|---|---:|---:|---:|\n",
  )
  for balance in report.balances {
    out.write_string(
      "| " +
      escape_markdown(balance.person) +
      " | " +
      format_money(balance.paid_cents) +
      " | " +
      format_money(balance.owed_cents) +
      " | " +
      format_signed_money(balance.balance_cents) +
      " |\n",
    )
  }
  out.write_string("\n## 转账清单\n\n")
  if report.transfers.is_empty() {
    out.write_string("无需转账，所有人已平账。\n")
  } else {
    for i, transfer in report.transfers {
      out.write_string(
        "\{i + 1}. " +
        escape_markdown(transfer.from) +
        " → " +
        escape_markdown(transfer.to) +
        "：" +
        format_money(transfer.amount_cents) +
        " 元\n",
      )
    }
  }
  out.write_string(
    "\n结算计算完成。转账清单仅为建议，不代表已经完成付款。\n",
  )
  out.to_string()
}

`````

### shared/render_test.mbt

`````text
///|
fn must_report(text : String) -> @shared.SettlementReport raise {
  match @shared.report_from_text(text) {
    Ok(report) => report
    Err(message) => fail(message)
  }
}

///|
fn special_report() -> @shared.SettlementReport raise {
  let a = "<img/src=x/onerror=alert(1)>"
  let b = "B|*_[x]"
  let ledger = stage3_ledger([a, b], [
    {
      ..exact_bill(a, 29L, [{ person: b, amount_cents: 29L, }]),
      description: "茶</h3><script>alert(1)</script>&\"'|\n第二行",
      date: "</p><img/src=x/onerror=alert(2)>",
    },
  ])
  match @shared.build_report(ledger) {
    Ok(report) => report
    Err(message) => fail(message)
  }
}

///|
test "HTML escape special characters" {
  assert_eq(@shared.escape_html("<&>\"'"), "&lt;&amp;&gt;&quot;&#39;")
  assert_eq(@shared.escape_html("中文 &lt;"), "中文 &amp;lt;")
}

///|
test "HTML user text cannot create elements or attributes" {
  let html = @shared.render_html(special_report())
  assert_false(html.contains("<script>"))
  assert_false(html.contains("<img/"))
  assert_true(html.contains("&lt;script&gt;alert(1)&lt;/script&gt;"))
  assert_true(html.contains("&lt;/p&gt;&lt;img/src=x/onerror=alert(2)&gt;"))
  assert_true(html.contains("&amp;&quot;&#39;"))
  assert_true(html.contains("B|*_[x]"))
}

///|
test "HTML shows total details modes shares and balances" {
  let report = must_report("人：A B\nA 1 饭\nB 0.29 茶 =A:0.29 B:0")
  let html = @shared.render_html(report)
  for
    part in [
      "1.29 元", "消费明细", "平均分摊", "按实际金额分摊", "B：0.00 元",
      "每人净额", "已付（元）", "应付（元）", "转账清单", "结算计算完成",
    ] {
    assert_true(html.contains(part))
  }
  assert_true(html.contains("color:#15803d"))
  assert_true(html.contains("color:#b91c1c"))
}

///|
test "HTML full document offline and fragment separation" {
  let report = must_report("人：A\nA 1 茶")
  let fragment = @shared.render_html(report)
  let document = @shared.render_html_document(report)
  assert_true(fragment.has_prefix("<section"))
  assert_true(document.has_prefix("<!doctype html>"))
  assert_true(document.contains("width=device-width"))
  assert_true(document.contains("lang=\"zh-CN\""))
  assert_true(document.contains("日期：未填写"))
  assert_false(document.contains("<script"))
  assert_false(document.contains("https://"))
  assert_true(document.contains(fragment))
}

///|
test "HTML safe error and source line" {
  assert_eq(
    @shared.render_error_html("<script>&\"'"),
    "<div class=\"spliteasy-error\" role=\"alert\"><strong>无法结算：</strong>&lt;script&gt;&amp;&quot;&#39;</div>",
  )
  let html = @shared.render_text_html("人：A B\n<script> 1 茶")
  assert_true(html.contains("第 2 行：未知付款人：&lt;script&gt;"))
  assert_false(html.contains("<script>"))
  assert_true(html.contains("role=\"alert\""))
}

///|
test "HTML and markdown empty and settled messages" {
  for text in ["人：A", "人：A\nA 1 茶"] {
    let report = must_report(text)
    assert_true(
      @shared.render_html(report).contains(
        "无需转账，所有人已平账。",
      ),
    )
    assert_true(
      @shared.render_markdown(report).contains(
        "无需转账，所有人已平账。",
      ),
    )
    assert_true(@shared.render_json(report).contains("\"transfers\":[]"))
  }
  assert_true(
    @shared.render_html(must_report("人：A")).contains(
      "暂无消费记录。",
    ),
  )
  assert_true(
    @shared.render_markdown(must_report("人：A")).contains(
      "暂无消费记录。",
    ),
  )
}

///|
test "Markdown table metacharacters and line endings escaped" {
  assert_eq(@shared.escape_markdown("A|B\\C"), "A\\|B\\\\C")
  assert_eq(
    @shared.escape_markdown("*_[x](y)`#+-!~"),
    "\\*\\_\\[x\\]\\(y\\)\\`\\#\\+\\-\\!\\~",
  )
  assert_eq(
    @shared.escape_markdown("<b>&\r\nx\ry\nz\tq"),
    "&lt;b&gt;&amp;<br>x<br>y<br>z q",
  )
}

///|
test "Markdown all user columns and transfers are escaped" {
  let md = @shared.render_markdown(special_report())
  assert_false(md.contains("<script>"))
  assert_false(md.contains("<img/"))
  assert_true(md.contains("B\\|\\*\\_\\[x\\]"))
  assert_true(md.contains("&lt;/p&gt;&lt;img/src=x/onerror=alert\\(2\\)&gt;"))
  assert_true(md.contains("<br>第二行"))
}

///|
test "JSON quotes slashes controls and script delimiters" {
  assert_eq(
    @shared.quote_json("\"\\\n\r\t\u{0008}\u{000C}\u{0000}\u{001F}"),
    "\"\\\"\\\\\\n\\r\\t\\b\\f\\u0000\\u001f\"",
  )
  assert_eq(
    @shared.quote_json("<>&\u{2028}\u{2029}"),
    "\"\\u003c\\u003e\\u0026\\u2028\\u2029\"",
  )
  assert_eq(@shared.quote_json("中文😀"), "\"中文😀\"")
}

///|
test "JSON stable empty golden" {
  assert_eq(
    @shared.render_json(must_report("人：A")),
    "{\"schema_version\":1,\"total_cents\":0,\"balances\":[{\"person\":\"A\",\"paid_cents\":0,\"owed_cents\":0,\"balance_cents\":0}],\"transfers\":[],\"payments\":[]}\n",
  )
}

///|
test "JSON 64-bit integer tokens are not strings or rounded numbers" {
  let json = @shared.render_json(
    must_report("人：A B\nA 92233720368547758.07 茶 =B:92233720368547758.07"),
  )
  assert_true(json.contains("\"amount_cents\":9223372036854775807"))
  assert_true(json.contains("\"balance_cents\":-9223372036854775807"))
  assert_false(json.contains("\"9223372036854775807\""))
  assert_false(json.contains("e+"))
  assert_true(
    @shared.render_json(
      must_report("人：A B\nA 90071992547409.93 茶 =B:90071992547409.93"),
    ).contains("\"total_cents\":9007199254740993"),
  )
}

///|
test "JSON payments include dates zero allocations and stable order" {
  let json = @shared.render_json(must_report("人：A B\nA 0.01 茶 @B A"))
  assert_true(json.contains("\"split_mode\":\"equal\""))
  assert_true(json.contains("\"date\":\"\""))
  assert_true(
    json.contains(
      "\"shares\":[{\"person\":\"A\",\"amount_cents\":0},{\"person\":\"B\",\"amount_cents\":1}]",
    ),
  )
  let special = @shared.render_json(special_report())
  assert_true(special.contains("\\u003cscript\\u003e"))
  assert_true(special.contains("\\n第二行"))
}

///|
test "renders are deterministic and do not mutate reports" {
  let report = must_report("人：A B\nA 1 茶")
  let md = @shared.render_markdown(report)
  let html = @shared.render_html(report)
  let json = @shared.render_json(report)
  for _ in 0..<3 {
    assert_eq(@shared.render_markdown(report), md)
    assert_eq(@shared.render_html(report), html)
    assert_eq(@shared.render_json(report), json)
  }
  assert_eq(report.balances[0].balance_cents, 50L)
  assert_eq(report.transfers[0].amount_cents, 50L)
  assert_eq(report.payments[0].shares[1].amount_cents, 50L)
}

///|
test "Markdown dinner full golden output" {
  let report = must_report(
    "人：小明 小红 小刚 小美\n小明 300 晚餐\n小红 120 加菜\n小刚 40 饮料 !小红",
  )
  assert_eq(
    @shared.render_markdown(report),
    "# SplitEasy 结算单\n\n总消费：460.00 元\n\n## 消费明细\n\n| 序号 | 消费 | 付款人 | 金额（元） | 分摊方式 | 日期 |\n|---|---|---|---:|---|---|\n| 1 | 晚餐 | 小明 | 300.00 | 平均分摊 |  |\n| 2 | 加菜 | 小红 | 120.00 | 平均分摊 |  |\n| 3 | 饮料 | 小刚 | 40.00 | 平均分摊 |  |\n\n第 1 笔分摊：小明 75.00 元；小红 75.00 元；小刚 75.00 元；小美 75.00 元\n\n第 2 笔分摊：小明 30.00 元；小红 30.00 元；小刚 30.00 元；小美 30.00 元\n\n第 3 笔分摊：小明 13.33 元；小刚 13.33 元；小美 13.34 元\n\n## 每人净额\n\n| 人员 | 已付（元） | 应付（元） | 净额（元） |\n|---|---:|---:|---:|\n| 小明 | 300.00 | 118.33 | +181.67 |\n| 小红 | 120.00 | 105.00 | +15.00 |\n| 小刚 | 40.00 | 118.33 | -78.33 |\n| 小美 | 0.00 | 118.34 | -118.34 |\n\n## 转账清单\n\n1. 小美 → 小明：118.34 元\n2. 小刚 → 小明：63.33 元\n3. 小刚 → 小红：15.00 元\n\n结算计算完成。转账清单仅为建议，不代表已经完成付款。\n",
  )
}

///|
test "JSON mixed full golden output" {
  let report = must_report(
    "人：小明 小红 小刚 小美 小李\n小明 200 晚餐\n小红 75 奶茶 =小明:12 小红:15 小刚:18 小美:14 小李:16",
  )
  assert_eq(
    @shared.render_json(report),
    "{\"schema_version\":1,\"total_cents\":27500,\"balances\":[{\"person\":\"小明\",\"paid_cents\":20000,\"owed_cents\":5200,\"balance_cents\":14800},{\"person\":\"小红\",\"paid_cents\":7500,\"owed_cents\":5500,\"balance_cents\":2000},{\"person\":\"小刚\",\"paid_cents\":0,\"owed_cents\":5800,\"balance_cents\":-5800},{\"person\":\"小美\",\"paid_cents\":0,\"owed_cents\":5400,\"balance_cents\":-5400},{\"person\":\"小李\",\"paid_cents\":0,\"owed_cents\":5600,\"balance_cents\":-5600}],\"transfers\":[{\"from\":\"小刚\",\"to\":\"小明\",\"amount_cents\":5800},{\"from\":\"小李\",\"to\":\"小明\",\"amount_cents\":5600},{\"from\":\"小美\",\"to\":\"小明\",\"amount_cents\":3400},{\"from\":\"小美\",\"to\":\"小红\",\"amount_cents\":2000}],\"payments\":[{\"payer\":\"小明\",\"amount_cents\":20000,\"split_mode\":\"equal\",\"description\":\"晚餐\",\"date\":\"\",\"shares\":[{\"person\":\"小明\",\"amount_cents\":4000},{\"person\":\"小红\",\"amount_cents\":4000},{\"person\":\"小刚\",\"amount_cents\":4000},{\"person\":\"小美\",\"amount_cents\":4000},{\"person\":\"小李\",\"amount_cents\":4000}]},{\"payer\":\"小红\",\"amount_cents\":7500,\"split_mode\":\"exact\",\"description\":\"奶茶\",\"date\":\"\",\"shares\":[{\"person\":\"小明\",\"amount_cents\":1200},{\"person\":\"小红\",\"amount_cents\":1500},{\"person\":\"小刚\",\"amount_cents\":1800},{\"person\":\"小美\",\"amount_cents\":1400},{\"person\":\"小李\",\"amount_cents\":1600}]}]}\n",
  )
}

`````

### shared/solve.mbt

`````text
///|
/// Build a fresh report after the core validates and settles the ledger.
pub fn build_report(ledger : Ledger) -> Result[SettlementReport, String] {
  let settlement = match settle_ledger(ledger) {
    Ok(value) => value
    Err(message) => return Err(message)
  }
  let payments : Array[PaymentReport] = []
  for payment in ledger.payments {
    payments.push({
      payer: payment.payer,
      amount_cents: payment.amount_cents,
      split_mode: payment.split_mode,
      shares: allocate_validated(ledger.people, payment),
      description: payment.description,
      date: payment.date,
    })
  }
  Ok({
    total_cents: settlement.total_cents,
    payments,
    balances: settlement.balances,
    transfers: settlement.transfers,
  })
}

///|
pub fn report_from_text(text : String) -> Result[SettlementReport, String] {
  match parse_text(text) {
    Ok(ledger) => build_report(ledger)
    Err(message) => Err(message)
  }
}

///|
pub fn render_report(
  report : SettlementReport,
  format : ReportFormat,
) -> String {
  match format {
    Markdown => render_markdown(report)
    Html => render_html_document(report)
    Json => render_json(report)
  }
}

///|
pub fn solve_ledger(
  ledger : Ledger,
  format : ReportFormat,
) -> Result[String, String] {
  match build_report(ledger) {
    Ok(report) => Ok(render_report(report, format))
    Err(message) => Err(message)
  }
}

///|
pub fn solve_text(
  text : String,
  format : ReportFormat,
) -> Result[String, String] {
  match report_from_text(text) {
    Ok(report) => Ok(render_report(report, format))
    Err(message) => Err(message)
  }
}

///|
/// A safe fragment for a future DOM adapter, including line-numbered errors.
pub fn render_text_html(text : String) -> String {
  match report_from_text(text) {
    Ok(report) => render_html(report)
    Err(message) => render_error_html(message)
  }
}

///|
fn mode_label(mode : SplitMode) -> String {
  match mode {
    Equal => "平均分摊"
    Exact => "按实际金额分摊"
  }
}

`````

### shared/solve_test.mbt

`````text
///|
test "report includes allocated payment details and source snapshots" {
  let people = ["A", "B"]
  let participants = ["B", "A"]
  let ledger = stage3_ledger(people, [equal_bill("A", 1L, participants)])
  let report = match @shared.build_report(ledger) {
    Ok(value) => value
    Err(message) => fail(message)
  }
  people.clear()
  participants.clear()
  ledger.payments.clear()
  assert_eq(report.total_cents, 1L)
  assert_eq(report.payments.length(), 1)
  check_shares(report.payments[0].shares, ["A", "B"], [0L, 1L])
  assert_eq(report.balances[0].person, "A")
  assert_eq(report.transfers[0].from, "B")
}

///|
test "solve text and ledger match for all formats" {
  let text = "人：A B\nA 1 茶"
  for format in [@shared.Markdown, @shared.Html, @shared.Json] {
    let from_text = match @shared.solve_text(text, format) {
      Ok(value) => value
      Err(message) => fail(message)
    }
    let from_ledger = match @shared.solve_ledger(must_parse(text), format) {
      Ok(value) => value
      Err(message) => fail(message)
    }
    assert_eq(from_text, from_ledger)
  }
}

///|
test "solve rejects invalid input before rendering every format" {
  for format in [@shared.Markdown, @shared.Html, @shared.Json] {
    match @shared.solve_text("人：A\nA 0 茶", format) {
      Err(message) =>
        assert_eq(message, "第 2 行：消费总金额必须大于零")
      Ok(_) => fail("invalid text rendered")
    }
    match
      @shared.solve_ledger(
        stage3_ledger(["A"], [equal_bill("A", 0L, ["A"])]),
        format,
      ) {
      Err(message) =>
        assert_eq(message, "第 1 笔消费：消费总金额必须大于零")
      Ok(_) => fail("invalid ledger rendered")
    }
  }
}

///|
test "report refuses ambiguity" {
  match
    @shared.build_report({
      ..stage3_ledger(["A"], []),
      ambiguous: ["不确定"],
    }) {
    Err(message) => assert_eq(message, "账单存在歧义：不确定")
    Ok(_) => fail("ambiguous report accepted")
  }
}

///|
test "HTML solve emits document and DOM helper emits fragment" {
  match @shared.solve_text("人：A B\nA 1 茶", @shared.Html) {
    Ok(value) => assert_true(value.has_prefix("<!doctype html>"))
    Err(message) => fail(message)
  }
  assert_true(@shared.render_text_html("人：A").has_prefix("<section"))
}

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

### shared/textparser.mbt

`````text
///|
/// Unicode whitespace tokenizer; optionally make reserved mode markers tokens.
fn text_tokens(input : String, markers : Bool) -> Array[String] {
  let tokens : Array[String] = []
  let word = StringBuilder()
  for ch in input.iter() {
    let marker = markers && (ch == '@' || ch == '!' || ch == '=')
    if ch.is_whitespace() || marker {
      if !word.is_empty() {
        tokens.push(word.to_string())
        word.reset()
      }
      if marker {
        let symbol = StringBuilder()
        symbol.write_char(ch)
        tokens.push(symbol.to_string())
      }
    } else {
      word.write_char(ch)
    }
  }
  if !word.is_empty() {
    tokens.push(word.to_string())
  }
  tokens
}

///|
fn people_header_body(line : String) -> String? {
  let prefix = StringBuilder()
  let body = StringBuilder()
  let mut separator_seen = false
  for ch in line.iter() {
    if !separator_seen && (ch == ':' || ch == '：') {
      separator_seen = true
    } else if separator_seen {
      body.write_char(ch)
    } else {
      prefix.write_char(ch)
    }
  }
  let words = text_tokens(prefix.to_string(), false)
  if separator_seen && words.length() == 1 && words[0] == "人" {
    Some(body.to_string())
  } else {
    None
  }
}

///|
fn description_from_tokens(tokens : Array[String], end : Int32) -> String {
  let result = StringBuilder()
  for i in 2..<end {
    if i > 2 {
      result.write_char(' ')
    }
    result.write_string(tokens[i])
  }
  result.to_string()
}

///|
fn parse_text_payment(
  people : Array[String],
  line : String,
) -> Result[Payment, String] {
  let tokens = text_tokens(line, true)
  let mut marker_index = -1
  for i, token in tokens {
    if token == "@" || token == "!" || token == "=" {
      if marker_index >= 0 {
        return Err(
          "每笔消费只能使用一次 @、! 或 = 标记，不得混用",
        )
      }
      marker_index = i
    }
  }
  let end = if marker_index < 0 { tokens.length() } else { marker_index }
  if end < 3 {
    return Err(
      "消费格式应为：付款人 金额 消费说明 [分摊标记]",
    )
  }
  let amount = match parse_money(tokens[1]) {
    Ok(value) => value
    Err(message) => return Err("消费金额：" + message)
  }
  let participants : Array[String] = []
  let shares : Array[Share] = []
  let mut mode = Equal
  if marker_index < 0 {
    for person in people {
      participants.push(person)
    }
  } else {
    if marker_index + 1 == tokens.length() {
      return Err("分摊标记后不能为空")
    }
    match tokens[marker_index] {
      "@" =>
        for i in (marker_index + 1)..<tokens.length() {
          participants.push(tokens[i])
        }
      "!" => {
        let excluded : Array[String] = []
        for i in (marker_index + 1)..<tokens.length() {
          let name = tokens[i]
          if !has_person(people, name) {
            return Err("未知排除人员：" + name)
          }
          if has_person(excluded, name) {
            return Err("排除人员重复：" + name)
          }
          excluded.push(name)
        }
        for person in people {
          if !has_person(excluded, person) {
            participants.push(person)
          }
        }
      }
      "=" => {
        mode = Exact
        for i in (marker_index + 1)..<tokens.length() {
          let (name_view, amount_view) = match tokens[i].split_once(":") {
            Some(value) => value
            None =>
              return Err(
                "实际金额格式应为 姓名:金额，使用英文冒号",
              )
          }
          let name = name_view.to_owned()
          if name.is_empty() {
            return Err("实际金额份额的姓名不能为空")
          }
          let share_amount = match parse_money(amount_view.to_owned()) {
            Ok(value) => value
            Err(message) =>
              return Err("人员“" + name + "”的分摊金额：" + message)
          }
          shares.push({ person: name, amount_cents: share_amount, })
        }
      }
      _ => return Err("无法识别分摊标记")
    }
  }
  let payment : Payment = {
    payer: tokens[0],
    amount_cents: amount,
    split_mode: mode,
    participants,
    shares,
    description: description_from_tokens(tokens, end),
    date: "",
  }
  match validate_payment_data(people, payment) {
    Ok(_) => Ok(payment)
    Err(message) => Err(message)
  }
}

///|
/// Parse an entire document or fail with its original 1-based physical line.
/// LF/CRLF/CR and an initial UTF-8 BOM are accepted. Blank lines are ignored.
/// No guessing, comments, quoting, escaped markers, dates, or network IO.
pub fn parse_text(input : String) -> Result[Ledger, String] {
  let text = match input.strip_prefix("\u{FEFF}") {
    Some(value) => value.to_owned()
    None => input
  }
  let normalized = text
    .replace_all(old="\r\n", new="\n")
    .replace_all(old="\r", new="\n")
  let people : Array[String] = []
  let payments : Array[Payment] = []
  let mut header_seen = false
  let mut total = 0L
  let mut line_number = 0
  for raw_line in normalized.split("\n") {
    line_number = line_number + 1
    let line = raw_line.to_owned()
    if text_tokens(line, false).is_empty() {
      continue
    }
    let prefix = "第 \{line_number} 行："
    match people_header_body(line) {
      Some(body) => {
        if header_seen {
          return Err(
            prefix +
            "人员名单只能声明一次，且必须位于消费之前",
          )
        }
        for name in text_tokens(body, false) {
          for ch in name.iter() {
            if ch == '@' || ch == '!' || ch == '=' || ch == ':' || ch == '：' {
              return Err(
                prefix + "文本模式姓名不能包含 @、!、= 或冒号",
              )
            }
          }
          people.push(name)
        }
        match validate_ledger({ people, payments: [], ambiguous: [], }) {
          Ok(_) => ()
          Err(message) => return Err(prefix + message)
        }
        header_seen = true
      }
      None => {
        if !header_seen {
          return Err(
            prefix +
            "首个非空行必须声明人员，例如：人：小明 小红",
          )
        }
        let payment = match parse_text_payment(people, line) {
          Ok(value) => value
          Err(message) => return Err(prefix + message)
        }
        total = match checked_add_cents(total, payment.amount_cents) {
          Ok(value) => value
          Err(message) => return Err(prefix + message)
        }
        payments.push(payment)
      }
    }
  }
  if !header_seen {
    return Err("第 1 行：缺少人员名单")
  }
  let ledger : Ledger = { people, payments, ambiguous: [], }
  match validate_ledger(ledger) {
    Ok(_) => Ok(ledger)
    Err(message) => Err("第 \{line_number} 行：" + message)
  }
}

`````

### shared/textparser_test.mbt

`````text
///|
fn must_parse(text : String) -> @shared.Ledger raise {
  match @shared.parse_text(text) {
    Ok(ledger) => ledger
    Err(message) => fail(message)
  }
}

///|
fn text_error(text : String, expected : String) -> Unit raise {
  match @shared.parse_text(text) {
    Err(message) => assert_eq(message, expected)
    Ok(_) => fail("invalid text accepted")
  }
}

///|
test "text default equal and multiword description" {
  let ledger = must_parse("人：小明 小红\n小明 12.30 晚餐 加菜")
  assert_eq(ledger.people.length(), 2)
  assert_eq(ledger.payments.length(), 1)
  let payment = ledger.payments[0]
  assert_eq(payment.payer, "小明")
  assert_eq(payment.amount_cents, 1230L)
  assert_true(payment.split_mode == @shared.Equal)
  assert_eq(payment.participants[0], "小明")
  assert_eq(payment.participants[1], "小红")
  assert_true(payment.shares.is_empty())
  assert_eq(payment.description, "晚餐 加菜")
  assert_eq(payment.date, "")
  assert_true(ledger.ambiguous.is_empty())
}

///|
test "text whitespace tabs Chinese spaces and attached markers" {
  let ledger = must_parse(
    "\u{3000}人：\tA\u{3000}B C\n\tA\t1.00\u{3000}午餐\t加菜@C A\u{3000}",
  )
  assert_eq(ledger.payments[0].description, "午餐 加菜")
  assert_eq(ledger.payments[0].participants[0], "C")
  check_shares(must_allocate(ledger.people, ledger.payments[0]), ["A", "C"], [
    50L, 50L,
  ])
}

///|
test "text ascii header and zero payment draft" {
  let ledger = must_parse("人: A B\n\n")
  assert_eq(ledger.people.length(), 2)
  assert_true(ledger.payments.is_empty())
}

///|
test "text BOM and CRLF preserve names" {
  let ledger = must_parse("\u{FEFF}人：A B\r\nA 0.29 茶\r\n")
  assert_eq(ledger.people[0], "A")
  assert_eq(ledger.payments[0].amount_cents, 29L)
}

///|
test "text CR line endings accepted" {
  let ledger = must_parse("人：A B\rA 1 茶\rB 2 饭")
  assert_eq(ledger.payments.length(), 2)
}

///|
test "text at selects without changing canonical remainder" {
  let ledger = must_parse("人：A B C D\nA 0.05 茶 @D B C")
  check_shares(
    must_allocate(ledger.people, ledger.payments[0]),
    ["B", "C", "D"],
    [1L, 2L, 2L],
  )
}

///|
test "text bang excludes one or multiple people" {
  let ledger = must_parse("人：A B C D\nA 1 茶 !B D")
  assert_eq(ledger.payments[0].participants.length(), 2)
  assert_eq(ledger.payments[0].participants[0], "A")
  assert_eq(ledger.payments[0].participants[1], "C")
}

///|
test "text exact amounts mode and zero share" {
  let ledger = must_parse("人：A B C\nA 0.29 奶茶 =B:0.29 A:0")
  let bill = ledger.payments[0]
  assert_true(bill.split_mode == @shared.Exact)
  assert_true(bill.participants.is_empty())
  assert_eq(bill.shares.length(), 2)
  assert_eq(bill.shares[0].person, "B")
  assert_eq(bill.shares[0].amount_cents, 29L)
  assert_eq(bill.shares[1].amount_cents, 0L)
  check_transfers(must_settle(ledger).transfers, [("B", "A", 29L)])
}

///|
test "text payer may not participate" {
  for
    text in [
      "人：A B\nA 1 茶 @B", "人：A B\nA 1 茶 !A", "人：A B\nA 1 茶 =B:1",
    ] {
    check_transfers(must_settle(must_parse(text)).transfers, [("B", "A", 100L)])
  }
}

///|
test "text all three marked modes across different payments" {
  let ledger = must_parse(
    "人：A B C\nA 1 饭\nB 0.03 茶 @C A\nC 2 车费 !B\nA 3 早餐 =B:1 C:2",
  )
  assert_eq(ledger.payments.length(), 4)
  check_settlement_invariants(must_settle(ledger))
}

///|
test "text empty document and blank document rejected" {
  for text in ["", "\n\t\u{3000}\n", "\u{FEFF}"] {
    text_error(text, "第 1 行：缺少人员名单")
  }
}

///|
test "text header required before payments" {
  text_error(
    "\nA 1 茶\n人：A B", "第 2 行：首个非空行必须声明人员，例如：人：小明 小红",
  )
}

///|
test "text empty or duplicate header people" {
  text_error("人：\n", "第 1 行：参与人员不能为空")
  text_error("人：A A", "第 1 行：人员姓名重复：A")
}

///|
test "text header cannot be repeated" {
  text_error(
    "人：A B\n\n人：A C", "第 3 行：人员名单只能声明一次，且必须位于消费之前",
  )
  text_error(
    "人：A B\nA 1 茶\n人: A B", "第 3 行：人员名单只能声明一次，且必须位于消费之前",
  )
}

///|
test "text reserved symbols rejected in names" {
  for name in ["A@B", "A!B", "A=B", "A:B", "A：B"] {
    text_error(
      "人：" + name,
      "第 1 行：文本模式姓名不能包含 @、!、= 或冒号",
    )
  }
}

///|
test "text payment requires payer amount and description" {
  for line in ["A", "A 1", "A 1 @B", "@A 1 茶"] {
    text_error(
      "人：A B\n" + line,
      "第 2 行：消费格式应为：付款人 金额 消费说明 [分摊标记]",
    )
  }
}

///|
test "text rejects zero and negative payment" {
  text_error("人：A\nA 0 茶", "第 2 行：消费总金额必须大于零")
  text_error(
    "人：A\nA -1 茶", "第 2 行：消费金额：金额格式错误：仅支持非负数字和小数点",
  )
}

///|
test "text rejects invalid precision and amount overflow" {
  text_error(
    "人：A\nA 0.001 茶", "第 2 行：消费金额：金额最多支持两位小数",
  )
  text_error(
    "人：A\nA 92233720368547758.08 茶", "第 2 行：消费金额：金额超出 Int64 整数分范围",
  )
}

///|
test "text unknown payer reports original line" {
  text_error("\n人：A B\n\nC 1 茶\n", "第 4 行：未知付款人：C")
}

///|
test "text unknown duplicate selected people" {
  text_error("人：A B\nA 1 茶 @C", "第 2 行：未知参与者：C")
  text_error("人：A B\nA 1 茶 @A A", "第 2 行：参与者重复：A")
}

///|
test "text unknown duplicate or all excluded people" {
  text_error("人：A B\nA 1 茶 !C", "第 2 行：未知排除人员：C")
  text_error("人：A B\nA 1 茶 !B B", "第 2 行：排除人员重复：B")
  text_error(
    "人：A B\nA 1 茶 !A B", "第 2 行：平均分摊至少需要一位参与者",
  )
}

///|
test "text each marker requires a payload" {
  for marker in ["@", "!", "="] {
    text_error(
      "人：A B\nA 1 茶 " + marker,
      "第 2 行：分摊标记后不能为空",
    )
  }
}

///|
test "text mixed or repeated markers rejected" {
  for
    suffix in [
      "@A !B", "!B =A:1", "=A:1 @A", "@A @B", "!A !B", "=A:1 =B:0", "@!", "==A:1",
    ] {
    text_error(
      "人：A B\nA 1 茶 " + suffix,
      "第 2 行：每笔消费只能使用一次 @、! 或 = 标记，不得混用",
    )
  }
}

///|
test "text exact requires ASCII colon and a name" {
  text_error(
    "人：A\nA 1 茶 =A", "第 2 行：实际金额格式应为 姓名:金额，使用英文冒号",
  )
  text_error(
    "人：A\nA 1 茶 =A：1", "第 2 行：实际金额格式应为 姓名:金额，使用英文冒号",
  )
  text_error(
    "人：A\nA 1 茶 =:1", "第 2 行：实际金额份额的姓名不能为空",
  )
}

///|
test "text exact amount errors include person and line" {
  text_error(
    "人：A\nA 1 茶 =A:", "第 2 行：人员“A”的分摊金额：金额不能为空",
  )
  text_error(
    "人：A\nA 1 茶 =A:-1", "第 2 行：人员“A”的分摊金额：金额格式错误：仅支持非负数字和小数点",
  )
  text_error(
    "人：A\nA 1 茶 =A:1.001", "第 2 行：人员“A”的分摊金额：金额最多支持两位小数",
  )
  text_error(
    "人：A\nA 1 茶 =A:1:0", "第 2 行：人员“A”的分摊金额：金额格式错误：仅支持非负数字和小数点",
  )
}

///|
test "text exact unknown or duplicate names" {
  text_error("人：A B\nA 1 茶 =C:1", "第 2 行：未知份额人员：C")
  text_error(
    "人：A B\nA 1 茶 =A:1 A:0", "第 2 行：份额人员重复：A",
  )
}

///|
test "text exact mismatch and share sum overflow" {
  text_error(
    "人：A B\nA 1 茶 =A:0.99", "第 2 行：个人分摊金额合计必须等于消费总金额",
  )
  text_error(
    "人：A B\nA 92233720368547758.07 茶 =A:92233720368547758.07 B:0.01", "第 2 行：金额合计超出 Int64 整数分范围",
  )
}

///|
test "text total overflow uses second payment physical line" {
  text_error(
    "人：A B\nA 92233720368547758.07 茶\n\nB 0.01 饭\n", "第 4 行：金额合计超出 Int64 整数分范围",
  )
}

///|
test "text CRLF error line counts blank lines" {
  text_error(
    "\u{FEFF}\r\n人：A B\r\n\r\nA 1 茶\r\nB 1 饭 @C\r\n", "第 5 行：未知参与者：C",
  )
}

///|
test "text stops at first bad line without guessing" {
  text_error(
    "人：A B\nC 1 茶\nA 2 饭 @D", "第 2 行：未知付款人：C",
  )
}

///|
test "text no quotes or comments supported" {
  text_error(
    "# 人：A B\nA 1 茶", "第 1 行：首个非空行必须声明人员，例如：人：小明 小红",
  )
}

///|
test "text repeated parse has independent arrays" {
  let text = "人：A B\nA 1 茶 @B"
  let first = must_parse(text)
  first.people.clear()
  first.payments.clear()
  let next = must_parse(text)
  assert_eq(next.people.length(), 2)
  assert_eq(next.payments.length(), 1)
  check_settlement_invariants(must_settle(next))
}

///|
test "text maximum and JS unsafe integers settle exactly" {
  for
    (amount, expected) in [
      ("90071992547409.93", 9007199254740993L),
      ("92233720368547758.07", 9223372036854775807L),
    ] {
    let result = must_settle(
      must_parse("人：A B\nA " + amount + " 茶 =B:" + amount),
    )
    check_transfers(result.transfers, [("B", "A", expected)])
    check_settlement_invariants(result)
  }
}

///|
test "text golden A dinner through parsing and settlement" {
  let text = "人：小明 小红 小刚 小美\n小明 300 晚餐\n小红 120 加菜\n小刚 40 饮料 !小红"
  let ledger = must_parse(text)
  assert_eq(ledger.payments[2].description, "饮料")
  let result = must_settle(ledger)
  assert_eq(result.total_cents, 46000L)
  check_balances(
    result.balances,
    ["小明", "小红", "小刚", "小美"],
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
test "text golden B mixed through parsing and settlement" {
  let text = "人：小明 小红 小刚 小美 小李\n小明 200 晚餐\n小红 75 奶茶 =小明:12 小红:15 小刚:18 小美:14 小李:16"
  let ledger = must_parse(text)
  assert_eq(ledger.payments[0].description, "晚餐")
  assert_eq(ledger.payments[1].description, "奶茶")
  let result = must_settle(ledger)
  assert_eq(result.total_cents, 27500L)
  check_balances(
    result.balances,
    ledger.people,
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
test "text first header colon wins even when a name has reserved punctuation" {
  text_error(
    "人: A：B", "第 1 行：文本模式姓名不能包含 @、!、= 或冒号",
  )
  text_error(
    "人 ： A:B", "第 1 行：文本模式姓名不能包含 @、!、= 或冒号",
  )
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
    match validate_payment_data(ledger.people, payment) {
      Err(message) => return Err(prefix + message)
      Ok(_) => ()
    }
    total = match checked_add_cents(total, payment.amount_cents) {
      Ok(value) => value
      Err(message) => return Err(prefix + message)
    }
  }
  Ok(())
}

///|
/// Internal shared rules: caller validates the people list first.
/// Keep payment errors free of location prefixes so adapters can add a line or index.
fn validate_payment_data(
  people : Array[String],
  payment : Payment,
) -> Result[Unit, String] {
  if !has_person(people, payment.payer) {
    return Err("未知付款人：" + payment.payer)
  }
  if payment.amount_cents <= 0L {
    return Err("消费总金额必须大于零")
  }
  match payment.split_mode {
    Equal => {
      if !payment.shares.is_empty() {
        return Err("平均分摊不能同时填写实际金额份额")
      }
      if payment.participants.is_empty() {
        return Err("平均分摊至少需要一位参与者")
      }
      let participants : Array[String] = []
      for name in payment.participants {
        if !has_person(people, name) {
          return Err("未知参与者：" + name)
        }
        if has_person(participants, name) {
          return Err("参与者重复：" + name)
        }
        participants.push(name)
      }
    }
    Exact => {
      if !payment.participants.is_empty() {
        return Err("按实际金额分摊不能同时填写平均参与者")
      }
      if payment.shares.is_empty() {
        return Err("按实际金额分摊至少需要一条份额")
      }
      let shares_seen : Array[String] = []
      let mut sum = 0L
      for share in payment.shares {
        if !has_person(people, share.person) {
          return Err("未知份额人员：" + share.person)
        }
        if has_person(shares_seen, share.person) {
          return Err("份额人员重复：" + share.person)
        }
        if share.amount_cents < 0L {
          return Err("个人分摊金额不能为负数：" + share.person)
        }
        shares_seen.push(share.person)
        sum = match checked_add_cents(sum, share.amount_cents) {
          Ok(value) => value
          Err(message) => return Err(message)
        }
      }
      if sum != payment.amount_cents {
        return Err("个人分摊金额合计必须等于消费总金额")
      }
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

在解压后的 spliteasy 根目录：

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
make verify-reports
```

verify-reports 额外需要 Python 3；先跑 Native 生成对照，再跑 JS 逐字比较。
只看结果可以直接用浏览器打开 docs/generated/mixed_html.html 或 dinner_html.html，无需先安装 MoonBit。
可选真实浏览器验证，需要 Node.js、Playwright 和可运行 Chrome/Chromium：

```bash
node scripts/verify_report_browser.cjs
```

本次实际通过 SPLITEASY_CHROME 指向已安装 Chrome for Testing 133；具体记录在 docs/stage5-verification.json。
浏览器模块不在默认搜索路径时可设置 SPLITEASY_PLAYWRIGHT。
当前不提供尚未实现的正式 CLI split/check 命令；不要把固定演示包当作阶段 7 CLI。

## 5. 每条命令的预期输出

| 命令 | 预期 |
|---|---|
| export PATH | 无输出，当前终端可以找到 moon |
| moon version / moonc -v | 已安装版本，退出 0 |
| moon fmt | 格式化成功，退出 0 |
| make check | Native/JS 检查成功，退出 0 |
| make test | Native/JS 各 Total tests: 121, passed: 121, failed: 0. |
| make build-native | Native 构建成功，退出 0 |
| make run-cli | SplitEasy: MoonBit shared core ready. |
| make build-web | 已生成 web/spliteasy.js，退出 0 |
| make verify-reports | 两个后端的各项 independent checks 为 true，退出 0 |
| node scripts/verify_report_browser.cjs | cases=12、passed=true，退出 0 |

IIFE 构建的 TypeScript 声明只支持 ESM 提示为已知工具链限制，不影响 JS 生成。

## 6. 实际运行结果

实际工具链：moon 0.1.20261012 (748b63c 2026-10-12)，moonc v0.10.15+943464bfa (2026-10-12)。
最终上述命令均实际退出 0。Native/JS 各 121 项通过、0 失败，检查无编译警告。
Native 实际运行，JS IIFE 实际生成。
完整命令、stdout、stderr、环境说明和退出码在 docs/stage5-verification.json。

| 验证 | 实际结果 |
|---|---|
| 四人晚餐完整 Markdown | 与事先写定黄金文本逐字一致 |
| 五人混合完整 JSON | 与事先写定黄金文本逐字一致 |
| Native/JS 全部演示输出 | 逐字一致 |
| Int64.MAX_VALUE 金额 JSON 回读 | Python 无损得到 9223372036854775807 分 |
| JS 安全整数外金额回读 | Python 无损得到 9007199254740993 分 |
| JSON 全部 32 个控制字符、中文、emoji | 回读一致 |
| 姓名、说明、日期、错误的 HTML 注入 | 未产生 script/img、未弹窗 |
| 桌面/390px/320px × 四份离线 HTML | 12 组全部通过，无页面横向溢出、无外部请求 |
| 三种尺寸的错误片段 | role=alert 正常、错误文本安全 |
| 应收/应付颜色 | 真实浏览器计算色值正确 |

生成样例：
- docs/generated/dinner_html.html、mixed_html.html：可直接打开的结算单。
- dinner_markdown.md、mixed_json.json：真实输出。
- max_json.json、large_json.json：大整数输出。
- special_html.html、special_markdown.md、special_json.json：人为注入测试文本。
- no_transfer_html.html、error_html.html：无转账和错误提示。
- outputs-native.json、verification-native.json、verification-js.json、browser-verification.json：独立证据。

## 7. 未验证事项

- 真实手机、iPhone Safari、Android 系统浏览器、Windows 本机和真实剪贴板。
- 阶段 6 的填表、人员/消费增删改、模式切换、复制、本地草稿和离线记账。
- 阶段 7 正式 CLI 参数、文件 IO、退出码和账单 JSON 输入。
- 阶段 8 AI、CI、GitHub Pages、公开仓库和赛事要求核验。
- JSON 消费者使用普通 JS JSON.parse 时，大整数会转为 Number 丢精度；必须选择无损整数解析路线。本阶段验证输出及 Python 回读，不承诺普通 JSON.parse 无损。
- 报表 JSON 与 Ledger 输入 schema 不相同，当前不能直接把报表 JSON 当作账单导入。
- 报告字段只读，但数组可修改；编辑账单后应重新生成报告，不把人工修改的报告数组当作已验证结果。

浏览器的手机尺寸模拟不等同真实手机；静态 HTML 离线打开也不等同业务网页离线计算。

## 8. 错误及修复说明

- 初版 JSON 控制字符编码时 UInt16.to_char 返回 Char?，与 write_char 需要的 Char 不符；对固定 ASCII 十六进制数字做已知有效转换后解决。
- 目视检查发现手机姓名列过窄，增加姓名最小列宽及数字列换行控制，随后重跑输出和浏览器验证。
- HTML 空日期明确显示“未填写”；没有修改原 date 或补造日期。单元测试覆盖此显示。
- 所有旧测试保留；新增测试未发生断言失败，未使用 --update 改写预期。
- 所有黄金文件预期由已确定金额和固定格式事先写定，生成器只比对，不覆盖正确预期。
- IIFE 的 TypeScript 声明提示继续保留于原始日志。

## 9. 简单中文技术解释

以前核心只给出计算结果，现在把它整理成一个统一报告。
三种输出共用同一份报告，不分别实现算法，所以金额和转账不会因输出格式不同而分叉。

| 场景 | 入口 |
|---|---|
| 结构化账单生成报告 | build_report |
| 文本生成报告 | report_from_text |
| 账单直接得到指定格式 | solve_ledger |
| 文本直接得到指定格式 | solve_text |
| 生成安全网页片段 | render_html / render_text_html |
| 生成完整离线 HTML | render_html_document |

HTML 把用户输入当成普通文字显示，即使姓名或说明包含 <script> 也不会当作标签执行。
Markdown 把竖线和换行等字符处理掉，避免用户内容破坏表格或生成标签。
JSON 金额直接写整数的十进制文本，不经过浮点数，因此完整保留整数分。

JSON 输出固定顺序为 schema_version、total_cents、balances、transfers、payments，末尾带一个换行。
所有金额字段使用整数分；HTML 和 Markdown 才把整数分精确显示为两位小数的元。
显示负数时只对除以 100 后的商和小余数取反，避免 Int64.MIN_VALUE 整体取反溢出。

普通 JS JSON.parse 对大数有精度限制，所以不能拿它的 Number 结果继续算账；这也是新增 Python 独立回读验证的原因。
报告中的“结算计算完成”仅表示清单计算完成，不代表收款或转账已经发生。

## 10. 本阶段验收标准

- [x] 统一 SettlementReport 含全部明细和结果，源账单数组不被复用或修改。
- [x] 文本/结构化账单可通过共享入口得到三种输出。
- [x] HTML 显示消费、模式、份额、余额、转账、错误及无转账提示。
- [x] HTML 所有用户文本转义，应收/应付颜色和文字标识正确。
- [x] Markdown 表格特殊字符、换行和 HTML 文本正确处理，完整黄金输出一致。
- [x] JSON 顺序稳定、金额为整数分数字，大整数无损输出与独立回读通过。
- [x] 两个核心黄金案例和原 100 项测试继续通过。
- [x] Native/JS 各 121 项通过，双端构建和运行成功。
- [x] 真实浏览器引擎的报表与注入检查通过，真实手机未冒充验收。
- [x] 提供可直接打开的报告样例、验证脚本和实际记录。
- [x] 未提前实现阶段 6 的业务表单。

## 11. Git commit 建议

```bash
git add shared examples/report scripts fixtures/expected_dinner.md fixtures/expected_mixed.json Makefile moon.mod README.md AI_USAGE.md CHANGELOG.md docs/output-format.md docs/stage5-verification.json docs/STAGE5_REPORT.md docs/generated
git commit -m "feat: add settlement reports and safe HTML Markdown JSON rendering"
```

尚未实际提交或推送。此前阶段尚未提交时需先建立基线，或用 git add . 并如实描述合并范围。
解压后的新目录不含 Git 内部元数据，必要时先 git init -b main。

## 12. 下一阶段预告

等待用户确认后执行阶段 6：手机填表网页，人员和消费增删改、平均/实际金额切换、统一结算、复制、本地草稿及浏览器验证。
本阶段到此停止。
内部交付截止仍为 2026-10-24 23:59（Asia/Shanghai）。
