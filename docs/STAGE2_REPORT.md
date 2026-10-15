# 阶段 2：数据模型与金额

1. 完成：Int64 分解析、无浮点格式化、人员/模式/份额/日期/歧义/溢出校验。
2. 文件：shared/money.mbt、ledger.mbt、model_wbtest.mbt、包配置、Windows 测试入口及自动推进约定。
3. 完整源码：本阶段 Git 提交保留全部文件，不继承旧实现测试结论。
4. 命令：moon fmt；moon test --target native；moon test --target js；moon build --target native --release。
5. 预期：检查构建退出 0，测试全通过。
6. 实际：Linux Native 4 组、JS 4 组均通过；每组含多个边界断言；Native release 构建成功。Windows CI 由提交自动触发，另行检查。
7. 未验证：用户桌面操作；新分摊算法尚未实现。
8. 修复：新版 try? 优先级与弃用语法改为显式错误捕获；Debug/Eq 显式扩展。未修改正确业务预期。
9. 解释：元字符串按数字精确转换成整数分，相加前检查上限；零份额合法，消费总额必须正数。
10. 验收：最大金额、0.29、精度、非法输入、模式互斥、份额合计、总额溢出、日期闰年均已断言。
11. 提交：feat(stage2): add precise money and ledger validation。
12. 后续：按用户最新授权自动进入阶段 3，不再阶段间询问。
