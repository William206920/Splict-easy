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
