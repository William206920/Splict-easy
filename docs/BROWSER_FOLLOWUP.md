# SplitEasy 阶段 1 浏览器补充验证报告

结论：已代为完成真实 Chrome 浏览器引擎自动化验证，以及手机屏幕/触摸能力模拟验证；没有真实手机设备验收。

## 验证范围

- 对象：原始 SplitEasy-stage1.zip 中的 index.html 和 MoonBit 编译生成的 spliteasy.js。
- 环境：Linux、Playwright、Google Chrome for Testing 133.0.6943.16，无头浏览器。
- 未使用用户的电脑、手机或浏览器会话。
- 测试浏览器来自 Google 官方下载站。不是对当前最新版 Chrome 的兼容性承诺。
- 未修改网页源码，未进入下一开发阶段。

| 检查 | 结果 |
|---|---|
| 桌面 1280×800，通过本地 HTTP 加载 | 通过 |
| 手机竖屏模拟 390×844 | 通过 |
| 手机横屏模拟 844×390 | 通过 |
| 窄屏手机模拟 320×640 | 通过 |
| MoonBit 启动信息 | 四种尺寸均正确显示 |
| 页面横向溢出 | 四种尺寸均无 |
| 正文计算字号 | 16px |
| JavaScript/控制台错误 | 四种尺寸均无 |
| 页面和脚本请求失败 | 四种尺寸均无 |
| 外部网络请求 | 未观察到 |
| 中文显示 | 补齐测试容器中文字体后目视正常 |
| 已加载页面断网后保留显示 | 通过，仅检查静态启动页 |
| file:// 本地打开及断网刷新 | 当前测试浏览器通过 |
| HTTP 页面断网刷新 | 不支持，观察到 ERR_INTERNET_DISCONNECTED |

HTTP 离线刷新不支持是当前没有 Service Worker/离线缓存的实际限制；不把它写为通过。
file:// 的成功只适用于本次 Linux Chrome 测试环境，不代表所有浏览器及手机均兼容。
页面尚无消费输入或分账交互，不能验证断网分账、复制、草稿或触摸操作。

## 目视检查与环境修复

首轮截图中文字显示方框，确认测试容器没有中文字体。
从 Noto 官方仓库安装 Noto Sans CJK SC 字体后重新运行同一套测试，结果通过，手机竖屏截图中文字正常。
这项修复只影响测试环境，没有为网页增加 CDN 或外部字体请求。
截图仅用于内部视觉检查，不作为本报告的交付附件。

## 仍需要真实设备完成的检查

- iPhone Safari、Android Chrome 或用户实际使用的系统浏览器。
- 真实手机触摸、系统字号缩放、地址栏变化和实际设备字体。
- 用户 Windows 电脑与本地防火墙、同一 Wi-Fi 的访问链路。
- 阶段 6 完成后的业务交互、断网计算和剪贴板权限。

因此，阶段 1 的桌面浏览器引擎及手机尺寸模拟检查已补齐；真实手机验收保持“未验证”。
历史交付包中早先记录的“浏览器未验证”是当时状态，本报告是后续补充结果。

## 原始结果

```json
{
  "tested_at": "2026-10-15T05:02:05.945Z",
  "source": "Original SplitEasy-stage1.zip web files",
  "engine": "Google Chrome for Testing headless",
  "browser_version": "133.0.6943.16",
  "real_phone_tested": false,
  "real_windows_tested": false,
  "cases": [
    {
      "name": "desktop",
      "profile": {
        "viewport": {
          "width": 1280,
          "height": 800
        }
      },
      "httpStatus": 200,
      "state": {
        "title": "SplitEasy · 工程验证",
        "lang": "zh-CN",
        "status": "SplitEasy: MoonBit shared core ready.",
        "heading": "SplitEasy · AA 分账器",
        "viewportWidth": 1280,
        "scrollWidth": 1280,
        "fontSize": "16px",
        "statusBox": {
          "x": 344,
          "y": 195.890625,
          "width": 592,
          "height": 25.59375,
          "top": 195.890625,
          "right": 936,
          "bottom": 221.484375,
          "left": 344
        }
      },
      "consoleErrors": [],
      "failedRequests": [],
      "externalRequests": [],
      "offlineLoadedPageRetained": true,
      "passed": true
    },
    {
      "name": "mobile_portrait_emulation",
      "profile": {
        "viewport": {
          "width": 390,
          "height": 844
        },
        "isMobile": true,
        "hasTouch": true,
        "deviceScaleFactor": 3
      },
      "httpStatus": 200,
      "state": {
        "title": "SplitEasy · 工程验证",
        "lang": "zh-CN",
        "status": "SplitEasy: MoonBit shared core ready.",
        "heading": "SplitEasy · AA 分账器",
        "viewportWidth": 390,
        "scrollWidth": 390,
        "fontSize": "16px",
        "statusBox": {
          "x": 48,
          "y": 221.484375,
          "width": 294,
          "height": 51.1875,
          "top": 221.484375,
          "right": 342,
          "bottom": 272.671875,
          "left": 48
        }
      },
      "consoleErrors": [],
      "failedRequests": [],
      "externalRequests": [],
      "offlineLoadedPageRetained": true,
      "passed": true
    },
    {
      "name": "mobile_landscape_emulation",
      "profile": {
        "viewport": {
          "width": 844,
          "height": 390
        },
        "isMobile": true,
        "hasTouch": true,
        "deviceScaleFactor": 3
      },
      "httpStatus": 200,
      "state": {
        "title": "SplitEasy · 工程验证",
        "lang": "zh-CN",
        "status": "SplitEasy: MoonBit shared core ready.",
        "heading": "SplitEasy · AA 分账器",
        "viewportWidth": 844,
        "scrollWidth": 844,
        "fontSize": "16px",
        "statusBox": {
          "x": 126,
          "y": 195.890625,
          "width": 592,
          "height": 25.59375,
          "top": 195.890625,
          "right": 718,
          "bottom": 221.484375,
          "left": 126
        }
      },
      "consoleErrors": [],
      "failedRequests": [],
      "externalRequests": [],
      "offlineLoadedPageRetained": true,
      "passed": true
    },
    {
      "name": "narrow_mobile_emulation",
      "profile": {
        "viewport": {
          "width": 320,
          "height": 640
        },
        "isMobile": true,
        "hasTouch": true,
        "deviceScaleFactor": 2
      },
      "httpStatus": 200,
      "state": {
        "title": "SplitEasy · 工程验证",
        "lang": "zh-CN",
        "status": "SplitEasy: MoonBit shared core ready.",
        "heading": "SplitEasy · AA 分账器",
        "viewportWidth": 320,
        "scrollWidth": 320,
        "fontSize": "16px",
        "statusBox": {
          "x": 48,
          "y": 259.875,
          "width": 224,
          "height": 51.1875,
          "top": 259.875,
          "right": 272,
          "bottom": 311.0625,
          "left": 48
        }
      },
      "consoleErrors": [],
      "failedRequests": [],
      "externalRequests": [],
      "offlineLoadedPageRetained": true,
      "passed": true
    },
    {
      "name": "file_url_online_and_offline_reload",
      "passed": true,
      "consoleErrors": []
    },
    {
      "name": "http_offline_reload_without_service_worker",
      "offlineReloadSupported": false,
      "observedError": "page.reload: net::ERR_INTERNET_DISCONNECTED\nCall log:\n\u001b[2m  - waiting for navigation until \"load\"\u001b[22m\n",
      "expectedLimitationObserved": true
    }
  ],
  "source_hashes": {
    "index.html": "7a5bd0c58238ff6717e6b5ae50565c74413b5e95bb127ec62e2a5a1b86bf2fbc",
    "spliteasy.js": "ef9c9f53975108a3d6b9c243bd656a909e90a3928f3b372618c6c4b9e13bbaa1"
  },
  "serverRequests": [
    "/",
    "/spliteasy.js",
    "/",
    "/spliteasy.js",
    "/",
    "/spliteasy.js",
    "/",
    "/spliteasy.js",
    "/",
    "/spliteasy.js"
  ],
  "passed": true
}
```

## 可复现测试脚本

需要 Node.js、Playwright 和可运行的 Chromium/Chrome，脚本默认路径为本次环境路径。
复现时可设置 SPLITEASY_WEB_ROOT 为解压后 web 目录，SPLITEASY_CHROME 为浏览器可执行路径；同时调整 require 路径为本机 Playwright 安装路径。

```javascript
const {chromium}=require('/opt/codex/runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const http=require('http');const fs=require('fs');const path=require('path');const assert=require('assert/strict');const crypto=require('crypto');
(async()=>{
 const root=process.env.SPLITEASY_WEB_ROOT||'/tmp/spliteasy-stage1-browser/spliteasy/web';
 const out=__dirname;const requests=[];
 const server=http.createServer((req,res)=>{
  requests.push(req.url);const name=req.url==='/'?'index.html':req.url.slice(1);
  if(name==='favicon.ico'){res.writeHead(204).end();return;}
  if(!['index.html','spliteasy.js'].includes(name)){res.writeHead(404).end();return;}
  res.setHeader('Content-Type',name.endsWith('.js')?'text/javascript':'text/html; charset=utf-8');
  fs.createReadStream(path.join(root,name)).pipe(res);
 });
 await new Promise(r=>server.listen(0,'127.0.0.1',r));let browser;
 const result={tested_at:new Date().toISOString(),source:'Original SplitEasy-stage1.zip web files',engine:'Google Chrome for Testing headless',browser_version:null,real_phone_tested:false,real_windows_tested:false,cases:[],source_hashes:{}};
 for(const name of ['index.html','spliteasy.js'])result.source_hashes[name]=crypto.createHash('sha256').update(fs.readFileSync(path.join(root,name))).digest('hex');
 try{
  browser=await chromium.launch({executablePath:process.env.SPLITEASY_CHROME||'/tmp/spliteasy-chrome/chrome-headless-shell-linux64/chrome-headless-shell',headless:true,args:['--no-sandbox']});
  result.browser_version=browser.version();const base=`http://127.0.0.1:${server.address().port}`;
  const expected='SplitEasy: MoonBit shared core ready.';
  const profiles=[{name:'desktop',viewport:{width:1280,height:800}},{name:'mobile_portrait_emulation',viewport:{width:390,height:844},isMobile:true,hasTouch:true,deviceScaleFactor:3},{name:'mobile_landscape_emulation',viewport:{width:844,height:390},isMobile:true,hasTouch:true,deviceScaleFactor:3},{name:'narrow_mobile_emulation',viewport:{width:320,height:640},isMobile:true,hasTouch:true,deviceScaleFactor:2}];
  for(const profile of profiles){
   const {name,...options}=profile;const context=await browser.newContext(options);const page=await context.newPage();const errors=[];const failed=[];const external=[];
   page.on('pageerror',e=>errors.push(e.message));page.on('console',msg=>{if(msg.type()==='error')errors.push(msg.text());});
   page.on('requestfailed',req=>failed.push({url:req.url(),error:req.failure()}));page.on('request',req=>{if(!req.url().startsWith(base))external.push(req.url());});
   const response=await page.goto(base);await page.waitForFunction(()=>document.getElementById('status').textContent==='SplitEasy: MoonBit shared core ready.');
   const state=await page.evaluate(()=>({title:document.title,lang:document.documentElement.lang,status:document.getElementById('status').textContent,heading:document.querySelector('h1').textContent,viewportWidth:innerWidth,scrollWidth:document.documentElement.scrollWidth,fontSize:getComputedStyle(document.body).fontSize,statusBox:document.getElementById('status').getBoundingClientRect().toJSON()}));
   assert.equal(response.status(),200);assert.equal(state.status,expected);assert.equal(state.lang,'zh-CN');assert.ok(state.scrollWidth<=state.viewportWidth);assert.equal(state.fontSize,'16px');assert.deepEqual(errors,[]);assert.deepEqual(failed,[]);assert.deepEqual(external,[]);
   // Internal visual QA only; screenshots are not deliverables.
   await page.screenshot({path:path.join('/tmp',`spliteasy-${name}.png`),fullPage:true});
   await context.setOffline(true);const retained=await page.locator('#status').innerText();assert.equal(retained,expected);
   result.cases.push({name,profile:options,httpStatus:response.status(),state,consoleErrors:errors,failedRequests:failed,externalRequests:external,offlineLoadedPageRetained:retained===expected,passed:true});await context.close();
  }
  const fileContext=await browser.newContext();const filePage=await fileContext.newPage();const fileErrors=[];filePage.on('pageerror',e=>fileErrors.push(e.message));
  await filePage.goto('file://'+path.join(root,'index.html'));assert.equal(await filePage.locator('#status').innerText(),expected);await fileContext.setOffline(true);await filePage.reload();assert.equal(await filePage.locator('#status').innerText(),expected);assert.deepEqual(fileErrors,[]);
  result.cases.push({name:'file_url_online_and_offline_reload',passed:true,consoleErrors:fileErrors});await fileContext.close();
  const offlineContext=await browser.newContext();const offlinePage=await offlineContext.newPage();await offlinePage.goto(base);await offlineContext.setOffline(true);let blocked=false;let reloadError='';
  try{await offlinePage.reload({timeout:10000});}catch(e){blocked=true;reloadError=e.message;}
  assert.ok(blocked,'HTTP offline reload should not be advertised as cached offline support');
  result.cases.push({name:'http_offline_reload_without_service_worker',offlineReloadSupported:false,observedError:reloadError,expectedLimitationObserved:true});await offlineContext.close();
  result.serverRequests=requests;result.passed=true;
 }catch(e){result.passed=false;result.error=String(e);process.exitCode=1;}
 finally{if(browser)await browser.close();await new Promise(r=>server.close(r));fs.writeFileSync(path.join(out,'results.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify(result,null,2));}
})().catch(e=>{console.error(e);process.exitCode=1;});

```
