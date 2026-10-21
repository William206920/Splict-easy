# Windows 重做版阶段 1 交付报告

日期：2026-10-15。当前阶段仅原生环境和启动骨架，未进入阶段 2。

## 1. 完成功能

- 旧实现从 main 移除，保留 Git 历史。
- V4.0 完整方案改为 Windows 原生开源桌面应用。
- 新 MoonBit Native 主入口调用 shared，通过 Win32 C FFI 创建窗口、Unicode 文本与按钮。
- 按钮事件回到 MoonBit，由 MoonBit 更新文字；关闭消息正常退出。
- Windows 构建脚本和最小 CI；自动检查真实隐藏窗口的 Unicode 回读、事件和关闭。

以上 Windows 行为已有源码和检查入口，实际验证状态见第 6—7 节；不能仅凭源码认定已在 Windows 运行成功。

## 2. 新增和修改文件

moon.mod、toolchain.version、shared/、platform/win32/、cmd/desktop/、cmd/smoke/、scripts/build-windows.ps1、.github/workflows/native-windows.yml、.gitignore、AGENTS.md、README.md、LICENSE、CHANGELOG.md、AI_USAGE.md、docs/PROJECT_PLAN.md、工具链和验证记录。

## 3. 全部文件完整内容

本阶段完整文件均提交在当前仓库，各目录可直接浏览或下载源码 ZIP，不以片段替代完整工程。阶段源码汇编见 docs/STAGE1_SOURCE.md；完整方案独立存放，工具帮助输出见 TOOLCHAIN_LINUX.txt。

## 4. 运行命令

Linux 只用于编译检查：

```bash
moon version --all
moon fmt --check
moon check --target native
moon build --target native
moon build --target native --release
moon check --target js
moon test --target native
```

Windows 源码构建和集成检查：

```powershell
$env:PATH = "$env:USERPROFILE\.moon\bin;$env:PATH"
./scripts/build-windows.ps1 -Smoke
./dist/SplitEasy.exe
```

## 5. 预期输出

- 检查和构建退出 0。
- 当前无业务单元测试，moon test 会报告 0 项，不能描述为核心算法已验收。
- Windows 集成检查：`PASS: Win32 Unicode + MoonBit event + shared core + close`。
- 程序启动显示标题与中文 ready 信息；点击验证按钮后变为验证成功。
- Linux 执行 GUI 或窗口检查必须退出 1，不能模拟 Windows 通过。

## 6. 实际运行结果

当前本地环境为 Linux x86_64；moon 0.1.20261012，moonc v0.10.15+943464bfa。

| 检查 | 当前实际结果 |
| --- | --- |
| 版本和五项帮助命令 | 已实际执行，退出 0 |
| 格式检查 | 通过 |
| Native check/debug build/release build | 通过，仅 Linux 平台路径 |
| shared 的 JS 检查 | 通过，没有构建网页 |
| Native 业务单元测试 | 0 项；阶段 1 暂无金额算法 |
| Linux 运行 GUI/smoke | 均拒绝运行，退出 1，符合预期 |
| Windows CI 编译与隐藏窗口检查 | 已通过，Windows Server 2025 x64，真实 Win32 窗口检查 |
| 用户 Windows 桌面实测 | 未验证 |

Windows 运行：[38719888097](https://github.com/William206920/Split-easy/actions/runs/38719888097)，验证源码提交 48a17f45b81b54df95dc6aeeaabfe4d181ca6f1d。输出 `PASS: Win32 Unicode + MoonBit event + shared core + close`。可执行文件已生成并作为 Actions artifact 上传；这不是最终安装包。完整 Windows 证据见 verification-windows.json。

完整本地记录：verification-linux.json。Linux 的 .exe 后缀来自构建器命名，并不代表生成了 Windows PE 程序。

## 7. 未验证事项

Windows CI 已通过；用户 Windows 10/11 桌面、真实鼠标键盘、中文输入法、DPI、便携依赖与安装卸载未验收。第一阶段只有文本和按钮，还未提供账单输入。

## 8. 错误与修复

- GitHub API 不接受本次直接创建空树的请求；改为创建仅含新方向 README 的树，旧源码已移除。没有因此强制改写历史。
- 官方 Linux 安装脚本在容器中解压时因归属设置失败；使用同一官方下载包，以不恢复原归属方式解压并设置执行权限，完成 core bundle。
- 首次格式检查发现新工具链要求的格式与 Int32 名称规范；实际执行 moon fmt 后重新检查通过。
- 没有删除测试或修改黄金预期。旧业务测试未移植，当前明确记录为 0 项。

## 9. 中文技术说明

MoonBit 程序是入口。它调用 Windows 系统创建控件，Windows 把按钮事件交回 MoonBit，MoonBit 再调用共享包生成显示内容。C 文件只是平台桥接，尚未包含任何分账算法。

## 10. 阶段验收门槛

阶段 1 的技术路线自动验收已通过：取得 Windows 原生构建、Unicode、按钮事件、更新和关闭的实际成功记录。用户桌面显示、输入与 DPI 继续单列待验证。当前停止，等待用户确认后才进入阶段 2。

## 11. Git 提交

- 重置：cda8e70db40d50acc9059737bfc9a0badee54606。
- 新阶段源码：48a17f45b81b54df95dc6aeeaabfe4d181ca6f1d，`feat: bootstrap MoonBit native Windows desktop application`。
- 重置、新方案与阶段 1 源码均已同步 main，之后的文档提交补录 Windows 通过证据。

## 12. 下一阶段

用户确认后才进入阶段 2，实现 Int64 金额、Ledger、两种分摊模式及校验。当前不提前实现。

## 技术依据

- https://docs.moonbitlang.com/en/stable/language/ffi.html
- https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html
- https://learn.microsoft.com/en-us/windows/win32/learnwin32/your-first-windows-program
