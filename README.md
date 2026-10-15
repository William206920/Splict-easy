# SplitEasy · AA 分账器

MoonBit 黑客松项目，产品规范 V3.1。当前仅交付阶段 1 工程骨架，尚未实现记账和分账。
内部交付截止：2026-10-24 23:59（Asia/Shanghai）。

## 环境

使用 MoonBit 官方默认 stable 工具链，不固定未经验证的旧版本。
Linux/macOS 安装：

```bash
curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash
export PATH="$HOME/.moon/bin:$PATH"
```

Windows 用户建议通过 VS Code 的 MoonBit 扩展安装工具链。
本项目 Makefile 和 build.sh 需要 Bash/Make；Windows 可使用 WSL。
Native 需要可用 C 编译器，JS 测试需要 Node.js。

## 阶段 1 命令

在项目根目录逐条运行：

```bash
moon version
moon --help
moon build --help
moon test --help
moon check --help
make check
make test
make build-native
make run-cli
make build-web
python3 -m http.server 8000 --directory web
```

最后一条命令启动本地服务器；打开 http://localhost:8000。
Native 输出和网页状态应为 `SplitEasy: MoonBit shared core ready.`。
这只表示共享包可用，不代表分账功能完成。

## 结构

- shared：纯 MoonBit 共享包，当前只有启动信息和冒烟测试。
- cli/core：Native 适配包，当前转发共享启动信息。
- cli/main：Native 可执行入口。
- web：JS 可执行入口、DOM FFI、HTML 和构建脚本。
- fixtures、examples、.github/workflows：保留后续阶段目录。
- docs：实际验证日志及阶段交付记录。

只创建本阶段所需文件；金额模型、分账、文本解析、AI、CI、部署均在后续阶段完成。
`web/spliteasy.js` 是编译产物，不手写、不提交 Git；运行 `make build-web` 重新生成。
仓库地址、在线演示、手机体验、赛事要求均待验证，不提供虚构链接。

## 隐私

当前程序只显示固定启动信息，不收集或上传账单，不使用外部 CDN。

## 官方参考

- https://www.moonbitlang.com/download/
- https://docs.moonbitlang.com/en/stable/toolchain/moon/module.html
- https://docs.moonbitlang.com/en/stable/toolchain/moon/package.html
- https://docs.moonbitlang.com/en/stable/tutorial/cli-quickstart.html
- https://docs.moonbitlang.com/en/stable/language/ffi.html

## 许可证

MIT，见 LICENSE。
