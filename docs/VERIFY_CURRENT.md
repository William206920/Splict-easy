# 当前预览：整体验证与剩余验收

## 0.9.1 成员与导入修复（2026-10-16）

独立成员页、导入指南与示例、跨页输入保留和替换账单保护已完成。[修复说明及原生截图](MEMBERS_IMPORT_FIX.md)。[Windows CI 38855867925](https://github.com/William206920/Splict-easy/actions/runs/38855867925) 全部通过，Native 24 组，JS 本地 20 组；C 平台桥接未改动。真实模型和用户桌面等人工验收边界不变。

[下载 0.9.1 验证包](https://github.com/William206920/Splict-easy/actions/runs/38855867925/artifacts/12027202151)。已下载核对 SHA256 并实际查看成员与导入截图。

## 0.9.0 原生界面优化（2026-10-16）

侧栏导航、账单概览、消费/转账/成员分区及消费、AI、导入表单已重新设计。[本轮说明及四页实际截图](UI_REDESIGN.md)。

[Windows CI 38853402455](https://github.com/William206920/Splict-easy/actions/runs/38853402455) 全部通过，源码 `12ddc99`。Native 21 组、桌面与布局/遮挡检查、CLI、AI 模拟、安装卸载和截图均通过；JS 核心本地 19 组通过。真实模型及用户桌面 DPI/输入法仍待验收。

[下载 0.9.0 验证包](https://github.com/William206920/Splict-easy/actions/runs/38853402455/artifacts/12026535125)。Artifact ZIP SHA256：`318cd60ad203dfdf5662fe66dd9e20347eb3005f938a271b9534c468bb356f87`。已下载核对哈希，并逐页查看截图；未发布 GitHub Release。

以下保留 0.8.0 的各阶段历史记录。

用户已授权连续推进，各阶段均已独立提交，不再等待阶段间确认。旧实现仍只保留在历史中。

## 阶段与 Windows 实际记录

| 阶段 | 独立源码提交 | Windows CI |
| --- | --- | --- |
| 1 | [48a17f4](https://github.com/William206920/Splict-easy/commit/48a17f45b81b54df95dc6aeeaabfe4d181ca6f1d) | [通过](https://github.com/William206920/Splict-easy/actions/runs/38719888097) |
| 2 | [797a555](https://github.com/William206920/Splict-easy/commit/797a5553dbc8e1cf765526a28ab8fc1632de826d) | [通过](https://github.com/William206920/Splict-easy/actions/runs/38720762654) |
| 3 | [341c37c](https://github.com/William206920/Splict-easy/commit/341c37ce5dd1cd72fdd0f118adf885e5bd5ac0a2) | [通过](https://github.com/William206920/Splict-easy/actions/runs/38720925482) |
| 4 | [0db2a49](https://github.com/William206920/Splict-easy/commit/0db2a4937191bb4bd46a7981c9bc9116aee7e34e) | [通过](https://github.com/William206920/Splict-easy/actions/runs/38721336321) |
| 5 | [edc2052](https://github.com/William206920/Splict-easy/commit/edc2052b33079aa6ea9d0b918df1d8434f6a75a3) | [通过](https://github.com/William206920/Splict-easy/actions/runs/38721534925) |
| 6 | [5cb05ee](https://github.com/William206920/Splict-easy/commit/5cb05ee973ca2e00875ce5373da29d4f7299a304) | [通过](https://github.com/William206920/Splict-easy/actions/runs/38722487735) |
| 7 | [dcfd19d](https://github.com/William206920/Splict-easy/commit/dcfd19d1de166921aa5d35e4916640014ea9a115) | [通过](https://github.com/William206920/Splict-easy/actions/runs/38723034006) |
| 8 | [7488aa3](https://github.com/William206920/Splict-easy/commit/7488aa304b2399f36ab003341c410206578f123f) | [通过](https://github.com/William206920/Splict-easy/actions/runs/38724606635) |

Windows 为 Server 2025 x64 的实际原生环境。每阶段的完整源码以对应提交为准，后续修复保留正常提交，不改写历史。

## 已执行的验证

- 固定 MoonBit v0.10.15+943464bfa；Native 检查和 release 构建。
- 当前本地 Native 21 组、JS 19 组测试，含 400 组守恒、确定性和回放案例。
- 四人晚餐和五人混合黄金金额、转账顺序。
- Int64 上限、0.29、零份额、非法金额、总额溢出和日期。
- 原始行号、BOM/CRLF、严格账单 JSON 和大整数无损往返。
- Session 原子修改、关联删除阻断、改名及旧结果失效。
- Windows 原生控件、两种消费、编辑删除、混合结算、JSON 导入、剪贴板。
- UTF-8 文件、原子保存、保存失败保留原文件。
- CLI 进程的完整 JSON/Markdown 黄金、输出文件、stderr、退出码和最大整数。
- Windows WinHTTP 的本地模拟：真实 HTTP 传输、两次确认、取消、EOF、歧义、错误金额、无效 JSON、认证失败、超时。
- GUI 后台请求、遮盖密钥、逐笔预览、取消不修改旧账单、确认后黄金结算。
- Windows 安装器、便携包、SHA256；安装、重复安装、安装后 GUI/CLI、关闭、卸载及用户数据保留。
- 第三方许可随包保留。CI 可能有行尾转换和 Actions Node 版本提示，未隐瞒为应用错误。

源码提交后运行最终构建和截图流程，下载产物在成功的 Actions 运行中。GitHub Release 尚未发布；自动审批拒绝了长期 contents:write 与自动发布配置，已移除这部分，保留只读 CI。

## 剩余验收，不能冒称通过

1. **真实模型演示**：尚无可用真实服务配置，本地 fixture 不是模型。按 AI_DEMO.md 在用户本机配置，记录服务、模型、日期和实际结果，不发送 Key 到聊天。
2. **用户桌面**：Windows 10/11、中文输入法、100/125/150/200% DPI、视觉布局和真实打开/保存对话框人工体验。
3. **参赛手续**：队伍、报名、交流群与最终正式提交由用户核对。不能声称赛事已接受或官方审核已通过。

## 版本边界

当前为开发预览，完整实现与自动验证不等于真实模型和人工桌面验收。支持 Windows x64；单币种、单笔一个付款人；桌面最多 200 人、5000 笔。未签名，不承诺商店或其他平台。

最后检查中还调整了 GUI 零金额：填写 0 视为未参与，不写入多余的份额引用；核心继续接受显式零份额。该调整不改变金额或黄金结果，并在原生集成中加入断言。最终 CI 将重新执行。

内部完成目标仍为 2026-10-24 23:59 Asia/Shanghai。


## 最终回归修复记录

运行 38725626002 在超时模拟断言失败，其余核心、桌面、CLI 已通过。原因是仅依赖系统网络超时不能保证固定总等待时间。修复增加应用层 30 秒总超时，晚到响应不会应用，旧后台请求结束前不能启动新请求；原超时断言保留不放宽。将重新验证后记录最终结果。

截图复核发现 String.replace 仅替换首个匹配，导致原生报表后续换行丢失。修正为 replace_all，并补原生 CRLF 回读、重复换行归一化和重复 Markdown 特殊字符断言。金额和转账黄金不变，继续重跑 Windows 回归。

## 最终通过记录

最终源码：3c084c4b10fcb605d5124a357add2edbead63ff0。
[Windows 运行 38726605287](https://github.com/William206920/Splict-easy/actions/runs/38726605287) 已成功，Native 21 组、CLI 黄金、原生完整操作与 CRLF 回读、HTTP 模拟/超时/取消、异步 GUI 预览、安装/卸载和示例截图生成均通过。JS 当前本地 19 组通过。

[下载已验证预览包](https://github.com/William206920/Splict-easy/actions/runs/38726605287/artifacts/11967903629)（需登录 GitHub）。ZIP 包含 Setup.exe、Portable.zip、SHA256SUMS.txt、preview.png 和系统 DLL 依赖清单。程序为 Windows x64 PE，GUI 子系统为 2、CLI 为 3；前一轮产物已下载检查过哈希、格式与随包许可，最终产物以本次 CI 的校验清单为准。

- Artifact ID：11967903629
- Artifact ZIP SHA256：sha256:87a18a977bffdf7f41e70535f684d575806be8b49cf164fa3c8e6a5a18f0f4d3
- 安装包、便携包、截图已生成，未发布 GitHub Release。
- 新截图由真实原生程序生成；CRLF 多行回读已通过。用户桌面视觉、DPI、输入法及真实模型仍待验收。

自动审批拒绝了长期仓库写权限和自动 Release 发布配置，认为未获明确发布授权。该配置已移除，工作流保持 contents:read；当前通过 Actions 提供产物。Release 需用户明确授权后另行处理。
