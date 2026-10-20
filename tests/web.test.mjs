import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { execute, model_response } from '../web/generated/core.mjs';
import { createHandler } from '../api/parse.mjs';
import { normalizeGenerated } from '../scripts/generated-js.mjs';

const empty = '{"schema_version":1,"people":[],"payments":[],"ambiguous":[]}';
const fixture = readFileSync('examples/ledger_mixed.json', 'utf8');
const run = (action, ledger = empty, data = {}) => JSON.parse(execute(action, ledger, JSON.stringify(data)));
const env = { MOONBIT_BASE_URL: 'https://api.deepseek.com', MOONBIT_API_KEY: 'test-secret-not-a-real-key', MOONBIT_MODEL: 'deepseek-flash', UPSTASH_REDIS_REST_URL: 'https://quota.invalid', UPSTASH_REDIS_REST_TOKEN: 'fake-quota-key' };
const request = (body = { consent: true, text: 'fixture bill' }, headers = {}) => new Request('https://spliteasy.invalid/api/parse', { method: 'POST', headers: { 'content-type': 'application/json', origin: 'https://spliteasy.invalid', 'x-vercel-forwarded-for': '192.0.2.1', ...headers }, body: JSON.stringify(body) });
const providerResponse = (content = fixture, finish_reason = 'stop') => new Response(JSON.stringify({ choices: [{ finish_reason, message: { content } }] }));
test('cross-platform generated number formatting preserves strings and comments', () => {
  assert.equal(normalizeGenerated('const a = [1e+012, 1e-009]; const s = "1e+012"; // 1e+012\r\n'), 'const a = [1e+12, 1e-9]; const s = "1e+012"; // 1e+012\n');
});
function network({ quota = 1, content = fixture, status = 200, finish = 'stop', outage = false } = {}) {
  const calls = [];
  return { calls, fetcher: async (url, options) => {
    calls.push({ url, options });
    if (url === 'https://quota.invalid') { if (outage) throw new Error('quota offline'); return new Response(JSON.stringify({ result: quota })); }
    if (status !== 200) return new Response('secret echoed by a broken upstream: test-secret-not-a-real-key', { status });
    return providerResponse(content, finish);
  } };
}

test('browser bridge retains the native mixed golden and deterministic transfers', () => {
  const result = run('view', fixture);
  assert.equal(result.ok, true); assert.equal(result.total, '275.00');
  // Same expected values as shared/settle_wbtest.mbt, independently fixed golden.
  assert.deepEqual(result.balances.map(b => b.balance), ['148.00', '20.00', '-58.00', '-54.00', '-56.00']);
  assert.equal(result.transfers[0].from, '小刚'); assert.equal(result.transfers[0].amount, '58.00');
  assert.ok(result.markdown.includes('总消费：275.00'));
});
test('bridge member operations update references and reject linked deletion atomically', () => {
  let current = run('view', fixture);
  const old = current.ledger;
  assert.equal(run('remove_person', old, { name: '小明' }).ok, false);
  current = run('rename', old, { old: '小明', name: '阿明' });
  assert.equal(current.ok, true); assert.ok(!current.ledger.includes('小明'));
  assert.equal(run('view', old).people[0], '小明');
  current = run('add_person', current.ledger, { name: '新成员' });
  assert.equal(run('remove_person', current.ledger, { name: '新成员' }).ok, true);
});
test('form money stays decimal strings until MoonBit Int64 conversion; tail remainder is stable', () => {
  let current = run('import', empty, { text: '人：甲 乙 丙' });
  current = run('put_payment', current.ledger, { index: '-1', payer: '甲', amount: '0.29', description: '尾差', date: '', mode: 'equal', participants: ['甲', '乙', '丙'], amounts: [] });
  assert.equal(current.total, '0.29'); assert.deepEqual(current.balances.map(b => b.due), ['0.09', '0.10', '0.10']);
  const invalid = run('put_payment', current.ledger, { index: '-1', payer: '甲', amount: '0.291', description: '无效', date: '', mode: 'equal', participants: ['甲'], amounts: [] });
  assert.equal(invalid.ok, false);
});
test('Int64 amounts above JS Number precision round-trip through opaque ledger strings', () => {
  const source = '{"schema_version":1,"people":["甲"],"payments":[{"payer":"甲","amount_cents":9007199254740993,"split_mode":"equal","participants":["甲"],"shares":[],"description":"精度","date":""}],"ambiguous":[]}';
  const result = run('view', source);
  assert.equal(result.total, '90071992547409.93'); assert.ok(result.ledger.includes('9007199254740993'));
  assert.equal(run('view', result.ledger).total, result.total);
});
test('reject wrapped indexes, invalid imports, ambiguous AI, inconsistent shares', () => {
  assert.equal(run('remove_payment', fixture, { index: '4294967296' }).ok, false);
  assert.equal(run('import', fixture, { text: '{bad' }).ok, false);
  const ambiguous = JSON.parse(fixture); ambiguous.ambiguous = ['缺付款人'];
  assert.equal(JSON.parse(model_response(JSON.stringify({ choices: [{ message: { content: JSON.stringify(ambiguous) } }] }))).ok, false);
  const ledger = run('import', empty, { text: '人：甲 乙' }).ledger;
  assert.equal(run('put_payment', ledger, { index: '-1', payer: '甲', amount: '30', description: '茶', date: '', mode: 'exact', participants: ['甲', '乙'], amounts: ['10', '10'] }).ok, false);
});
test('status does not expose credentials; missing configuration fails closed', async () => {
  const n = network(); const handler = createHandler({}, n.fetcher);
  const status = await handler(new Request('https://spliteasy.invalid/api/parse'));
  assert.equal((await status.json()).enabled, false);
  assert.equal((await handler(request())).status, 503); assert.equal(n.calls.length, 0);
  const publicStatus = await createHandler(env, n.fetcher)(new Request('https://spliteasy.invalid/api/parse'));
  const body = await publicStatus.text(); assert.ok(!body.includes(env.MOONBIT_API_KEY)); assert.equal(JSON.parse(body).invitationRequired, false);
});
test('Vercel Marketplace KV aliases configure persistent quotas', async () => {
  const aliases = { ...env, UPSTASH_REDIS_REST_URL: undefined, UPSTASH_REDIS_REST_TOKEN: undefined, KV_REST_API_URL: 'https://quota.invalid', KV_REST_API_TOKEN: 'fake-quota-key' };
  const n = network(); assert.equal((await createHandler(aliases, n.fetcher)(request())).status, 200);
});
test('public AI uses server key/fixed model only and returns validated preview, not settlement', async () => {
  const n = network(); const result = await createHandler(env, n.fetcher)(request({ consent: true, text: '三个人聚餐', key: 'attacker', model: 'attacker', base_url: 'https://evil.invalid' }));
  assert.equal(result.status, 200); const data = await result.json(); assert.equal(data.ok, true); assert.ok(data.preview.includes('确认后')); assert.equal(data.transfers, undefined);
  assert.equal(n.calls.length, 2); const upstream = n.calls[1]; assert.equal(upstream.url, 'https://api.deepseek.com/chat/completions');
  assert.equal(upstream.options.headers.authorization, `Bearer ${env.MOONBIT_API_KEY}`);
  const sent = JSON.parse(upstream.options.body); assert.equal(sent.model, 'deepseek-flash'); assert.equal(sent.max_tokens, 4096); assert.equal(sent.thinking.type, 'disabled'); assert.equal(sent.response_format.type, 'json_object');
  assert.equal(upstream.options.redirect, 'error'); assert.ok(!JSON.stringify(data).includes(env.MOONBIT_API_KEY));
});
test('unconfirmed, oversized, cross-origin and wrong-method requests do not reach quota or model', async () => {
  const n = network(); const handler = createHandler(env, n.fetcher);
  for (const req of [request({ text: 'missing consent' }), request({ consent: true, text: 'x'.repeat(8001) }), request(undefined, { origin: 'https://evil.invalid' })]) assert.ok((await handler(req)).status >= 400);
  assert.equal((await handler(new Request('https://spliteasy.invalid/api/parse', { method: 'PUT' }))).status, 405); assert.equal(n.calls.length, 0);
});
test('Kimi uses its configured regional endpoint and non-thinking JSON parameters', async () => {
  for (const host of ['api.moonshot.cn', 'api.moonshot.ai']) {
    const n = network();
    const response = await createHandler({ ...env, MOONBIT_BASE_URL: `https://${host}/v1`, MOONBIT_MODEL: 'kimi-k2.6' }, n.fetcher)(request());
    assert.equal(response.status, 200);
    const upstream = n.calls[1]; assert.equal(upstream.url, `https://${host}/v1/chat/completions`);
    const body = JSON.parse(upstream.options.body);
    assert.equal(body.model, 'kimi-k2.6'); assert.equal(body.temperature, 0.6);
    assert.equal(body.thinking.type, 'disabled'); assert.equal(body.response_format.type, 'json_object');
    assert.equal(upstream.options.headers.authorization, `Bearer ${env.MOONBIT_API_KEY}`);
    const result = await response.json(); assert.equal(result.ok, true); assert.ok(result.preview.includes('确认后'));
  }
});
test('daily/hourly quota denial and quota outage never call the paid model', async () => {
  for (const options of [{ quota: 0 }, { outage: true }]) {
    const n = network(options); const result = await createHandler(env, n.fetcher)(request()); assert.ok([429, 503].includes(result.status)); assert.equal(n.calls.length, 1);
  }
  const n = network(); await createHandler(env, n.fetcher)(request());
  const script = JSON.parse(n.calls[0].options.body); assert.equal(script[0], 'EVAL'); assert.equal(script[2], '2'); assert.deepEqual(script.slice(-2), ['10', '100']);
  assert.ok(!JSON.stringify(script).includes('192.0.2.1'));
});
test('optional invite mode rejects invalid codes before paid work', async () => {
  const n = network(); const handler = createHandler({ ...env, SPLITEASY_ACCESS_MODE: 'invite', SPLITEASY_ACCESS_CODE: 'demo-invite-code-123456' }, n.fetcher);
  assert.equal((await handler(request())).status, 401); assert.equal(n.calls.length, 0);
  assert.equal((await handler(request(undefined, { authorization: 'Bearer demo-invite-code-123456' }))).status, 200);
});

test('Pages CORS status, preflight and parsing use the existing gateway and quotas', async () => {
  const n = network(); const handler = createHandler(env, n.fetcher);
  const headers = { origin: 'https://william206920.github.io', 'sec-fetch-site': 'cross-site' };
  const status = await handler(new Request('https://spliteasy.invalid/api/parse', { headers }));
  assert.equal((await status.json()).enabled, true);
  assert.equal(status.headers.get('access-control-allow-origin'), headers.origin);
  const preflight = await handler(new Request('https://spliteasy.invalid/api/parse', { method: 'OPTIONS', headers: { ...headers, 'access-control-request-method': 'POST', 'access-control-request-headers': 'content-type,authorization' } }));
  assert.equal(preflight.status, 204); assert.equal(n.calls.length, 0);
  assert.equal(preflight.headers.get('access-control-allow-headers'), 'content-type, authorization');
  const result = await handler(request(undefined, headers));
  assert.equal(result.status, 200); assert.equal(n.calls.length, 2);
  assert.equal(result.headers.get('access-control-allow-origin'), headers.origin);
  assert.equal(result.headers.get('access-control-allow-credentials'), null);
  const denied = await handler(request(undefined, { ...headers, origin: 'https://william206920.github.io.evil.invalid' }));
  assert.equal(denied.status, 403); assert.equal(n.calls.length, 2);
  assert.equal(denied.headers.get('access-control-allow-origin'), null);
  const unavailable = await createHandler(env, network({ outage: true }).fetcher)(request(undefined, headers));
  assert.equal(unavailable.status, 503); assert.equal(unavailable.headers.get('access-control-allow-origin'), headers.origin);
});
test('provider failures are sanitized; truncated or ambiguous outputs cannot be applied', async () => {
  const n = network({ status: 401 }); const error = await createHandler(env, n.fetcher)(request()); assert.equal(error.status, 502); assert.ok(!(await error.text()).includes(env.MOONBIT_API_KEY));
  const truncated = network({ finish: 'length' }); assert.equal((await createHandler(env, truncated.fetcher)(request())).status, 422);
  const ambiguous = JSON.parse(fixture); ambiguous.ambiguous = ['缺少参与人']; const a = network({ content: JSON.stringify(ambiguous) }); assert.equal((await createHandler(env, a.fetcher)(request())).status, 422);
});
