# AI 使用记录

2026-10-15：用户明确移除旧网页实现并选择 Windows 桌面平台。AI 整理 V4.0 方案，编写 MoonBit Native 骨架、Win32 平台桥接、PowerShell 构建和最小 Windows CI。

业务规则沿用用户确定的方案。阶段 1 仅验证启动窗口、Unicode 文本和事件；尚未实现新版本的金额、账单、分账或 AI 产品功能。

技术依据：MoonBit 官方 C FFI/包配置与 Microsoft Win32 文档，见 docs/PROJECT_PLAN.md 和阶段报告。C 桥接为本次实现，不复制旧网页代码。

实际验证结果与未验证项以 docs/STAGE1_REPORT.md 为准，不将旧 Native/JS 各 121 项测试当作新成果。用户尚未人工验收当前 Windows UI，AI 不替用户声称已理解或审核全部代码。
