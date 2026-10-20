"""Independent ZIP/XML/CSV validation of actual MoonBit-generated export files."""
import csv
import pathlib
import sys
import zipfile
import xml.etree.ElementTree as ET

root = pathlib.Path(sys.argv[1])
ns = {'s': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}

def cell_value(cell):
    if cell.attrib.get('t') == 'inlineStr':
        return ''.join(cell.itertext())
    return cell.findtext('s:v', '', ns)

def workbook(name):
    with zipfile.ZipFile(root / name) as z:
        assert z.testzip() is None
        for path in z.namelist():
            ET.fromstring(z.read(path))
        book = ET.fromstring(z.read('xl/workbook.xml'))
        assert [s.attrib['name'] for s in book.find('s:sheets', ns)] == ['成员转账明细', '消费明细']
        sheets = [ET.fromstring(z.read(f'xl/worksheets/sheet{i}.xml')) for i in [1, 2]]
        for sheet in sheets:
            assert sheet.find('.//s:pane', ns).attrib['ySplit'] == '5'
            assert sheet.find('s:autoFilter', ns) is not None
            assert not sheet.findall('.//s:f', ns), 'Untrusted data must not become formulas'
        return [[{c.attrib['r']: cell_value(c) for c in row} for row in sheet.findall('s:sheetData/s:row', ns)] for sheet in sheets], sheets

rows, sheets = workbook('mixed.xlsx')
transfers = rows[0][4:]
assert len(transfers) == 6
assert sum(round(float(row.get('C' + str(i + 6), '0')) * 100) for i, row in enumerate(transfers)) == 16800
assert rows[1][4]['D6'] == '200.00'
assert rows[1][5]['D7'] == '75.00'
assert '小美：14.00 元' in rows[1][5]['F7']
assert set(r.get('A' + str(i + 6)) for i, r in enumerate(transfers)) == {'小明', '小红', '小刚', '小美', '小李'}
max_rows, max_sheets = workbook('maximum.xlsx')
amount = max_sheets[1].find('.//s:c[@r="D6"]', ns)
assert amount.attrib['t'] == 'inlineStr'
assert cell_value(amount) == '92233720368547758.07'
html = (root / 'mixed.html').read_text(encoding='utf-8')
assert html.count('<table>') == 2 and '待转账合计 168.00' in html
csv_rows = list(csv.reader((root / 'mixed.csv').open(encoding='utf-8-sig', newline='')))
assert len(csv_rows) == 9 and all(len(row) == 9 for row in csv_rows)
assert sum(row[0] == '消费' for row in csv_rows[1:]) == 2
maximum_csv = list(csv.reader((root / 'maximum.csv').open(encoding='utf-8-sig', newline='')))
assert any(row[3] == "'92233720368547758.07" for row in maximum_csv[1:])
print('PASS: two-sheet XLSX ZIP/CRC/XML, transfers, amounts, shares, exact Int64, literal text, HTML and CSV')
