# 阶段 8：AI 与参赛交付

1. 实现 GUI/CLI 自然语言解析、两次确认、共享校验/结算、异步 WinHTTP、取消、模型错误与文档。准备一页说明、示例、许可和发布素材。
2. 文件 ai/、platform/http、AI 页面与 CLI 接线、模拟集成脚本、说明和 third_party 许可。
3. 完整源码在本阶段独立提交中。
4. moon fmt；moon test --target native/js；moon build --target native --release；Windows build-windows.ps1 -Smoke（包含 verify_ai.py）；package/verify-installer.ps1。
5. 预期：模拟模型与真实传输分层验证，取消/歧义/错误不结算，普通模式保持离线。
6. 本地实际 Native 19 组、JS 18 组通过；CLI 独立黄金和 release 构建通过。Windows 的后台请求/模拟服务/GUI 预览/安装检查随提交执行，后续归档。
7. 真实模型演示待配置与验收；用户 Windows 10/11、DPI、输入法、视觉布局与人工安装待验收。不将模拟标为真实演示。
8. 修正标准 JSON 的数字精度路径，HTTP 使用 C 字节副本跨线程；GUI 错误清理采用 errdefer，不让后台失败改变账单。
9. 模型只输出 Ledger；外发须同意、预览后再确认，最终净额与转账始终由 MoonBit 核心完成。
10. AI 实现/模拟验收与真实模型验收分开，缺少真实配置时不宣称整个 AI 参赛交付已完成。
11. feat(stage8): add consent-gated AI parsing and delivery documentation。
12. 自动继续整体回归与发布预览；真实模型和用户桌面仍保留待验收。

## Windows 实际结果补录

[运行 38724606635](https://github.com/William206920/split-easy/actions/runs/38724606635) 成功。Windows Native 19 组、本地 WinHTTP 模拟、两次确认/取消/超时/错误、GUI 异步预览、安装后 GUI/CLI 与卸载保留数据均实际通过。真实模型仍待配置。

最终预览修复及完整回归见 VERIFY_CURRENT.md；最新 Windows Native 21 组、JS 本地 19 组，示例截图和安装产物已生成。真实模型仍待配置，Release 未发布。
