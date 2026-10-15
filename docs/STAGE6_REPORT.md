# 阶段 6：完整 Windows 界面与本地文件

1. 完成原生人员/消费增删改、平均/实际表单切换、预览差额、结算、复制、示例、文本/JSON 导入、报表导出、本地文件与草稿恢复。
2. 文件 app/、Win32 控件和系统 IO 桥接、cmd 入口与集成检查。
3. 完整源码在本阶段 Git 提交。
4. 本地 moon fmt / test --target native / test --target js / build --target native --release；Windows scripts/build-windows.ps1 -Smoke。
5. 预期 Windows 原生流程与文件集成通过，Linux 不模拟 GUI。
6. 实际本地 Native 15 组、JS 14 组通过；Linux release 编译通过。Windows CI 随提交触发，实际结果另行归档。
7. 未验证用户桌面 DPI、输入法、视觉显示、文件对话框人工操作。
8. 补齐损坏/无效 UTF-8 草稿保护，避免自动覆盖；修复公开类型边界。未更改黄金预期。
9. C 只提供控件、Unicode、剪贴板和磁盘 IO，MoonBit 驱动全部账单与状态；文件先写临时并同步后替换。
10. 自动检查增加真实控件下人员、两种消费、混合结算、改名、引用阻断、编辑删除、导入和剪贴板；磁盘测试覆盖 UTF-8 和失败保留旧文件。
11. feat(stage6): build native desktop workflow and local persistence。
12. 自动继续阶段 7。
