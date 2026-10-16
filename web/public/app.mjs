import { execute } from './core.mjs';

const $ = id => document.getElementById(id);
const EMPTY = '{"schema_version":1,"people":[],"payments":[],"ambiguous":[]}';
const SAMPLE = '人：小明 小红 小刚\n小明 90 晚餐\n小红 30 奶茶 =小明:10 小红:20\n小刚 20 车费 @小明 小刚';
const FREE_SAMPLE = '我们三人：小明、小红、小刚。小明付了90元晚餐，三人平摊。小红付了30元奶茶，小明喝10元、小红喝20元，小刚没喝。小刚付20元车费，由小明和小刚平摊。';
const STORAGE = 'spliteasy.online.ledger.v1';
let ledger = EMPTY, view, savedSource = null, corruptedSource = null, timer, editing = -1, preview = null, request = null, requestSerial = 0, service;
const esc = value => String(value).replace(/[&<>"']/g, char => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[char]));
const avatar = name => esc([...name][0] || '·');
const empty = (text, symbol = '◌') => `<div class="empty"><span class="empty-symbol" aria-hidden="true">${symbol}</span>${esc(text)}</div>`;

function notify(message, error = false) {
  clearTimeout(timer); $('notice').textContent = message; $('notice').className = `toast${error ? ' error' : ''}`; $('notice').hidden = false;
  timer = setTimeout(() => { $('notice').hidden = true; }, error ? 10000 : 4000);
}
function core(action, data = {}, source = ledger) {
  const result = JSON.parse(execute(action, source, JSON.stringify(data)));
  if (!result.ok) throw new Error(result.error);
  return result;
}
function download(filename, content, type = 'application/json') {
  const url = URL.createObjectURL(new Blob([content], { type: `${type};charset=utf-8` }));
  const link = document.createElement('a'); link.href = url; link.download = filename; link.click(); setTimeout(() => URL.revokeObjectURL(url), 2000);
}
function ensureWritable() {
  if (request) throw new Error('AI 正在解析，请先取消请求再修改账单。');
  if (corruptedSource !== null) {
    if (!confirm('发现无法读取的旧草稿。继续将下载旧草稿备份，再保存新的账单。是否继续？')) throw new Error('已保留旧草稿');
    download('SplitEasy-草稿恢复备份.txt', corruptedSource, 'text/plain'); corruptedSource = null;
  }
  let current;
  try { current = localStorage.getItem(STORAGE); } catch { return; }
  if (current !== savedSource) throw new Error('另一个标签页已修改账单。请先导出当前账单备份，再刷新页面载入最新内容。');
}
function commit(result) {
  ensureWritable();
  ledger = result.ledger; view = result;
  try { localStorage.setItem(STORAGE, ledger); savedSource = ledger; } catch { notify('当前账单可继续使用，但浏览器未能保存。请及时导出备份。', true); }
  render();
}
function change(action, data) { commit(core(action, data)); }
function safely(fn) { try { fn(); } catch (error) { notify(error.message || '操作失败', true); } }

function render() {
  $('stat-total').textContent = `¥ ${view.total}`;
  $('stat-people').innerHTML = `${view.people.length} <em>人</em>`;
  $('stat-payments').innerHTML = `${view.payments.length} <em>笔</em>`;
  $('expense-list').innerHTML = view.payments.length ? view.payments.map((p, index) => `<div class="expense-row"><span class="expense-avatar">${avatar(p.description)}</span><div class="expense-detail"><strong>${esc(p.description)}</strong><small>${esc(p.payer)} 付款 · ${p.mode === 'equal' ? `${p.participants.length} 人平摊` : '按实际金额'}${p.date ? ` · ${esc(p.date)}` : ''}</small></div><span class="expense-amount">¥ ${esc(p.amount)}</span><div class="row-actions"><button data-edit="${index}" aria-label="编辑${esc(p.description)}">编辑</button><button data-delete="${index}" aria-label="删除${esc(p.description)}">删除</button></div></div>`).join('') : empty('还没有消费，从记录第一笔开始。', '▤');
  $('transfer-list').innerHTML = view.transfers.length ? view.transfers.map(t => `<div class="transfer"><span>${esc(t.from)}</span><span class="arrow">→</span><span>${esc(t.to)}</span><strong>¥ ${esc(t.amount)}</strong></div>`).join('') : empty(view.payments.length ? '大家已经平衡，无需转账。' : '添加消费后，这里会告诉你怎么转账。', '⇄');
  $('balance-rows').innerHTML = view.balances.length ? view.balances.map(b => `<tr><td>${esc(b.person)}</td><td>¥ ${esc(b.paid)}</td><td>¥ ${esc(b.due)}</td><td class="${b.balance.startsWith('-') ? 'negative' : 'positive'}">${b.balance.startsWith('-') ? '应付 ' + esc(b.balance.slice(1)) : b.balance === '0.00' ? '已平衡' : '应收 ' + esc(b.balance)}</td></tr>`).join('') : `<tr><td colspan="4"><div class="empty">记录消费后，查看每个人的付款与份额。</div></td></tr>`;
  $('member-list').innerHTML = view.people.length ? view.people.map((name, index) => {
    const count = view.payments.filter(p => p.payer === name || p.participants.includes(name) || p.shares.some(s => s.person === name)).length;
    return `<div class="member-card"><span class="avatar">${avatar(name)}</span><div class="info"><strong>${esc(name)}</strong><p>关联 ${count} 笔消费</p><div class="row-actions"><button data-rename="${index}">改名</button><button data-remove="${index}">删除</button></div></div></div>`;
  }).join('') : empty('还没有成员，添加一起记账的人吧。', '♧');
}
function navigate() {
  const name = ['overview', 'members', 'import', 'ai'].includes(location.hash.slice(1)) ? location.hash.slice(1) : 'overview';
  for (const page of document.querySelectorAll('.page')) page.hidden = page.id !== `page-${name}`;
  for (const link of document.querySelectorAll('[data-page]')) { link.classList.toggle('active', link.dataset.page === name); if (link.dataset.page === name) link.setAttribute('aria-current', 'page'); else link.removeAttribute('aria-current'); }
}
function openExpense(index = -1) {
  ensureWritable();
  if (!view.people.length) { location.hash = 'members'; $('member-name').focus(); throw new Error('先添加一起分账的成员吧。'); }
  editing = index;
  const p = view.payments[index];
  $('expense-title').textContent = p ? '编辑消费' : '添加消费';
  $('expense-description').value = p?.description || ''; $('expense-amount').value = p?.amount || '';
  $('expense-payer').innerHTML = view.people.map(name => `<option>${esc(name)}</option>`).join('');
  if (p) $('expense-payer').value = p.payer;
  $('expense-mode').value = p?.mode || 'equal'; $('expense-date').value = p?.date || ''; $('expense-error').textContent = '';
  $('participants').innerHTML = view.people.map((name, i) => `<label class="participant" for="participant-${i}"><input id="participant-${i}" type="checkbox" data-person="${esc(name)}" ${!p || p.participants.includes(name) || p.shares.some(s => s.person === name) ? 'checked' : ''}><span>${esc(name)}</span><input class="share-input" data-share="${i}" aria-label="${esc(name)}的实际份额（元）" inputmode="decimal" placeholder="金额（元）" value="${esc(p?.shares.find(s => s.person === name)?.amount || '')}"></label>`).join('');
  updateSplit(); $('expense-dialog').showModal(); $('expense-description').focus();
}
function updateSplit() {
  const exact = $('expense-mode').value === 'exact';
  for (const input of document.querySelectorAll('.share-input')) input.hidden = !exact;
  $('split-hint').textContent = exact ? '勾选参与成员，并逐人填写金额（元）。合计必须等于实付。' : '选中的成员平摊，尾差按名单顺序给靠后者。';
}
function showPreview(result, text) {
  preview = { result, source: ledger }; $('preview-content').textContent = text; $('preview-dialog').showModal();
}

try {
  savedSource = localStorage.getItem(STORAGE);
  if (savedSource) { const loaded = core('view', {}, savedSource); ledger = loaded.ledger; }
} catch (error) { corruptedSource = savedSource; notify('旧草稿无法读取，已保留原内容。请先导出备份后再记账。', true); }
view = core('view'); render(); navigate();
window.addEventListener('hashchange', navigate);
window.addEventListener('storage', event => { if (event.key === STORAGE) notify('另一个标签页更新了账单。请导出当前记录后刷新，避免覆盖。', true); });
$('new-expense').onclick = () => safely(() => openExpense());
$('expense-mode').onchange = updateSplit;
$('close-expense').onclick = $('cancel-expense').onclick = () => $('expense-dialog').close();
$('expense-form').onsubmit = event => {
  event.preventDefault();
  try {
    const participants = [...document.querySelectorAll('[data-person]:checked')];
    change('put_payment', { index: String(editing), payer: $('expense-payer').value, amount: $('expense-amount').value.trim(), description: $('expense-description').value.trim(), date: $('expense-date').value, mode: $('expense-mode').value,
      participants: participants.map(el => el.dataset.person), amounts: participants.map(el => el.closest('label').querySelector('.share-input').value.trim()) });
    $('expense-dialog').close(); notify('消费已保存');
  } catch (error) { $('expense-error').textContent = error.message; }
};
$('expense-list').onclick = event => safely(() => {
  const button = event.target.closest('button'); if (!button) return;
  if (button.dataset.edit !== undefined) openExpense(Number(button.dataset.edit));
  if (button.dataset.delete !== undefined && confirm('删除这笔消费？')) { change('remove_payment', { index: button.dataset.delete }); notify('消费已删除'); }
});
$('member-form').onsubmit = event => { event.preventDefault(); safely(() => { change('add_person', { name: $('member-name').value.trim() }); $('member-name').value = ''; $('member-name').focus(); notify('成员已添加'); }); };
$('member-list').onclick = event => safely(() => {
  const button = event.target.closest('button'); if (!button) return;
  if (button.dataset.rename !== undefined) {
    const old = view.people[Number(button.dataset.rename)]; const name = prompt('修改成员姓名（会同步更新相关消费）', old);
    if (name !== null) change('rename', { old, name: name.trim() });
  }
  if (button.dataset.remove !== undefined) { const name = view.people[Number(button.dataset.remove)]; if (confirm(`删除成员「${name}」？`)) change('remove_person', { name }); }
});
$('load-sample').onclick = () => safely(() => { ensureWritable(); const sample = core('import', { text: SAMPLE }); showPreview(sample, sample.text); });
$('text-sample').onclick = () => { if (!$('import-text').value || confirm('用文本示例替换输入框内容？')) $('import-text').value = SAMPLE; };
$('json-sample').onclick = () => { if (!$('import-text').value || confirm('用 JSON 示例替换输入框内容？')) $('import-text').value = core('import', { text: SAMPLE }).ledger; };
$('preview-import').onclick = () => safely(() => { ensureWritable(); const result = core('import', { text: $('import-text').value }); showPreview(result, result.people.length ? `成员：${result.people.join('、')}\n\n${result.text}` : '空账单，确认后清空当前账本。'); });
$('import-file').onchange = async () => {
  const file = $('import-file').files[0]; if (!file) return;
  try { if (file.size > 2000000) throw new Error('文件不得超过 2 MB'); if (!$('import-text').value || confirm('用文件内容替换输入框？')) $('import-text').value = await file.text(); } catch (error) { notify(error.message, true); }
  $('import-file').value = '';
};
$('cancel-preview').onclick = () => { preview = null; $('preview-dialog').close(); };
$('preview-dialog').addEventListener('cancel', () => { preview = null; });
$('apply-preview').onclick = () => safely(() => { if (!preview || preview.source !== ledger) throw new Error('账单已改变，请重新预览。'); commit(preview.result); preview = null; $('preview-dialog').close(); location.hash = 'overview'; notify('已确认并载入账单'); });
$('clear-ledger').onclick = () => safely(() => { if (confirm('新建空账本会替换当前账单。需要保留时请先导出。是否继续？')) { commit(core('view', {}, EMPTY)); notify('已新建空账本'); } });
$('export-json').onclick = () => download('SplitEasy-账单.json', ledger);
$('export-md').onclick = () => { if (!view.payments.length) return notify('先添加消费后再导出结算单'); download('SplitEasy-结算单.md', view.markdown, 'text/markdown'); };
$('copy-report').onclick = async () => { try { if (!view.payments.length) return notify('先添加消费后再复制结算单'); await navigator.clipboard.writeText(view.text); notify('已复制结算单'); } catch { download('SplitEasy-结算单.txt', view.text, 'text/plain'); notify('无法访问剪贴板，已下载文本结算单'); } };
$('ai-sample').onclick = () => { if (!$('ai-text').value || confirm('用示例替换输入文字？')) $('ai-text').value = FREE_SAMPLE; };
async function checkService() {
  try { const response = await fetch('/api/parse', { cache: 'no-store' }); if (!response.ok) throw new Error(); service = await response.json(); $('invite-field').hidden = !service.invitationRequired; $('ai-status').textContent = service.enabled ? `服务：${service.provider} · ${service.model}。${service.invitationRequired ? '需要邀请码，' : '向所有访客开放，'}每次最多 8000 字符。` : '共享 AI 尚未配置完成。你仍可使用文本导入和普通记账。'; }
  catch { $('ai-status').textContent = '暂时无法连接 AI 服务。你仍可使用文本导入和普通记账。'; service = null; }
  $('send-ai').disabled = !service?.enabled;
}
checkService();
function stopRequest() { if (request) request.abort(); request = null; requestSerial++; $('send-ai').disabled = !service?.enabled; $('cancel-ai').hidden = true; $('send-ai').textContent = '✧ 发送并解析'; }
$('cancel-ai').onclick = () => { stopRequest(); notify('已取消，响应不会记入账单。已发出的模型请求仍可能产生费用。'); };
$('send-ai').onclick = async () => {
  let serial, source;
  try {
    ensureWritable();
    if (!$('ai-consent').checked) throw new Error('请先勾选同意外发文字。');
    const text = $('ai-text').value.trim(); if (!text || text.length > 8000) throw new Error('请输入 1–8000 字符的账单描述。');
    const code = $('invite-code').value; if (service?.invitationRequired && !code) throw new Error('请输入站点邀请码。');
    if (!confirm(`将把输入框中的账单文字发送至 ${service?.provider || ''}，使用 ${service?.model || ''} 解析。是否发送？`)) return;
    source = ledger; request = new AbortController(); serial = ++requestSerial;
    $('send-ai').disabled = true; $('send-ai').textContent = '正在整理账单…'; $('cancel-ai').hidden = false;
    const response = await fetch('/api/parse', { method: 'POST', headers: { 'content-type': 'application/json', authorization: `Bearer ${code}` }, body: JSON.stringify({ text, consent: true }), signal: request.signal });
    const result = await response.json();
    if (serial !== requestSerial) return;
    if (!response.ok) throw new Error(result.error || '解析失败');
    if (source !== ledger) throw new Error('账单已改变，请重新解析。');
    stopRequest();
    const verified = core('view', {}, result.ledger); showPreview(verified, result.preview);
    $('ai-consent').checked = false;
  } catch (error) { if (serial && serial !== requestSerial) return; if (error.name !== 'AbortError') notify(error.message || '请求失败', true); }
  finally { if (serial === requestSerial) stopRequest(); }
};
window.addEventListener('beforeunload', event => { if (request || $('expense-dialog').open) { event.preventDefault(); event.returnValue = ''; } });
