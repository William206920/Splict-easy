# 阶段 5：统一报告与应用状态

1. 完成：纯文本、Markdown、JSON 报表；Session 人员/消费编辑、原子校验与旧结果失效。
2. 文件：report.mbt、session.mbt、app_wbtest.mbt 与版本记录。
3. 完整源码在本阶段提交。
4. moon fmt；moon test --target native；moon test --target js。
5. 预期金额与顺序稳定，改名更新引用，非法操作不破坏状态。
6. 实际 Native/JS 各 14 组通过；含此前黄金和 400 组性质检查。
7. 原生界面、磁盘保存尚待阶段 6。
8. 无业务测试失败或黄金预期修改。
9. 界面和 CLI 共用报告；Session 验证成功才替换账单并清除旧报告。
10. 验收改名、引用删除阻断、失败原子性、特殊文本与无需转账提示。
11. feat(stage5): add reports and transactional application state。
12. 自动继续阶段 6。
