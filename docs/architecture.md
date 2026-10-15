# 阶段 1 技术核实

核实日期：2026-10-15。以官方 stable 文档和安装后命令结果为依据。

- moon：0.1.20261012 (748b63c 2026-10-12)。
- moonc：v0.10.15+943464bfa (2026-10-12)。
- 新工程采用 moon.mod / moon.pkg，不使用旧 JSON 清单。
- 模块默认 Native，支持 +native+js；shared 双端；web 仅 JS；cli 仅 Native。
- pkgtype(kind: "executable") 声明两个可执行入口。
- web 的 options(link: { "js": { "format": "iife" } }) 已实际生成 IIFE。
- 当前产物路径 _build/js/release/build/web/web.js 已实测。
- Native 可执行产物通过 moon run cli/main --target native 实际运行。
- Native IO、参数解析和网络 AI 本阶段不实现；官方 Native CLI 示例使用 async 包与 core/argparse，后续阶段再核对当时版本。
- 所有当前包都不依赖第三方模块；仅使用随工具链提供的标准库。

官方资料：
https://www.moonbitlang.com/download/
https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html
https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html
https://docs.moonbitlang.com/en/stable/tutorial/cli-quickstart.html
https://docs.moonbitlang.com/en/stable/language/ffi.html

实际错误和修复：
1. 官方安装脚本首次 tar 恢复 uid/gid 失败：用 TAR_OPTIONS=--no-same-owner 重试，成功。
2. 首次 moon fmt 在工程父目录执行失败：切换到 spliteasy 根目录后成功。
3. 黑盒测试隐式导入警告：改为 @shared.startup_message() 后检查无警告。
4. 首次 IIFE 构建提示 TypeScript 声明仅支持 ESM：本项目不依赖 TypeScript 声明，JS 产物正常生成。
5. 真实浏览器缺失且下载包无效：不伪造验收，明确留待用户或后续环境验证。

仓库：已 git init -b main。未建立远程仓库、未提交或推送、未部署。
赛事资格与官方截止尚未独立核验；本阶段继续遵守用户给定内部交付截止。
