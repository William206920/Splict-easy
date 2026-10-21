# SplitEasy：MoonBit 原生 Windows AA 分账应用

解决的问题：聚餐平摊与不同价格的个人消费混在一起时，手工统计和相互抵扣容易出错。

产品：原生 Windows 填表应用，人员与消费可编辑，平均/实际金额可混用，统一结算、复制、文件保存与导出。配套 Native CLI 和可选的自然语言 AI 输入。

实现：主要业务与界面控制由 MoonBit 编写，Native 入口通过少量 C FFI 使用 Win32 Unicode 控件、文件、剪贴板和后台 WinHTTP。无需 HTML/WebView。

正确性：Int64 整数分、溢出拒绝；按名单顺序分尾差；确定性贪心尽量减少转账。两个固定黄金案例及 400 组守恒/回放账单测试。JSON 整数直接从原始字面量读取，不经过浮点。

AI：只解析为 Ledger，不能替代计算。外发前确认、结果预览再确认、MoonBit 校验与歧义阻断。普通功能离线。模拟 HTTP 和真实模型演示分别验收；后者当前待配置和记录。

交付：MIT 源码、按阶段提交、Windows 构建 CI、便携 ZIP、用户级安装/卸载包、SHA256、README、AI_USAGE 和演示说明。

验证边界：已有 Windows CI、原生控件、CLI 和安装流程自动记录；用户桌面 DPI/输入法/视觉和真实模型待验证，不宣称赛事已验收。

仓库：https://github.com/William206920/split-easy
内部交付目标：2026-10-24 23:59 Asia/Shanghai。
