// Optional real-browser verification. Requires Playwright and Chromium/Chrome.
const {chromium}=require(process.env.SPLITEASY_PLAYWRIGHT||'playwright');
const fs=require('fs');const path=require('path');const assert=require('assert/strict');
(async()=>{
 const root=path.resolve(__dirname,'..');const generated=path.join(root,'docs/generated');
 const options={headless:true,args:['--no-sandbox']};if(process.env.SPLITEASY_CHROME)options.executablePath=process.env.SPLITEASY_CHROME;
 const browser=await chromium.launch(options);const cases=[];
 try{
  for(const [name,viewport] of [['desktop',{width:1280,height:800}],['mobile_emulation',{width:390,height:844}],['narrow_mobile_emulation',{width:320,height:640}]]){
   const context=await browser.newContext({viewport,isMobile:name!=='desktop',hasTouch:name!=='desktop'});await context.setOffline(true);
   for(const file of ['dinner_html.html','mixed_html.html','special_html.html','no_transfer_html.html']){
    const page=await context.newPage();const errors=[];const dialogs=[];const external=[];
    page.on('pageerror',e=>errors.push(e.message));page.on('dialog',async dialog=>{dialogs.push(dialog.message());await dialog.dismiss();});page.on('request',req=>{if(/^https?:/.test(req.url()))external.push(req.url());});
    await page.goto('file://'+path.join(generated,file));
    const state=await page.evaluate(()=>({viewportWidth:innerWidth,scrollWidth:document.documentElement.scrollWidth,scripts:document.scripts.length,images:document.images.length,body:document.body.innerText,balances:[...document.querySelectorAll('tbody tr')].map(row=>({person:row.cells[0].textContent,net:row.cells[3].textContent,color:getComputedStyle(row.cells[3]).color}))}));
    assert.ok(state.scrollWidth<=state.viewportWidth);assert.equal(state.scripts,0);assert.equal(state.images,0);assert.deepEqual(dialogs,[]);assert.deepEqual(errors,[]);assert.deepEqual(external,[]);
    if(file==='mixed_html.html'){
     assert.ok(state.body.includes('275.00 元'));assert.ok(state.body.includes('按实际金额分摊'));assert.ok(state.body.includes('小美 → 小红：20.00 元'));
     assert.equal(state.balances[0].color,'rgb(21, 128, 61)');assert.equal(state.balances[2].color,'rgb(185, 28, 28)');
    }
    if(file==='special_html.html')assert.ok(state.body.includes('茶</h3><script>alert(1)</script>&"\'|'));
    if(file==='no_transfer_html.html')assert.ok(state.body.includes('无需转账，所有人已平账。'));
    if(name==='mobile_emulation' && file==='mixed_html.html')await page.screenshot({path:'/tmp/spliteasy-stage5-mixed-mobile.png',fullPage:true});
    if(name==='desktop' && file==='special_html.html')await page.screenshot({path:'/tmp/spliteasy-stage5-special-desktop.png',fullPage:true});
    cases.push({profile:name,viewport,file,offlineLoaded:true,noPageOverflow:true,noScriptOrImageInjection:true,externalRequests:external,errors,passed:true});await page.close();
   }
   const page=await context.newPage();await page.setContent('<!doctype html><meta charset="utf-8">'+fs.readFileSync(path.join(generated,'error_html.html'),'utf8'));
   assert.equal(await page.locator('[role="alert"]').count(),1);assert.equal(await page.locator('script').count(),0);assert.ok((await page.locator('[role="alert"]').innerText()).includes('第 2 行：未知付款人：<script>'));await page.close();
   await context.close();
  }
  const result={browser:browser.version(),engine:'Linux Chrome headless',realPhoneTested:false,cases,errorHtmlSafeInAllProfiles:true,passed:true};fs.writeFileSync(path.join(generated,'browser-verification.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({browser:result.browser,cases:cases.length,realPhoneTested:false,passed:true}));
 }finally{await browser.close();}
})().catch(error=>{console.error(error);process.exitCode=1;});
