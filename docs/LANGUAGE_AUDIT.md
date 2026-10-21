# MoonBit 语言占比与赛事要求核对

核对日期：2026-10-20。目标为用户要求的 **GitHub 默认分支 MoonBit 占比严格高于 65%**。这不是声称主办方已经验收通过。

## 赛事原文与边界

已重新阅读[官网参赛流程](https://moonbitlang.github.io/Hackathon2026/#process)、[官网当前源文件](https://github.com/moonbitlang/Hackathon2026/blob/main/src/App.tsx)，并在真实浏览器读取官网链接的[正式章程](https://bxup9uklfcb.feishu.cn/wiki/Dx4Bwd6D1i3GfHkajQCcF7SznEd)。

- 官网及章程均要求 MoonBit 为主要实现语言；本次读取的相关条款没有给出 65% 数字，65% 是本仓库采用的用户验收线。
- 须公开完整源码与开发历史，提供 README、可运行示例、覆盖检查/构建/测试的 CI，以及核心功能测试；采用 OSI 认可许可证，说明参考来源与许可证。
- 正式章程的项目验收清单还列出 **发布到 mooncakes.io**。本仓库的在线部署不能替代该项发布，当前不声称已完成 mooncakes 发布或赛事正式验收。
- 官网首页当前写 2026-10-31 报名与验收截止；链接章程（页面显示 10 月 10 日修改）的时间表仍写十月赛 10 月 24 日，部分阶段标题也保留九月日期。两处存在冲突，需以赛事组最终通知为准；本项目内部截止继续保持 2026-10-24 23:59 Asia/Shanghai。
- 报名、队伍/交流群信息、mooncakes 发布和原生 GUI/CLI 真实模型及用户桌面验收仍单列，不能用语言比例冒称所有参赛手续已通过。

## 原因与真实迁移

GitHub 使用 [Linguist](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-repository-languages) 按源码字节统计，既不是按文件数，也不是按 MoonBit 业务功能数量统计。

修改前 GitHub `/languages` 返回：MoonBit 121042、JavaScript 406598、C 34349、HTML 10418、PowerShell 9767、Python 7267、Inno Setup 1232 字节。MoonBit 为 **20.492%**。

1. `web/generated/core.mjs` 中 368976 字节实际来自 MoonBit 编译器。按 [Linguist 的生成文件规则](https://github.com/github-linguist/linguist/blob/main/docs/overrides.md#generated-code) 将它准确标记 `linguist-generated=true`，仍保留文件、构建指纹和 CI 重编译比对。仅修正此项时 MoonBit 约为 **54.598%**，并不够。
2. 把原 `web/public/app.mjs` 中的应用控制迁入 `web/bridge/browser.mbt`：导航、成员/消费表单、文件导入、预览确认、导出及共享 AI 流程。原 JavaScript 文件只保留两行启动调用。
3. `web_state.mbt` 管理草稿冲突、损坏草稿、原子修改、预览版本、AI 同意、取消与过期响应；`web_render.mbt` 管理安全 HTML 转义、成员关联、消费/转账/余额展示与表单字符串。金额继续使用 MoonBit Int64，不经 JS Number。
4. `gateway.mbt` 接管服务端配置、URL 接受规则、额度参数校验、请求同意与长度、Kimi/DeepSeek 请求策略及截断响应检查。`api/parse.mjs` 保留 HTTP、密钥读取、密码学散列与恒定时间比较、Redis 原子请求和超时等平台能力。
5. `browser_io.mbt` 只有短 JS FFI，提供 DOM、文件、存储、剪贴板、计时器、HTTP 与 AbortController；不把整段旧 JavaScript 塞进 MoonBit 文件冒充迁移。审计脚本同时列出 `#|` 外部代码字节。
6. 手写 CSS 原来是长行紧凑格式，被 Linguist 的压缩文件启发式自动排除。显式设 `web/public/style.css linguist-generated=false`，使其按真实 CSS 正常计入。没有将手写 C/JS/HTML 改标成 MoonBit，也没有隐藏测试或辅助脚本。

## 当前源码字节核对

以下是全部相关源码按 LF 归一化后的本地统计，与本仓库当前 Linguist 分类对应；最终 GitHub 重算结果以远端 `/languages` 为准。

| 语言 | 字节 |
| --- | ---: |
| MoonBit | 182263 |
| JavaScript | 22161 |
| C | 34349 |
| CSS | 12220 |
| HTML | 10418 |
| PowerShell | 9767 |
| Python | 7267 |
| Inno Setup | 1232 |
| 合计 | 279677 |

MoonBit：**65.169%**，含真实测试和平台 FFI，与 GitHub 的字节口径一致。编译后的 `core.mjs` 不重复计入源码。PNG、许可证、Markdown、账单样例等非编程/标记源码不进入这个分母。

运行 `node scripts/check-language-share.mjs` 可复查；网页 CI 已增加门禁，比例不严格高于 65% 就失败。脚本是本仓库扩展名集合的可复现估算，不冒称实现了完整 Linguist；`.gitattributes` 与最终 GitHub API 一起核对。

## 本轮验证

- 固定工具链 `moon fmt`、JS 类型检查、**45 项 MoonBit JS 测试**通过；其中新增浏览器状态/展示与服务端策略回归，覆盖损坏草稿、多标签冲突、XSS、Int64、预览前不修改、预览过期、取消/旧响应、HTTP 输入、URL、限额、请求策略与截断。
- **14 项 Node 网关/桥接测试**通过，覆盖真实导出模块与 Node HTTP 适配；实际 Kimi 凭据不参与测试、不写入生成产物。
- 原生类型检查通过。Windows 编译、安装和原生集成以本轮远端 Windows CI 为准，不能将本地类型检查称为桌面验收。
- 真实浏览器本地验证：140 元示例的预览/确认、独立成员页、成员添加、实际金额合计不符阻断、0.29 元平均消费保存及刷新恢复（总计 140.29 元）通过。

## 合并后的实际远端结果

PR #5 的源码 `fa6bf76` 已经 [Linux 网页 CI 39374059201](https://github.com/William206920/split-easy/actions/runs/39374059201) 和 [Windows 原生 CI 39374059443](https://github.com/William206920/split-easy/actions/runs/39374059443) 验证通过，包含生成文件一致性、占比门禁、原生构建/集成、打包和安装校验。合并提交为 `9e3110d`。

合并后实际请求 GitHub `/repos/William206920/split-easy/languages`，返回的各语言字节与上表逐项相同，MoonBit **65.16910578989334%**。真实仓库页面显示 MoonBit **65.2%**，CSS **4.4%**，确认是远端重算结果。

Vercel 自动部署已生效，公开 `app.mjs` 是两行 MoonBit 启动入口；生产 `core.mjs` SHA256 与该源码的本地编译产物完全相同。公开状态接口返回 Kimi K2.6 启用。再次通过真实生产 HTTP 接口发送虚构三人示例，返回 200 和有效预览；用本轮 MoonBit 产物独立复核，得到 140 元、三人三笔消费以及小红/小刚分别向小明转账 20 元。未覆盖用户账单，也未改动服务端 Key。
