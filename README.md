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
