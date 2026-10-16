# 第三方来源与许可证

本项目自有 MoonBit/C/脚本/文档代码采用 MIT。

- MoonBit core 与 Native runtime：International Digital Economy Academy，Apache License 2.0。随包保留 third_party/MoonBit-Apache-2.0.txt 及 MoonBit-NOTICE.txt（包含 core 自身记录的参考来源和许可）。本项目不修改或重新发布 MoonBit 编译器。
- simdutf：MoonBit 工具链记录的可选 UTF 编解码组件，保守随包保留其 MIT 声明，见 third_party/simdutf-MIT.txt。未分发 tcc/Binaryen 等编译工具。
- Windows 系统 API：使用平台提供的 Win32/WinHTTP，不把 Windows 系统 DLL 当作项目代码分发。MSVC 静态运行库通过合法构建环境链接，依赖清单由 dumpbin 生成。
- Inno Setup：仅用于生成安装器，来源 https://github.com/jrsoftware/issrc 。不将编译器当作本项目代码发布；保留其许可说明。
- GitHub Actions checkout/upload-artifact：仅构建基础设施，不作为应用二进制运行组件。
- Vercel 在线版的 JavaScript 计算模块由本项目 MoonBit 源码及 MoonBit core 编译生成。网站 `/notices/` 随构建分发 MoonBit Apache 2.0、NOTICE 和本项目许可证；浏览器 UI 无外部字体/图片/CDN 依赖。

C 平台适配与 MoonBit 业务代码是本次编写；参考官方接口文档见完整方案与阶段报告。没有引入外部图标、字体、CDN 或大型 GUI 框架。第三方源码中的既有版权说明均保留；不将第三方组件一概宣称为 MIT。
