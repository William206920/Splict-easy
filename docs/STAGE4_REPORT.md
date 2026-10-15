# 阶段 4：文本与 JSON 输入

1. 完成默认全员/@/!/=/中文原始行号、BOM/CRLF、严格无损账单 JSON。
2. 新增 shared/inputs.mbt、raw_json.mbt 和输入测试，更新包导入。
3. 完整源码见本阶段提交。
4. moon fmt；moon test --target native；moon test --target js。
5. 预期黄金文本等价结构输入，大整数 JSON 无损。
6. 实际 Native/JS 各 12 组测试通过。
7. GUI 导入与 CLI IO 留到后续阶段。
8. 测试发现标准 JSON 数字的浮点路径不适合金额，改为独立的原始整数词法解析；仅字符串转义复用标准库。保留失败用例，另修复新版 replace 标签和错误匹配。
9. 金额读取不经过 Double，拒绝小数分、指数、重复键、超深嵌套和溢出。账单 schema_version=1。
10. 已验收两个黄金文本、原行号、混用拒绝、Int64 上限往返及非法 JSON。
11. feat(stage4): parse ledger text and lossless integer JSON。
12. 自动继续阶段 5。
