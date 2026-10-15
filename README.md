# SplitEasy · 原生 Windows AA 分账应用

使用 MoonBit Native 与 Windows 原生控件开发的 MIT 开源应用。目标是混合记录平均与实际金额消费，统一生成结算清单。

**当前仅新阶段 1：启动窗口、中文文本及按钮事件。Windows 原生构建和隐藏窗口集成检查已通过；账单、分账、保存和 AI 尚未实现。**

- [完整方案 V4.0](docs/PROJECT_PLAN.md)
- [阶段 1 报告和实际验证](docs/STAGE1_REPORT.md)
- [Windows 自动构建](../../actions/workflows/native-windows.yml)

旧网页代码已应用户要求移除，历史仍可追溯。旧版测试不适用于当前实现。

[下载阶段 1 Windows 可执行文件 ZIP](https://github.com/William206920/Splict-easy/actions/runs/38719888097/artifacts/11964670982)（GitHub Actions artifact，需登录 GitHub；当前只有启动窗口）。

## 构建与启动

运行正式程序时不需要安装 MoonBit；当前尚不是最终安装包。成功的 Actions 运行会附带阶段 1 可执行文件。

从源码构建需要 Windows x64、MoonBit stable（见 toolchain.version）、Visual Studio Build Tools 的 C++ 桌面工具及 Windows SDK。在仓库根目录用 PowerShell 运行：

```powershell
$env:PATH = "$env:USERPROFILE\.moon\bin;$env:PATH"
./scripts/build-windows.ps1 -Smoke
./dist/SplitEasy.exe
```

脚本定位已安装的 MSVC 环境，不需要永久修改系统配置。MoonBit 安装按[官方说明](https://docs.moonbitlang.com/en/stable/tutorial/tour.html)操作。

集成检查预期输出：

```text
PASS: Win32 Unicode + MoonBit event + shared core + close
```

双击程序后应出现“SplitEasy · AA 分账器”，显示中文启动信息。点击“验证共享核心”，消息应改变。关闭窗口应退出。需要在用户桌面另测显示缩放、键盘和后续中文输入；自动检查不能替代这些项目。

## 当前架构

- shared：纯 MoonBit 启动函数，后续承载全部金额和结算逻辑。
- platform/win32：MoonBit 声明与少量 C 平台桥接。
- cmd/desktop：MoonBit 主入口、事件与 shared 调用。
- cmd/smoke：真实 Windows 隐藏窗口检查，验证 Unicode 回读、按钮事件、更新和关闭。

界面不使用 HTML 或 WebView。Linux 仅可检查和编译平台无关路径；平台 stub 会明确拒绝运行 GUI，不模拟 Windows 成功。

## 后续功能与隐私

整数分、两种分摊、混合结算和确定性贪心按原规则重做。普通功能完全本地离线。AI 解析在阶段 8 实现，主动启用、发送前确认、解析后预览确认，计算仍由 MoonBit 完成。内部交付目标为 2026-10-24 23:59（Asia/Shanghai）。

本仓库保留真实验证结果，不将自动构建或隐藏窗口检查称为用户桌面实测。许可证：[MIT](LICENSE)。
