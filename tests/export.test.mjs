import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, mkdirSync, writeFileSync } from 'node:fs';
import { export_document } from '../web/generated/core.mjs';

const root = 'dist/export-fixtures/web';
const fixture = readFileSync('examples/ledger_mixed.json', 'utf8');
mkdirSync(root, { recursive: true });
test('MoonBit export bridge produces two-table documents without mutating the source', () => {
  for (const format of ['xlsx', 'html', 'csv']) {
    const result = JSON.parse(export_document(fixture, format));
    assert.equal(result.ok, true);
    const bytes = result.encoding === 'base64' ? Buffer.from(result.data, 'base64') : Buffer.from(result.data);
    writeFileSync(`${root}/mixed.${format}`, bytes);
    if (format === 'xlsx') assert.equal(bytes.subarray(0, 4).toString('hex'), '504b0304');
    if (format === 'html') {
      assert.equal((result.data.match(/<table>/g) || []).length, 2);
      assert.match(result.data, /待转账合计 168.00/);
      assert.match(result.data, /小刚/);
      assert.match(result.data, /小美：14.00 元/);
      assert.doesNotMatch(result.data, /<script|https?:\/\//);
    }
  }
  assert.equal(JSON.parse(export_document(fixture, 'pdf')).ok, false);
  assert.equal(readFileSync('examples/ledger_mixed.json', 'utf8'), fixture);
});

test('maximal integer cents remain exact and formula-like user input stays literal', () => {
  const source = JSON.parse(fixture);
  source.payments = [source.payments[0]];
  source.payments[0].participants = ['小红'];
  source.payments[0].description = '=HYPERLINK("https://bad.invalid","click") & <script>evil</script>';
  // Keep the raw integer lexeme opaque: never route monetary cents through Number.
  const raw = JSON.stringify(source).replace('20000', '9223372036854775807');
  for (const format of ['xlsx', 'html', 'csv']) {
    const result = JSON.parse(export_document(raw, format));
    assert.equal(result.ok, true);
    writeFileSync(`${root}/maximum.${format}`, result.encoding === 'base64' ? Buffer.from(result.data, 'base64') : result.data);
    if (format === 'html') {
      assert.match(result.data, /92233720368547758.07/);
      assert.match(result.data, /&lt;script&gt;/);
      assert.doesNotMatch(result.data, /<script>/);
    }
    if (format === 'csv') assert.match(result.data, /"'=HYPERLINK/);
  }
  const ambiguous = JSON.stringify({ ...source, ambiguous: ['付款人不明确'] });
  assert.equal(JSON.parse(export_document(ambiguous, 'xlsx')).ok, false);
});
