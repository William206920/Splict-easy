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

## GitHub 仓库

https://github.com/William206920/Splict-easy

阶段 1—5 按五次独立提交同步，后续约定与历史报告状态说明见 docs/GITHUB_SYNC.md。
