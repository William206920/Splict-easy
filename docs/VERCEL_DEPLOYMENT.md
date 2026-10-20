# Vercel 在线版

2026-10-16 用户授权：保留 Windows 原生版，同时增加浏览器在线版，所有访客可使用维护者的 DeepSeek API。API Key 不得出现在源码、网页、浏览器存储、构建日志、截图或客户端包中。

## 架构

- `web/bridge/*.mbt` 导出 MoonBit 共享核心。所有金额转换、成员/消费增删改、名单规则、Int64 整数分、结算、AI 校验复用 `shared` 和 `ai`，不在 JavaScript 中重写分账算法。
- `web/public` 仅实现响应式界面、浏览器存储和事件适配。浏览器把账单作为不透明字符串传递给 MoonBit，显示金额由 MoonBit 以字符串返回；不把账单的整数分送入 `JSON.parse` 后再保存，避免超出 JS 安全整数范围的精度损失。
- `api/parse.mjs` 是 Vercel Node.js Function。模型地址、Key、模型均只读取服务端环境变量，不接受客户端覆盖。默认公开使用，可切换为邀请码模式。
- 发送前勾选同意并再次确认 → 服务端限制额度 → DeepSeek → MoonBit 严格校验 → 返回逐笔预览 → 用户确认替换 → MoonBit 本地结算。AI 不负责计算净额。
- 普通账单保存在当前浏览器 `localStorage`，不会自动跨设备同步。损坏草稿保留备份路径，多标签冲突阻止覆盖。不要把“本地保存”等同永久可靠存储，提供 JSON/Markdown/文本导出。

## Vercel 项目配置

从 `William206920/Splict-easy` 导入项目；根目录为仓库根目录，Framework 选 Other，构建和输出由 `vercel.json` 定义。Node.js 22。Git 分支变更会触发 Vercel 构建。

Vercel 构建使用已检入的 MoonBit 编译产物 `web/generated/core.mjs`，不要求 Vercel 额外安装 MoonBit。构建先检查源文件指纹。GitHub CI 用固定工具链重新编译并检查生成文件一致，防止生成产物与 MoonBit 源码脱节。首次 Linux CI 发现 Windows/Linux 编译器对数字指数前导零的打印有差异（`1e+012` 与 `1e+12`）；在生成步骤仅规范数字 token 的指数，保留字符串/注释不变，并增加回归。没有跳过生成产物一致性检查。

在 Vercel 项目 Settings → Environment Variables 中填写：

| 变量 | 内容 |
| --- | --- |
| `MOONBIT_BASE_URL` | `https://api.deepseek.com` |
| `MOONBIT_MODEL` | `deepseek-flash` |
| `MOONBIT_API_KEY` | 维护者自己的 Key，设置为敏感环境变量 |
| `UPSTASH_REDIS_REST_URL` | 持久化额度存储的 HTTPS REST 地址 |
| `UPSTASH_REDIS_REST_TOKEN` | 额度存储凭据，设置为敏感环境变量 |
| `SPLITEASY_ACCESS_MODE` | `public`（用户已选择公开） |
| `SPLITEASY_HOURLY_LIMIT` | 默认 `10`，每 IP 每小时 |
| `SPLITEASY_DAILY_LIMIT` | 默认 `100`，全站每天，按 UTC 日期 |

DeepSeek 官方文档说明 DeepSeek-V4.1-Flash 使用 API 模型名 `deepseek-flash`。服务端在官方域名下启用 JSON 输出，并关闭思考模式以缩短解析时间。来源：[首次调用](https://api-docs.deepseek.com/)、[JSON 输出](https://api-docs.deepseek.com/guides/json_mode/)、[思考模式](https://api-docs.deepseek.com/guides/thinking_mode/)。这是接口配置核对，不能代替真实调用验证。

额度存储可在 Vercel Marketplace 连接 Upstash Redis；只有在用户确认的免费额度/已有套餐内设置，不能未经授权购买服务。使用原子 Redis Lua 脚本跨实例限制每 IP 每小时与全站每天请求数。只存散列 IP 标识与计数，最长 48 小时失效，不存账单文字。无额度服务或存储故障时不发送模型请求；不以进程内 Map 冒称全局限流。失败/歧义模型请求仍占额度，取消浏览器请求也不保证上游停止计费。更换 Key 或额度命名空间会重置计数。请求数限额不是精确的货币预算，建议同时在模型账户设置可用额度。

额度配置同时接受 Vercel Marketplace 集成常见的 `KV_REST_API_URL` / `KV_REST_API_TOKEN` 别名。

环境变量仅在服务端使用。修改后需重新部署；没有配置完成时，网站普通分账可用，AI 显示未配置并返回 503。不得将用户提供的真实 Key 发到聊天或写进 `.env.example`。

## 本地构建与验证

```text
moon fmt --check
moon check --target native
moon test --target js
node scripts/build-web.mjs --compile
node --test tests/web.test.mjs
node scripts/serve-web.mjs
```

浏览器打开 `http://127.0.0.1:4173`。Node 22+；编译需使用 `toolchain.version` 固定的 MoonBit。

开发时如果需要环境变量，可使用 Node 的 `--env-file=.env.local`，该文件已忽略。不要把真实密钥放进命令行参数或日志。生成产物随源码提交；修改 MoonBit 后必须重新编译。

## 验收状态

2026-10-16 本地实际验证：`moon fmt --check`、Native/JS 类型检查、MoonBit JS 20 组测试通过；新增 Node 浏览器桥接/HTTP 网关 13 组测试通过。原有混合黄金、0.29 尾差、大于 JS Number 安全范围的 Int64 金额往返、关联成员删除保护、无效导入、歧义、截断、额度与上游故障均验证。首次新测试发现根地址会产生双斜杠，已修复；新测试里录入错误的黄金期望已对照原有 shared/settle_wbtest.mbt 纠正，原有正确黄金与算法未变。

实际打开浏览器：独立成员页、添加成员、刷新恢复、实际份额合计不符阻断、正确保存、无效导入不覆盖；1280 与 390 像素视口下页面没有横向整体溢出。截图来自本地真实运行及示例数据，不是生产部署或真实 AI 证据。

![在线版桌面布局](screenshots/online-desktop.png)

[查看手机布局截图](screenshots/online-mobile.png)

源码提交 `8864afcc37a6d05fff5d2703f639ec4d39ec69b1` 的远端验证已完成：

- [Linux 网页 CI 38860175878](https://github.com/William206920/Splict-easy/actions/runs/38860175878) 通过：固定 MoonBit、20 组 JS 测试、重新编译后生成产物一致、Node 22 下 13 组网关/桥接测试与静态产物上传。
- [Windows 原生 CI 38860175899](https://github.com/William206920/Splict-easy/actions/runs/38860175899) 全部通过：原生构建、测试、GUI/CLI/模拟 AI 集成、安装包生成及安装验证。网页新增未破坏桌面交付。
- 本地代码与 GitHub `codex/vercel-online` 的 Git 树一致。开发变更见 [PR #3](https://github.com/William206920/Splict-easy/pull/3)。

生产部署尚未完成：Vercel 账号登录曾触发手机号尝试次数限制，需用户自行完成账号验证。2026-10-16 用户最终选择继续使用 Vercel；试验性的 Cloudflare 适配未发布，已撤回。不将这些本地测试或本地截图称为生产部署。

真实 DeepSeek Key 尚未配置，真实模型演示与真实额度存储仍待实际验证。不能用模拟上游响应替代真实服务验收。用户应在 Vercel 项目的敏感环境变量中设置密钥，后续重新部署并用示例账单完成端到端核对。

Windows 原生 GUI/CLI 不受该网页入口影响，依旧直接使用用户配置的兼容 API；本次没有宣称桌面端已经自动接入共享站点。
