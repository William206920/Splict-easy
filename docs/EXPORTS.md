# 结算单与 Excel 导出

默认导出自包含 HTML，适合朋友核对、离线查看和打印；页面调用浏览器打印，可在对话框中选择另存 PDF。本版本没有直接 PDF 编码器。导出 HTML 不是桌面程序的界面，Windows 应用仍为 MoonBit / Win32 原生。

可选 Excel .xlsx 恰好两张表：成员转账明细（姓名、转账给谁、金额、说明）和消费明细（日期、名称、付款人、金额、分摊方式、每人承担）。每行一笔建议转账，同一人转给多人时列多行；无需转出的成员列 0 元并说明。顶部总消费和待转账合计独立展示。表头冻结、筛选、金额格式及自动换行便于编辑核对。

CSV 是单张扁平数据表，以记录类型区分转账/消费，适合其他工具导入；不是 Excel 的两张工作表。文字加引号并处理公式前缀，UTF-8 BOM 帮助识别中文。超大金额以文本前缀保留。JSON 账单备份仍用于恢复，报表 JSON 仅为结算报告，导出快照不会自动同步后续改动。

每次导出从当前 Ledger 重新验证并结算，不读取旧缓存报告、不更改账本。所有金额通过 Int64 整数分生成十进制字符串，不经过 JS Number。XLSX 数值超过 15 位有效数字时改为文本，保留原金额；不得以浮点重算替代 MoonBit 的分摊。转账是建议，不表示付款完成。无 API Key、外部资源或账单上传。

Excel 采用 OOXML 与 ZIP Store，由 MoonBit 编码；引用格式说明：[Microsoft SpreadsheetML 结构](https://learn.microsoft.com/en-us/office/open-xml/spreadsheet/structure-of-a-spreadsheetml-document)、[Excel 数字精度](https://support.microsoft.com/en-us/excel/keeping-leading-zeros-and-large-numbers)。普通金额单元格可参与 Excel 计算；超大金额文本需保留原值。XML 控制字符或超过 32767 字符的单元格明确拒绝，用户可缩短内容或改用结算单/CSV。

验证包含两表结构、全部成员、独立转账金额、消费与份额、ZIP CRC/XML、最大 Int64、用户文本转义和公式注入防护。JS 和 Native 目标生成文件，由 Python 标准库独立读取核对；本地还用 openpyxl 只读加载校验。尚未在用户 Excel/WPS 中完成手动打开与打印验收，浏览器打印为 PDF 需要用户在打印窗口选择目标。

## 部署与验收记录

- PR #9 已合并，0.9.3 标签源码为 `276f990f380b6ecb3e5b3870542c317449719e9c`。
- Windows PR CI `39410822398` 通过 40 项 Native 测试、原生 HTML/XLSX/CSV 文件生成和独立解析、桌面与 CLI、模拟 HTTP AI、安装卸载及截图检查。
- 网页 PR CI `39410822565` 通过 65 项 MoonBit JS、17 项 Node 和独立 Python 文件解析。main 网页与 Pages 部署 `39411091137` 成功。
- Pages 与 Vercel 的公开 core.mjs SHA256 均为 `ef48daa7445e4770ddc499cc4c08eaa2cc1b8b3d817de9022de0782cb7d5762a`，与本地编译一致；公网浏览器可见默认结算单和其他格式入口。
- 本地浏览器查看了 HTML 的两部分排版；使用表格工具读取并渲染 Excel 两张表。浏览器自动化等待 Blob 下载事件时连接超时，不将此尝试计作完整浏览器下载链路通过。MoonBit 导出的实际文件与原生落盘路径已独立验证。
- GitHub 实际 MoonBit 239230 / 354670 字节，约 67.4514%，严格高于 65%。
