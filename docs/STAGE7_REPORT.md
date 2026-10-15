# 阶段 7：Native CLI 与 Windows 打包

1. 完成 check/split、文本/JSON、--json、-o、标准流和退出码；Windows 便携 ZIP、Inno 安装器、校验和与安装测试脚本。
2. 文件 cli/core、cmd/cli、console IO、packaging、构建和验证脚本及固定 Markdown 黄金。
3. 完整源码保存在本阶段提交。
4. moon test --target native/js；moon build --target native --release；python3 scripts/verify_cli.py <cli>；Windows build/package/verify-installer.ps1。
5. 预期全部通过，CLI 非 AI 不读取模型配置或联网，安装卸载保留用户数据。
6. Linux 实际 Native 16 组、JS 15 组通过；独立进程检查 JSON/Markdown 完整黄金、UTF-8、Int64 上限、错误 stderr 和非零退出码均通过。Windows 打包由本次 CI 执行，后续记录实际结果。
7. 用户桌面安装和未签名提示未实测；AI 尚待阶段 8。
8. 独立 Markdown 黄金检查促成明细表与份额段落分离，避免破坏表格结构；没有修改业务黄金。
9. GUI 与 CLI 从同一 shared 结算；安装器按当前用户安装，程序本地计算，正式账单不放在安装目录。
10. 新增安装、重复安装、已安装 CLI 运行、卸载和用户数据保留自动检查；MSVC 静态运行库选项与依赖清单。
11. feat(stage7): add native CLI and Windows installer packaging。
12. 自动继续阶段 8。

## Windows 实际结果补录

[运行 38723034006](https://github.com/William206920/Splict-easy/actions/runs/38723034006) 已通过。原生 GUI/CLI 构建、独立 CLI 黄金、便携包、Inno 安装器、安装/重复安装/卸载和用户数据保留自动检查全部成功。
