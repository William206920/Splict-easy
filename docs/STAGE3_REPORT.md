# 阶段 3：混合分账与转账

1. 完成：名单顺序尾差、实际份额、混合净额和确定性贪心。
2. 文件：shared/settle.mbt、settle_wbtest.mbt、版本记录。
3. 完整源码保存在本阶段 Git 提交中。
4. 命令：moon fmt；moon test --target native；moon test --target js。
5. 预期：黄金 A/B 金额和转账顺序一致，余额守恒并可回放归零。
6. 实际：Native/JS 各 8 组通过，含 400 组生成账单与 Int64 上限。
7. 未验证：完整桌面操作尚未实现。
8. 无失败业务测试，无黄金预期修改。
9. 先汇总已付和应承担，再逐轮选最大债权/债务；同额取名单前者。
10. 验收：付款人不参与、1 分三人、参与数组乱序、黄金 A/B 与回放已测试。
11. 提交：feat(stage3): implement deterministic mixed settlement。
12. 自动继续阶段 4。
