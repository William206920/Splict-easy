///|
// Browser capabilities only. Application decisions and markup are in MoonBit.
priv type WebRequest

///|
extern "js" fn io_text(id : String, text : String) -> Unit =
  #| (id, text) => { document.getElementById(id).textContent = text; }

///|
extern "js" fn io_html(id : String, html : String) -> Unit =
  #| (id, html) => { document.getElementById(id).innerHTML = html; }

///|
extern "js" fn io_value(id : String) -> String =
  #| id => document.getElementById(id).value

///|
extern "js" fn io_set_value(id : String, value : String) -> Unit =
  #| (id, value) => { document.getElementById(id).value = value; }

///|
extern "js" fn io_hidden(id : String, hidden : Bool) -> Unit =
  #| (id, hidden) => { document.getElementById(id).hidden = hidden; }

///|
extern "js" fn io_disabled(id : String, disabled : Bool) -> Unit =
  #| (id, disabled) => { document.getElementById(id).disabled = disabled; }

///|
extern "js" fn io_checked(id : String) -> Bool =
  #| id => document.getElementById(id).checked

///|
extern "js" fn io_set_checked(id : String, checked : Bool) -> Unit =
  #| (id, checked) => { document.getElementById(id).checked = checked; }

///|
extern "js" fn io_focus(id : String) -> Unit =
  #| id => document.getElementById(id).focus()

///|
extern "js" fn io_dialog(id : String, open : Bool) -> Unit =
  #| (id, open) => { const d = document.getElementById(id); if (open) d.showModal(); else d.close(); }

///|
extern "js" fn io_dialog_open(id : String) -> Bool =
  #| id => document.getElementById(id).open

///|
extern "js" fn io_class(id : String, name : String) -> Unit =
  #| (id, name) => { document.getElementById(id).className = name; }

///|
extern "js" fn io_later(ms : Int32, callback : () -> Unit) -> Int32 =
  #| (ms, callback) => setTimeout(callback, ms)

///|
extern "js" fn io_clear_timer(timer : Int32) -> Unit =
  #| timer => clearTimeout(timer)

///|
extern "js" fn io_confirm(text : String) -> Bool =
  #| text => window.confirm(text)

///|
extern "js" fn io_prompt(text : String, initial : String) -> String =
  #| (text, initial) => { const value = window.prompt(text, initial); return JSON.stringify({cancelled:value === null,value:value ?? ''}); }

///|
extern "js" fn io_on(
  id : String,
  event : String,
  callback : () -> Unit,
) -> Unit =
  #| (id, event, callback) => document.getElementById(id).addEventListener(event, e => { if (event === 'submit') e.preventDefault(); callback(); })

///|
extern "js" fn io_delegate(
  id : String,
  actions : String,
  callback : (String, String) -> Unit,
) -> Unit =
  #| (id, actions, callback) => document.getElementById(id).addEventListener('click', e => { const b = e.target.closest?.('button'); if (!b || !e.currentTarget.contains(b)) return; for (const key of actions.split(',')) if (b.dataset[key] !== undefined) { callback(key, b.dataset[key]); return; } })

///|
extern "js" fn io_hash() -> String =
  #| () => location.hash

///|
extern "js" fn io_set_hash(hash : String) -> Unit =
  #| hash => { location.hash = hash; }

///|
extern "js" fn io_route(name : String) -> Unit =
  #| name => { for (const p of document.querySelectorAll('.page')) p.hidden = p.id !== `page-${name}`; for (const l of document.querySelectorAll('[data-page]')) { const active = l.dataset.page === name; l.classList.toggle('active', active); if (active) l.setAttribute('aria-current','page'); else l.removeAttribute('aria-current'); } }

///|
extern "js" fn io_hash_change(callback : () -> Unit) -> Unit =
  #| callback => window.addEventListener('hashchange', callback)

///|
extern "js" fn io_storage_change(key : String, callback : () -> Unit) -> Unit =
  #| (key, callback) => window.addEventListener('storage', e => { if (e.key === key) callback(); })

///|
extern "js" fn io_before_unload(check : () -> Bool) -> Unit =
  #| check => window.addEventListener('beforeunload', e => { if (check()) { e.preventDefault(); e.returnValue = ''; } })

///|
extern "js" fn io_storage_read(key : String) -> String =
  #| key => { try { return JSON.stringify({ok:true,value:localStorage.getItem(key) ?? ''}); } catch { return '{"ok":false,"value":""}'; } }

///|
extern "js" fn io_storage_write(key : String, value : String) -> Bool =
  #| (key, value) => { try { localStorage.setItem(key, value); return true; } catch { return false; } }

///|
extern "js" fn io_download(
  name : String,
  content : String,
  type_ : String,
) -> Unit =
  #| (name, content, type) => { const url = URL.createObjectURL(new Blob([content],{type:`${type};charset=utf-8`})); const a = document.createElement('a'); a.href=url; a.download=name; a.click(); setTimeout(() => URL.revokeObjectURL(url),2000); }

///|
extern "js" fn io_copy(content : String, callback : (Bool) -> Unit) -> Unit =
  #| (content, callback) => { Promise.resolve().then(() => navigator.clipboard.writeText(content)).then(() => callback(true), () => callback(false)); }

///|
extern "js" fn io_selection() -> String =
  #| () => { const p = [...document.querySelectorAll('[data-person]:checked')]; return JSON.stringify({participants:p.map(e=>e.dataset.person),amounts:p.map(e=>e.closest('label').querySelector('.share-input').value)}); }

///|
extern "js" fn io_hide_selector(selector : String, hidden : Bool) -> Unit =
  #| (selector, hidden) => { for (const e of document.querySelectorAll(selector)) e.hidden = hidden; }

///|
extern "js" fn io_file_size(id : String) -> Int32 =
  #| id => document.getElementById(id).files[0]?.size ?? -1

///|
extern "js" fn io_file_read(
  id : String,
  callback : (Bool, String) -> Unit,
) -> Unit =
  #| (id, callback) => { const f=document.getElementById(id).files[0]; if (!f) return; f.text().then(text=>callback(true,text),()=>callback(false,'')); }

///|
extern "js" fn io_fetch(
  path : String,
  body : String,
  code : String,
  callback : (Int32, String) -> Unit,
) -> WebRequest =
  #| (path, body, code, callback) => { const c = new AbortController(); const options=body ? {method:'POST',headers:{'content-type':'application/json',authorization:`Bearer ${code}`},body,signal:c.signal} : {cache:'no-store',signal:c.signal}; fetch(path,options).then(async r=>callback(r.status,await r.text())).catch(e=>callback(e.name==='AbortError'?0:-1,'')); return c; }

///|
extern "js" fn io_abort(request : WebRequest) -> Unit =
  #| request => request.abort()

///|
extern "js" fn io_api_config() -> String =
  #| () => document.querySelector('meta[name="spliteasy-api"]')?.content ?? ''
