# SplitEasy 协作约定

- 需求以用户确认修订的 docs/PROJECT_PLAN.md（SplitEasy 方案 V3.2）为准；内部交付截止 2026-10-24 23:59（Asia/Shanghai）。
- 阶段 8 必须交付可实际演示的 CLI AI 自然语言解析：发送前确认、解析后预览确认、MoonBit 校验和歧义阻断；真实调用未验证时不得用模拟测试冒称完成。普通分账保持离线，AI 仍由用户选择启用。
- GitHub 仓库已由用户确认：https://github.com/William206920/Splict-easy，默认分支 main。
- 用户已授权后续阶段完成并验证后同步 GitHub；按阶段保留独立提交，不需要再次确认上传。
- 每阶段完成后仍须停止，等待用户确认下一阶段；不提前实现后续阶段。
- 保留现有历史，不强制推送，不删除失败测试，不虚构验证记录。
- 核心业务用 shared 中的 MoonBit 实现，金额使用 Int64 整数分，网页和 CLI 共用。
- 验证使用 make check、make test 及适用构建；报表改动还需 make verify-reports。
- 浏览器模拟与真实手机验收分别记录；CI/部署完成前不宣称已上线。
- 历史报告保持原样，最新同步状态见 docs/GITHUB_SYNC.md。
