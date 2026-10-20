import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { extname } from 'node:path';

// GitHub Linguist counts bytes, not file counts or lines. All handwritten
// programming and markup source is counted, including compact CSS.
const languages = { '.mbt': 'MoonBit', '.mjs': 'JavaScript', '.js': 'JavaScript',
  '.c': 'C', '.h': 'C', '.html': 'HTML', '.ps1': 'PowerShell', '.py': 'Python',
  '.iss': 'Inno Setup', '.ts': 'TypeScript', '.tsx': 'TSX', '.rs': 'Rust',
  '.go': 'Go', '.sh': 'Shell', '.cpp': 'C++', '.cs': 'C#', '.rb': 'Ruby', '.css': 'CSS' };
const tracked = execFileSync('git', ['ls-files', '-z'], { encoding: 'utf8' }).split('\0').filter(Boolean);
const generatedAttribute = execFileSync('git', ['check-attr', 'linguist-generated', '--', 'web/generated/core.mjs'], { encoding: 'utf8' }).trim();
if (!generatedAttribute.endsWith(': true')) throw new Error('The MoonBit compiler output must be marked linguist-generated=true.');
const bytes = {};
let generatedBytes = 0, cssBytes = 0, inlineJsBytes = 0;
for (const path of tracked) {
  const extension = extname(path);
  if (!languages[extension] && extension !== '.css') continue;
  const source = readFileSync(path, 'utf8').replace(/\r\n/g, '\n');
  const size = Buffer.byteLength(source);
  if (path === 'web/generated/core.mjs') { generatedBytes += size; continue; }
  if (extension === '.css') cssBytes += size;
  const language = languages[extension];
  bytes[language] = (bytes[language] || 0) + size;
  if (extension === '.mbt') inlineJsBytes += Buffer.byteLength(source.split('\n').filter(line => /^\s*#\|/.test(line)).join('\n'));
}
const total = Object.values(bytes).reduce((sum, value) => sum + value, 0);
const percent = (bytes.MoonBit || 0) * 100 / total;
console.log(JSON.stringify({ scope: 'tracked source, normalized LF; repository-specific Linguist estimate',
  bytes, total, moonbitPercent: Number(percent.toFixed(3)), generatedBytes,
  cssBytes, inlineJsBytes, minimumExclusive: 65 }, null, 2));
if (!(percent > 65)) throw new Error(`MoonBit source share must exceed 65%; found ${percent.toFixed(3)}%.`);
