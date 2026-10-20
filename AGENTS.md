# SplitEasy Windows 桌面应用协作约定

- 2026-10-20 用户将线上 AI 服务商改为 Kimi，替代此前的 DeepSeek 选择；继续部署在 Vercel，面向所有访客，密钥仅在服务端，额度和双重确认要求不变。

- 2026-10-16 最新用户授权：额外新增 Vercel 在线版，向所有访客提供维护者自己的 DeepSeek API；该网页版允许 HTML/CSS 与浏览器适配，Windows 原生版继续保留。业务、整数金额、分摊和 AI 校验复用 MoonBit，密钥仅在服务端。此前“不使用 HTML/WebView”继续适用于 Windows 桌面程序。

- 按用户确认的 Windows 原生应用方向和 docs/PROJECT_PLAN.md V4.0 工作。
- MoonBit 为主，Win32 C stub 只提供平台能力；不使用 HTML/WebView 界面。
- 平均/实际金额混合分摊、Int64 整数分、名单尾差和确定性贪心规则不变。
- 2026-10-15 最新用户授权：连续自主完成所有后续阶段，每阶段验证后独立提交 GitHub，不再询问是否进入下一阶段。实际密钥和桌面实测的缺失单列，不冒称通过。
- 旧代码已按用户要求移除；不把旧测试计入新实现，不改写已有 Git 历史。
- 用户授权验证后按阶段同步 William206920/Splict-easy，不需重复询问上传。
- Windows 实际结果、Linux 编译、自动窗口检查和用户桌面实测分别记录。
- Windows 原生构建入口 scripts/build-windows.ps1 -Smoke；核心检查 moon check --target native。
- 阶段 8 必交付 GUI/CLI AI，含发送确认、解析预览确认、歧义阻断和真实演示。
- 内部截止 2026-10-24 23:59 Asia/Shanghai。
