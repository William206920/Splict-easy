# AI 使用记录

## 2026-10-15 · 阶段 1

工具：ChatGPT 中的 Codex，使用真实终端、官方文档检索和本地构建工具。
用户提供 SplitEasy V3.1 开发方案，要求阶段结束后等待确认。
AI 创建共享包、Native/JS 入口、DOM 桥接、构建脚本和本阶段文档。
本阶段没有实现整数分、分摊算法、Ledger、AI API 或业务界面。

实际执行命令和输出见 docs/verification.json；工具帮助输出见 docs/toolchain.txt。
安装首次因 tar 恢复 uid/gid 被容器拒绝而失败，使用 TAR_OPTIONS=--no-same-owner 重试。
不得将自动化冒烟检查写成人工验收；真实手机和用户电脑验证尚未完成。
不宣称已经创建公开 GitHub 仓库、部署 Pages 或通过赛事审核。

后续阶段再记录整数分设计、贪心局限、AI 解析风险和具体修复。
