import { cpSync, mkdirSync, readFileSync, writeFileSync, readdirSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { spawnSync } from 'node:child_process';
import { normalizeGenerated } from './generated-js.mjs';

const sources = ['shared', 'ai', 'web/bridge'].flatMap(dir => readdirSync(dir).filter(f => f.endsWith('.mbt') && !f.endsWith('test.mbt') || f === 'moon.pkg').sort().map(f => `${dir}/${f}`));
sources.push('moon.mod', 'toolchain.version', 'scripts/build-web.mjs', 'scripts/generated-js.mjs');
const hash = createHash('sha256');
for (const file of sources) hash.update(file).update(readFileSync(file, 'utf8').replace(/\r\n/g, '\n'));
const fingerprint = hash.digest('hex');
mkdirSync('web/generated', { recursive: true });
if (process.argv.includes('--compile')) {
  const result = spawnSync(process.platform === 'win32' ? 'moon.exe' : 'moon', ['build', 'web/bridge', '--target', 'js', '--release'], { stdio: 'inherit' });
  if (result.status !== 0) process.exit(result.status || 1);
  writeFileSync('web/generated/core.mjs', normalizeGenerated(readFileSync('_build/js/release/build/web/bridge/bridge.js', 'utf8')));
  writeFileSync('web/generated/source.sha256', `${fingerprint}\n`);
}
if (readFileSync('web/generated/source.sha256', 'utf8').trim() !== fingerprint) throw new Error('MoonBit sources changed: run node scripts/build-web.mjs --compile with the pinned MoonBit toolchain.');
mkdirSync('.web-dist', { recursive: true });
cpSync('web/public', '.web-dist', { recursive: true });
cpSync('web/generated/core.mjs', '.web-dist/core.mjs');
if (process.argv.includes('--pages')) {
  const { hosting_config } = await import('../web/generated/core.mjs');
  const { api } = JSON.parse(hosting_config(true));
  const index = readFileSync('.web-dist/index.html', 'utf8').replace('content="/api/parse"', `content="${api}"`);
  writeFileSync('.web-dist/index.html', index);
  writeFileSync('.web-dist/.nojekyll', '');
}
mkdirSync('.web-dist/notices', { recursive: true });
for (const file of ['MoonBit-Apache-2.0.txt', 'MoonBit-NOTICE.txt']) cpSync(`third_party/${file}`, `.web-dist/notices/${file}`);
cpSync('LICENSE', '.web-dist/notices/LICENSE.txt');
cpSync('NOTICE.md', '.web-dist/notices/NOTICE.txt');
console.log('Built SplitEasy Online with the verified MoonBit core.');
