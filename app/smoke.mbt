///|
fn demand(ok : Bool, text : String) -> Unit raise @shared.BillError {
  if !ok {
    @shared.invalid("桌面集成检查失败：" + text)
  }
}

///|
pub fn smoke() -> Unit raise @shared.BillError {
  demand(
    @win32.create("SplitEasy application integration", false),
    "创建窗口",
  )
  let ui = Desktop::new(true)
  ui.render()
  for name in ["A", "B", "C"] {
    demand(@win32.set_text(11, name), "姓名输入")
    ui.handle(12)
  }
  demand(ui.session.ledger.people.length() == 3, "添加三人")
  ui.handle(21)
  ignore(@win32.set_text(52, "晚餐"))
  ignore(@win32.set_text(53, "100"))
  ui.handle(53)
  ui.handle(56)
  demand(ui.session.ledger.payments.length() == 1, "添加平均消费")
  ui.handle(21)
  ignore(@win32.set_text(52, "奶茶"))
  ignore(@win32.set_text(53, "30"))
  ignore(@win32.flag(51, 3, 1))
  ignore(@win32.flag(55, 3, 1))
  ui.handle(55)
  ignore(@win32.set_text(2000, "10"))
  ignore(@win32.set_text(2001, "20"))
  ignore(@win32.set_text(2002, "0"))
  ui.handle(2000)
  ui.handle(56)
  demand(ui.session.ledger.payments.length() == 2, "添加实际金额消费")
  ui.handle(34)
  match ui.session.report {
    Some(r) =>
      demand(
        r.balances.map(b => b.balance_cents) == [5667L, -2333L, -3334L],
        "混合结算",
      )
    None => demand(false, "报告存在")
  }
  ui.handle(35)
  ignore(@win32.flag(10, 3, 1))
  ignore(@win32.set_text(11, "Bee"))
  ui.handle(13)
  demand(
    ui.session.ledger.payments[1].payer == "Bee" && ui.session.report is None,
    "改名同步且旧结果失效",
  )
  ignore(@win32.flag(10, 3, 1))
  let blocked = try {
    ui.handle(14)
    false
  } catch {
    _ => true
  }
  demand(blocked, "关联删除阻断")
  ignore(@win32.flag(20, 3, 0))
  ui.handle(22)
  ignore(@win32.set_text(53, "90"))
  ui.handle(56)
  demand(ui.session.ledger.payments[0].amount_cents == 9000L, "编辑消费")
  ignore(@win32.flag(20, 3, 1))
  ui.handle(23)
  demand(ui.session.ledger.payments.length() == 1, "删除消费")
  ui.handle(33)
  ignore(@win32.set_text(70, @shared.encode_ledger(@shared.sample_mixed())))
  ui.handle(71)
  ui.handle(34)
  match ui.session.report {
    Some(r) =>
      demand(r.transfers[3].amount_cents == 2000L, "JSON 导入和黄金结算")
    None => demand(false, "导入报告")
  }
  @win32.close()
  demand(@win32.next_event() == 0, "应用窗口关闭")
  println(
    "PASS: desktop people + equal/exact + edit/delete + import + settlement + clipboard",
  )
}

///|
pub fn network_smoke(base : String) -> Unit raise @shared.BillError {
  demand(@win32.create("SplitEasy AI fixture integration", false), "AI 窗口")
  let ui = Desktop::new(true)
  ui.session.add_person("原账单")
  ui.ai_config = {
    base_url: base,
    api_key: "fixture-key-not-real",
    model: "fixture-model",
  }
  ui.ai_text = "我们是小明、小红、小刚、小美、小李。小明付晚餐200元，五人平摊。小红付奶茶75元，个人分别12、15、18、14、16元。"
  ui.page = 3
  ui.render()
  demand(@win32.flag(81, 6, 0) > 0, "密钥输入被遮盖")
  ui.handle(84)
  let mut ticks = 0
  while ui.waiting && ticks < 500 {
    let event = @win32.next_event()
    demand(event > 0, "AI 事件循环")
    ui.handle(event)
    ticks = ticks + 1
  }
  demand(!ui.waiting && ui.page == 4, "后台完成并预览")
  demand(
    ui.session.ledger.people == ["原账单"] && ui.session.report is None,
    "确认前原账单不变",
  )
  ui.handle(87)
  demand(
    ui.session.ledger.people == ["原账单"],
    "取消预览不修改账单",
  )
  ui.handle(84)
  ticks = 0
  while ui.waiting && ticks < 500 {
    let event = @win32.next_event()
    demand(event > 0, "AI 重新解析")
    ui.handle(event)
    ticks = ticks + 1
  }
  demand(ui.page == 4, "重新预览")
  ui.handle(86)
  demand(ui.session.ledger.people.length() == 5, "确认后替换")
  match ui.session.report {
    Some(r) =>
      demand(r.transfers[3].amount_cents == 2000L, "确认后黄金结算")
    None => demand(false, "AI 结算报告")
  }
  @win32.close()
  demand(@win32.next_event() == 0, "AI 窗口退出")
  println(
    "PASS: GUI asynchronous AI fixture + preview cancel + explicit confirmation + shared settlement",
  )
}
