# SplitEasy v0.9.3 · 分享结算单与两表 Excel

[下载新版](https://github.com/William206920/split-easy/releases/tag/v0.9.3)。默认导出自包含 HTML 结算单，适合离线核对和打印。在浏览器打印窗口选择保存为 PDF；本版没有直接 PDF 编码器。

Excel 可选，严格只有成员转账明细、消费明细两张表，支持筛选、冻结表头、两位小数和超大金额精度保护。保留无需转出的成员；每行一笔转账，消费列出每人的承担额。CSV、Markdown、JSON 及纯文本也可使用。[使用说明](EXPORTS.md)。

标签对应源码 `276f990f380b6ecb3e5b3870542c317449719e9c`。[Windows PR 检查](https://github.com/William206920/split-easy/actions/runs/39410822398)通过 40 项 Native 测试、原生 HTML/XLSX/CSV 实际写入后的独立读取校验、GUI/CLI、模拟 AI、安装卸载及截图检查；[网页检查](https://github.com/William206920/split-easy/actions/runs/39410822565)通过 65 项 MoonBit JS、17 项 Node 和 ZIP/XML/CSV 校验。[发行构建](https://github.com/William206920/split-easy/actions/runs/39411126931)从标签重建后上传附件。

程序未签名。真实模型、用户 Excel/WPS 手工打开、打印窗口保存 PDF 和 Windows 10/11 DPI/输入法验收仍单列待完成，不能由结构检查替代。

---

# SplitEasy v0.9.2 · AI 追加账单与核对预览

[下载新版](https://github.com/William206920/split-easy/releases/tag/v0.9.2)。支持安装包和便携包，普通记账离线可用。

- AI 确认默认追加已有账本，旧消费、原名单顺序和已打开文件路径保留。
- 文本/JSON 导入支持追加或替换；独立核对页显示笔数、金额变化和逐笔份额。
- 重复消费需单独核对，替换已有账本需明确确认；取消、过期预览、溢出和重复点击受到保护。
- 桌面 AI 需要自己的服务与 Key。Kimi 示例：`https://api.moonshot.cn/v1` / `kimi-k2.6`。Key 不写入账单或草稿；共享 Kimi 继续由在线版服务端提供。

源码标签对应 `57104f7c78267d931c43c195f0bebce3346c9cec`。[Windows PR 检查](https://github.com/William206920/split-easy/actions/runs/39407328361)通过 35 项原生测试、GUI/CLI 与模拟 HTTP AI 集成、安装卸载和截图检查；[网页检查](https://github.com/William206920/split-easy/actions/runs/39407328495)通过 60 项 MoonBit JS 与 15 项网关/桥接测试。发行构建和附件校验见 [Release 工作流](https://github.com/William206920/split-easy/actions/runs/39408109390)。

程序未签名。真实原生模型调用及用户 Windows 10/11 的 DPI、输入法人工验收仍待完成，模拟 AI 通过不代表真实模型实测。[详细说明](DESKTOP_092.md)。

---

# SplitEasy v0.9.1 · 首个公开版本

发布日期：2026-10-20。MoonBit 驱动的 Windows 原生分账应用，适用于聚餐、旅行和合租记账。本次沿用桌面程序版本号 0.9.1，作为首个公开预览版本发布。

## 下载与运行

从 [GitHub Release](https://github.com/William206920/split-easy/releases/tag/v0.9.1) 下载：

- `SplitEasy-0.9.1-Windows-x64-Setup.exe`：Windows 10/11 x64 当前用户安装，无需管理员权限。
- `SplitEasy-0.9.1-Windows-x64-Portable.zip`：完整解压后运行 `SplitEasy.exe`，附带 `spliteasy-cli.exe`。
- `SHA256SUMS.txt`：使用 `Get-FileHash <文件> -Algorithm SHA256` 核对下载文件。

运行无需安装 MoonBit、Python 或浏览器。普通记账完全离线；账单、草稿与密钥不随发行包分发。MIT 许可及第三方声明随包保留。

## 主要功能

- 独立成员管理、消费增删改、平均与实际金额混合分摊。
- Int64 整数分计算、按名单顺序处理尾差、确定性生成转账清单。
- 文本和 JSON 导入，附填写说明、示例与确认预览。
- 本地账单、自动草稿、复制及导出，配套命令行工具。
- 原生 AI 解析支持兼容 Chat Completions 的服务：发送前确认、结构与金额校验、歧义阻断、逐笔预览后确认；需自行配置服务和 API Key。

无需安装也可使用 [在线版](https://spliteasy-online.vercel.app/)。在线版提供服务端共享 Kimi K2.6，每 IP 每小时 10 次、全站每天 100 次；共享密钥不包含在 Windows 程序中。

## 验证与已知限制

Windows 二进制来自 main 提交 `9e3110d89bda850043db1e4ee0abf23d7e6dde68` 的 [成功构建](https://github.com/William206920/split-easy/actions/runs/39374279549)，此后发行准备仅修改文档。CI 已完成核心与 CLI 检查、原生窗口集成、模拟 HTTP AI、安装和卸载验证。页面截图使用内置示例账单。

程序尚未进行代码签名。自动验证环境为 Windows Server 2025 x64；用户 Windows 10/11 的 DPI、输入法与视觉体验仍待人工验证。原生 GUI/CLI 的真实模型调用尚未完成实测；在线版 Kimi 的真实解析验证不等同于桌面端验证。
