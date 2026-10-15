# SplitEasy Windows 桌面应用协作约定

- 按用户确认的 Windows 原生应用方向和 docs/PROJECT_PLAN.md V4.0 工作。
- MoonBit 为主，Win32 C stub 只提供平台能力；不使用 HTML/WebView 界面。
- 平均/实际金额混合分摊、Int64 整数分、名单尾差和确定性贪心规则不变。
- 当前只执行阶段 1；每阶段结束等待用户确认下一阶段。
- 旧代码已按用户要求移除；不把旧测试计入新实现，不改写已有 Git 历史。
- 用户授权验证后按阶段同步 William206920/Splict-easy，不需重复询问上传。
- Windows 实际结果、Linux 编译、自动窗口检查和用户桌面实测分别记录。
- Windows 原生构建入口 scripts/build-windows.ps1 -Smoke；核心检查 moon check --target native。
- 阶段 8 必交付 GUI/CLI AI，含发送确认、解析预览确认、歧义阻断和真实演示。
- 内部截止 2026-10-24 23:59 Asia/Shanghai。
