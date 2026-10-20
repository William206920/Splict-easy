# GitHub Pages 在线入口

访问 **https://william206920.github.io/Splict-easy/**，无需下载或安装。Windows 发行包与 Vercel 在线入口继续保留。

## 部署结构

参考 [Traveling 的 Pages 工作流](https://github.com/Kleinrat/Traveling/blob/main/.github/workflows/pages.yml) 与 [GitHub 官方部署说明](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)：GitHub Actions 编译 MoonBit、执行检查，再将 `.web-dist` 上传并部署到 Pages。只部署公开网页、编译后的 MoonBit 核心与许可证，不发布仓库根目录。

GitHub Pages 提供静态网页；共享 AI 请求由 `https://spliteasy-online.vercel.app/api/parse` 处理。Kimi Key、Redis 令牌均保留在 Vercel 私有环境变量中。前端只配置公开的网关地址，服务端仅允许本站 Pages 来源跨域访问，不使用通配来源，不发送浏览器 Cookie。

普通记账与结算在浏览器内完成；AI 继续使用外发同意、MoonBit 校验、歧义阻断、确认预览和原子额度限制。Pages 与 Vercel 共用额度。两者域名不同，浏览器本地草稿互不共享；迁移账单请先导出 JSON，再在另一入口导入。

## 自动更新与本地构建

仓库 Settings → Pages → Source 选择 **GitHub Actions**。`.github/workflows/web.yml` 对 PR 执行检查，合并到 main 后自动部署，部署任务仅授予 `pages: write` 与 `id-token: write`，不授予仓库内容写权限。

```sh
moon check --target js
moon test --target js
node scripts/build-web.mjs --compile
node --test tests/web.test.mjs
node scripts/build-web.mjs --pages
```

使用固定的 `toolchain.version`。`--pages` 将公开 AI 网关地址写入构建后的 HTML；原始网页和 Vercel 构建继续使用同源接口。所有静态资源使用相对路径，兼容 `/Splict-easy/` 子路径和哈希导航。Actions 会重新编译并核对已提交的编译产物，防止源码与部署版本不一致。

新增回归覆盖托管地址选择、可信来源与仿冒来源、预检方法及请求头、跨域错误响应、额度故障与同源兼容。公网浏览器实际验收和 CI 结果应单独记录。
