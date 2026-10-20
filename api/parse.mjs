import { createHash, timingSafeEqual } from 'node:crypto';
import { gateway_config, gateway_input, gateway_request, gateway_response } from '../web/generated/core.mjs';

const json = (data, status = 200, extra = {}) => new Response(JSON.stringify(data), { status, headers: { 'content-type': 'application/json; charset=utf-8', 'cache-control': 'no-store', ...extra } });
const digest = value => createHash('sha256').update(value).digest();
const allowed = (supplied, expected) => timingSafeEqual(digest(supplied), digest(expected));

function config(env) {
  const keys = ['MOONBIT_BASE_URL', 'MOONBIT_API_KEY', 'MOONBIT_MODEL', 'UPSTASH_REDIS_REST_URL', 'UPSTASH_REDIS_REST_TOKEN', 'KV_REST_API_URL', 'KV_REST_API_TOKEN', 'SPLITEASY_ACCESS_MODE', 'SPLITEASY_ACCESS_CODE', 'SPLITEASY_HOURLY_LIMIT', 'SPLITEASY_DAILY_LIMIT'];
  const c = JSON.parse(gateway_config(JSON.stringify(Object.fromEntries(keys.map(key => [key, env[key]])))));
  if (!c.enabled) return null;
  return { ...c, scope: createHash('sha256').update(env.SPLITEASY_QUOTA_NAMESPACE || c.key).digest('hex').slice(0, 24) };
}

// One atomic Redis script enforces per-IP/hour and deployment-wide/day quotas.
// Failed/ambiguous provider requests still consume quota, because they may cost money.
const quotaScript = `local a=tonumber(redis.call('GET',KEYS[1]) or '0'); local b=tonumber(redis.call('GET',KEYS[2]) or '0'); if a>=tonumber(ARGV[1]) or b>=tonumber(ARGV[2]) then return 0 end; redis.call('INCR',KEYS[1]); redis.call('EXPIRE',KEYS[1],7200); redis.call('INCR',KEYS[2]); redis.call('EXPIRE',KEYS[2],172800); return 1`;

async function takeQuota(c, request, fetcher) {
  const now = Date.now();
  const ip = request.headers.get('x-vercel-forwarded-for') || request.headers.get('x-forwarded-for') || 'unknown';
  const identity = createHash('sha256').update(c.scope).update(ip.split(',')[0].trim()).digest('hex');
  const scope = c.scope;
  const response = await fetcher(c.redis, { method: 'POST', headers: { authorization: `Bearer ${c.redisToken}`, 'content-type': 'application/json' }, body: JSON.stringify(['EVAL', quotaScript, '2', `spliteasy:${scope}:hour:${Math.floor(now/3600000)}:${identity}`, `spliteasy:${scope}:day:${Math.floor(now/86400000)}`, String(c.hourly), String(c.daily)]), signal: AbortSignal.timeout(5000), redirect: 'error' });
  if (!response.ok) throw new Error('quota unavailable');
  const value = await response.json();
  if (value.error || value.result !== 0 && value.result !== 1) throw new Error('invalid quota response');
  return value.result === 1;
}

async function readLimited(request, max) {
  if (Number(request.headers.get('content-length')) > max) throw new Error('too large');
  const reader = request.body?.getReader();
  if (!reader) return '';
  let bytes = 0; const chunks = [];
  try {
    while (true) {
      const { value, done } = await reader.read(); if (done) break;
      bytes += value.byteLength;
      if (bytes > max) { await reader.cancel(); throw new Error('too large'); }
      chunks.push(value);
    }
  } finally { reader.releaseLock(); }
  return Buffer.concat(chunks).toString('utf8');
}

export function createHandler(env = process.env, fetcher = fetch) {
  return async function handler(request) {
    const c = config(env);
    if (request.method === 'GET') return json({ enabled: !!c, model: c ? c.model : null, provider: c ? new URL(c.endpoint).hostname : null, invitationRequired: c?.invite || false, maxCharacters: 8000 });
    if (request.method !== 'POST') return json({ error: '只支持 POST 请求' }, 405, { allow: 'GET, POST' });
    if (!c) return json({ error: '共享 AI 尚未配置完成；普通记账与结算可以正常使用。' }, 503);
    const origin = request.headers.get('origin');
    const expectedOrigin = new URL(request.url).origin;
    if (origin && origin !== expectedOrigin || request.headers.get('sec-fetch-site') === 'cross-site') return json({ error: '请求来源无效' }, 403);
    if (c.invite && !allowed(request.headers.get('authorization') || '', `Bearer ${c.code}`)) return json({ error: '邀请码不正确或已失效' }, 401);
    if (!request.headers.get('content-type')?.startsWith('application/json')) return json({ error: '请求格式无效' }, 415);
    let input;
    try { input = JSON.parse(gateway_input(await readLimited(request, 40000))); } catch { return json({ error: '请求无效或内容过长' }, 400); }
    if (!input.ok) return json({ error: input.error }, 400);
    try {
      if (!await takeQuota(c, request, fetcher)) return json({ error: '已达到调用额度，请稍后再试或联系站点维护者。' }, 429, { 'retry-after': '3600' });
    } catch { return json({ error: '额度服务暂不可用，尚未发送给模型。' }, 503); }
    try {
      const body = JSON.parse(gateway_request(c.model, c.provider, input.text));
      if (body.ok === false) return json({ error: body.error }, 400);
      const response = await fetcher(c.endpoint, { method: 'POST', headers: { 'content-type': 'application/json', authorization: `Bearer ${c.key}` }, body: JSON.stringify(body), signal: AbortSignal.timeout(35000), redirect: 'error' });
      if (!response.ok) return json({ error: '模型服务请求失败，请稍后重试或联系站点维护者。' }, 502);
      const raw = await readLimited(response, 1000000);
      const result = JSON.parse(gateway_response(raw));
      if (!result.ok) return json({ error: result.error }, 422);
      return json(result);
    } catch { return json({ error: '模型服务超时或响应无效，请稍后重试。' }, 502); }
  };
}

export default { fetch: createHandler() };
