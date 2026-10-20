///|
// Visual kinds are implemented by the Win32 theme; all displayed money comes
// from shared. Existing control IDs keep the native workflows and tests intact.
fn panel(id : Int32, x : Int32, y : Int32, w : Int32, h : Int32) -> Unit {
  control(9, id, "", x, y, w, h)
}

///|
fn display_line(text : String) -> String {
  text
  .replace_all(old="\t", new=" ")
  .replace_all(old="\r", new=" ")
  .replace_all(old="\n", new=" ")
}

///|
fn Desktop::shell(
  self : Desktop,
  title : String,
  subtitle : String,
  height : Int32,
) -> Unit {
  let side = if @win32.width() < 1080 { 164 } else { 188 }
  let full = if height > @win32.height() { height } else { @win32.height() }
  control(15, 500, "", 0, 0, side, full)
  control(22, 501, "SplitEasy", 24, 28, side - 36, 34)
  control(21, 502, "让每一笔，都算清楚。", 24, 70, side - 32, 42)
  control(21, 503, "工作空间", 24, 138, side - 32, 24)
  control(
    if self.page == 0 {
      17
    } else {
      13
    },
    100,
    "账单工作台",
    12,
    174,
    side - 24,
    44,
  )
  control(
    if self.page == 5 {
      17
    } else {
      13
    },
    101,
    "管理成员",
    12,
    226,
    side - 24,
    44,
  )
  control(
    if self.page == 3 || (self.page == 4 && self.review_ai) {
      17
    } else {
      13
    },
    38,
    "AI 智能录入",
    12,
    278,
    side - 24,
    44,
  )
  control(
    if self.page == 2 || (self.page == 4 && !self.review_ai) {
      17
    } else {
      13
    },
    33,
    "文本与 JSON 导入",
    12,
    330,
    side - 24,
    44,
  )
  control(21, 504, "账单文件", 24, 410, side - 32, 24)
  control(13, 30, "新建账单", 12, 446, side - 24, 40)
  control(13, 31, "打开账单", 12, 494, side - 24, 40)
  control(13, 37, "体验混合示例", 12, 542, side - 24, 40)
  control(
    21,
    505,
    "本地账单 · 离线可用\nWindows 原生应用",
    24,
    full - 86,
    side - 32,
    56,
  )
  let x = side + 28
  let title_w = @win32.width() -
    x -
    28 -
    (if self.page == 0 || self.page == 1 {
      274
    } else if self.page == 5 {
      140
    } else {
      0
    })
  control(10, 510, title, x, 30, title_w, 40)
  control(20, 511, subtitle, x, 80, @win32.width() - x - 28, 42)
  if self.page != 0 && self.page != 5 {
    for id in [30, 31, 37] {
      ignore(@win32.flag(id, 4, 0))
    }
  }
  if self.waiting || self.page == 4 {
    for id in [100, 101, 38, 33] {
      ignore(@win32.flag(id, 4, 0))
    }
  }
  @win32.content(full)
}

///|
fn Desktop::members_view(
  self : Desktop,
  x : Int32,
  y : Int32,
  w : Int32,
) -> Unit {
  panel(530, x, y, w, 300)
  control(19, 531, "账单成员", x + 20, y + 18, w - 40, 30)
  control(
    11,
    532,
    self.session.ledger.people.length().to_string() +
    " 位成员 · 选中可编辑",
    x + 20,
    y + 56,
    w - 40,
    24,
  )
  control(6, 10, "", x + 14, y + 88, w - 28, 100)
  for name in self.session.ledger.people {
    @win32.list_add(10, name)
  }
  ignore(@win32.flag(10, 3, self.member_index))
  control(2, 11, self.member_text, x + 20, y + 202, w - 40, 32)
  let bw = (w - 56) / 3
  control(1, 12, "添加", x + 20, y + 248, bw, 34)
  control(1, 13, "改名", x + 28 + bw, y + 248, bw, 34)
  control(1, 14, "删除", x + 36 + bw * 2, y + 248, bw, 34)
}

///|
fn Desktop::members_page(self : Desktop, x : Int32, w : Int32) -> Unit {
  self.shell(
    "管理成员", "添加、改名和删除账单成员；改名会同步更新消费中的引用。",
    920,
  )
  panel(620, x, 136, w, 680)
  control(19, 621, "账单成员", x + 24, 158, w - 48, 30)
  control(
    11,
    622,
    self.session.ledger.people.length().to_string() +
    " / 200 位成员 · 选中后可查看关联消费",
    x + 24,
    202,
    w - 48,
    30,
  )
  let half = (w - 72) / 2
  control(6, 10, "", x + 20, 250, half, 532)
  for name in self.session.ledger.people {
    @win32.list_add(10, name)
  }
  ignore(@win32.flag(10, 3, self.member_index))
  let right = x + 48 + half
  control(
    11, 623, "成员姓名（不含空格或 @ ! = :）", right, 250, half, 50,
  )
  control(2, 11, self.member_text, right, 306, half, 36)
  control(14, 12, "添加成员", right, 360, half, 38)
  let bw = (half - 12) / 2
  control(1, 13, "保存改名", right, 414, bw, 36)
  control(1, 14, "删除成员", right + bw + 12, 414, bw, 36)
  control(1, 15, "清空输入，新增成员", right, 466, half, 36)
  control(7, 16, self.member_details(self.member_index), right, 526, half, 256)
  for id in [13, 14] {
    ignore(@win32.flag(id, 4, if self.member_index >= 0 { 1 } else { 0 }))
  }
  control(1, 32, "保存账单", x + w - 112, 36, 112, 38)
  control(28, 90, self.status, x, 840, w, 58)
}

///|
fn Desktop::import_view(self : Desktop, x : Int32, w : Int32) -> Unit {
  let wide = w >= 800
  let input_w = if wide { (w - 20) / 2 } else { w }
  let help_x = if wide { x + input_w + 20 } else { x }
  let help_y = if wide { 136 } else { 860 }
  let help_w = if wide { w - input_w - 20 } else { w }
  self.shell(
    "导入已有账单",
    "可先载入示例照着修改；解析后选择追加或替换，确认后才修改账单。",
    if wide {
      920
    } else {
      1530
    },
  )
  panel(610, x, 136, input_w, 660)
  control(19, 611, "账单内容", x + 24, 158, input_w - 48, 30)
  let bw = (input_w - 64) / 3
  control(1, 72, "文本示例", x + 24, 206, bw, 38)
  control(1, 73, "JSON 示例", x + 32 + bw, 206, bw, 38)
  control(1, 74, "当前账单", x + 40 + bw * 2, 206, bw, 38)
  control(
    11,
    612,
    "此处只编辑待导入内容，尚未修改当前账单。",
    x + 24,
    260,
    input_w - 48,
    40,
  )
  control(3, 70, self.advanced_text, x + 24, 310, input_w - 48, 462)
  panel(625, help_x, help_y, help_w, 660)
  control(19, 626, "怎么填写？", help_x + 24, help_y + 22, help_w - 48, 30)
  control(
    7,
    76,
    import_instructions(),
    help_x + 24,
    help_y + 76,
    help_w - 48,
    560,
  )
  control(14, 71, "解析并预览导入", x, 816, 220, 42)
  control(1, 57, "返回账单", x + 236, 816, 132, 42)
}

///|
fn Desktop::transfers_view(
  self : Desktop,
  x : Int32,
  y : Int32,
  w : Int32,
) -> Unit {
  panel(540, x, y, w, 300)
  control(19, 541, "转账清单", x + 20, y + 18, w - 40, 30)
  match self.session.report {
    Some(r) => {
      control(
        11,
        542,
        if r.transfers.is_empty() {
          "已经结清，无需转账"
        } else {
          r.transfers.length().to_string() + " 笔转账，结清这份账单"
        },
        x + 20,
        y + 56,
        w - 40,
        24,
      )
      if !r.transfers.is_empty() {
        control(6, 41, "", x + 12, y + 90, w - 24, 194)
      }
      for t in r.transfers {
        @win32.list_add(
          41,
          t.from +
          " → " +
          t.to +
          "\t待转账\t¥ " +
          @shared.money(t.amount_cents),
        )
      }
      if r.transfers.is_empty() {
        control(
          18,
          543,
          "每个人的收支都已平衡。",
          x + 20,
          y + 132,
          w - 40,
          54,
        )
      }
    }
    None => {
      control(
        11,
        542,
        "统一结算后，在这里查看谁转给谁",
        x + 20,
        y + 56,
        w - 40,
        44,
      )
      control(19, 543, "让分账更简单", x + 20, y + 128, w - 40, 30)
      control(
        11,
        544,
        "记录每一笔消费，\n我们帮你汇总并抵扣。",
        x + 20,
        y + 174,
        w - 40,
        60,
      )
    }
  }
}

///|
fn Desktop::overview_view(self : Desktop, x : Int32, w : Int32) -> Unit {
  let wide = w >= 700
  let main = if wide { w - 338 } else { w }
  let bottom = if wide { 898 } else { 1220 }
  self.shell(
    "账单工作台", "聚餐、旅行与日常开销，一份账单轻松分清。",
    bottom,
  )
  // The headline total describes recorded expenses, even before settlement.
  let total = try {
    let mut sum = 0L
    for p in self.session.ledger.payments {
      sum = @shared.add_money(sum, p.amount_cents)
    }
    "¥ " + @shared.money(sum)
  } catch {
    _ => "总额超出范围"
  }
  let tile = (w - 32) / 3
  control(25, 550, "", x, 136, tile, 104)
  control(27, 551, "账单总消费", x + 20, 150, tile - 40, 24)
  // Long Int64 amounts wrap in a smaller font instead of disappearing.
  control(
    if total.length() > 16 {
      27
    } else {
      26
    },
    552,
    total,
    x + 20,
    183,
    tile - 40,
    49,
  )
  for i = 0; i < 2; i = i + 1 {
    let tx = x + (i + 1) * (tile + 16)
    panel(553 + i, tx, 136, tile, 104)
    control(
      11,
      555 + i,
      if i == 0 {
        "参与成员"
      } else {
        "消费记录"
      },
      tx + 20,
      150,
      tile - 40,
      24,
    )
    control(
      12,
      557 + i,
      if i == 0 {
        self.session.ledger.people.length().to_string() + " 人"
      } else {
        self.session.ledger.payments.length().to_string() + " 笔"
      },
      tx + 20,
      182,
      tile - 40,
      44,
    )
  }
  panel(560, x, 264, main, 300)
  control(19, 561, "消费明细", x + 20, 284, main - 180, 30)
  control(14, 21, "+ 添加消费", x + main - 152, 280, 132, 38)
  control(
    11,
    562,
    "选中记录可编辑 · 平均与实际金额可混合记账",
    x + 20,
    326,
    main - 40,
    24,
  )
  if !self.session.ledger.payments.is_empty() {
    control(6, 20, "", x + 12, 362, main - 24, 140)
  }
  for p in self.session.ledger.payments {
    @win32.list_add(
      20,
      display_line(p.description) +
      "\t" +
      p.payer +
      " 付款 · " +
      (if p.split_mode == @shared.Equal {
        "平均分摊"
      } else {
        "按实际金额"
      }) +
      (if p.date.is_empty() { "" } else { " · " + p.date }) +
      "\t¥ " +
      @shared.money(p.amount_cents),
    )
  }
  if self.session.ledger.payments.is_empty() {
    control(
      11,
      563,
      "还没有消费记录，点击「添加消费」开始。",
      x + 24,
      400,
      main - 48,
      54,
    )
  }
  control(1, 22, "编辑记录", x + 20, 514, 100, 34)
  control(1, 23, "删除记录", x + 132, 514, 100, 34)
  panel(570, x, 584, main, 252)
  control(19, 571, "完整结算单", x + 20, 602, main - 220, 30)
  control(1, 35, "复制", x + main - 182, 598, 72, 34)
  control(1, 36, "导出", x + main - 98, 598, 78, 34)
  let text = match self.session.report {
    Some(r) => @shared.render_text(r)
    None =>
      "尚未结算\n\n添加成员和消费后，点击「统一结算」。\n账单变更后需重新结算，确保结果与当前记录一致。"
  }
  control(7, 40, text, x + 20, 648, main - 40, 168)
  if wide {
    self.transfers_view(x + main + 20, 264, 318)
    self.members_view(x + main + 20, 584, 318)
  } else {
    self.transfers_view(x, 858, (w - 16) / 2)
    self.members_view(x + (w - 16) / 2 + 16, 858, (w - 16) / 2)
  }
  control(
    28,
    90,
    self.status,
    x,
    if wide {
      852
    } else {
      1174
    },
    if wide {
      main
    } else {
      w
    },
    44,
  )
  // Main actions live in a single row with a clearly stronger primary action.
  control(1, 32, "保存账单", x + w - 258, 36, 112, 38)
  control(14, 34, "统一结算", x + w - 130, 36, 130, 38)
  // Avoid title overlap on narrow Windows; keep the same actions beneath the title.
  if w < 760 {
    // The shell title is short; smaller action widths leave room for it.
    ignore(@win32.set_text(510, "账单"))
  }
  for id in [35] {
    ignore(
      @win32.flag(id, 4, if self.session.report is Some(_) { 1 } else { 0 }),
    )
  }
  ignore(
    @win32.flag(
      36,
      4,
      if self.session.ledger.payments.is_empty() {
        0
      } else {
        1
      },
    ),
  )
  for id in [22, 23] {
    ignore(
      @win32.flag(
        id,
        4,
        if self.session.ledger.payments.is_empty() {
          0
        } else {
          1
        },
      ),
    )
  }
  ignore(
    @win32.flag(
      21,
      4,
      if self.session.ledger.people.is_empty() {
        0
      } else {
        1
      },
    ),
  )
}

///|
fn Desktop::editor_view(self : Desktop, x : Int32, w : Int32) -> Unit {
  let cols = if w >= 700 { 2 } else { 1 }
  let rows = (self.session.ledger.people.length() + cols - 1) / cols
  let h = 620 + rows * 54
  self.shell(
    if self.edit_index < 0 {
      "添加一笔消费"
    } else {
      "编辑消费"
    },
    "先填写付款信息，再选择这笔消费由谁承担。",
    h + 72,
  )
  panel(580, x, 136, w, 246)
  control(19, 581, "付款信息", x + 24, 154, w - 48, 30)
  control(11, 582, "消费名称", x + 24, 202, w - 48, 24)
  control(2, 52, self.form.description, x + 24, 230, w - 48, 34)
  let field = (w - 72) / 2
  control(11, 583, "付款人", x + 24, 284, field, 22)
  control(5, 51, "", x + 24, 314, field, 200)
  for name in self.session.ledger.people {
    @win32.list_add(51, name)
  }
  ignore(@win32.flag(51, 3, self.form.payer))
  control(11, 584, "实付总额（元）", x + 48 + field, 284, field, 22)
  control(2, 53, self.form.amount, x + 48 + field, 314, field, 34)
  panel(585, x, 402, w, h - 402)
  control(19, 586, "分摊明细", x + 24, 422, 160, 30)
  control(5, 55, "", x + 24, 470, field, 200)
  @win32.list_add(55, "平均分摊 · 勾选参与者")
  @win32.list_add(55, "实际金额 · 逐人填写")
  ignore(@win32.flag(55, 3, if self.form.exact { 1 } else { 0 }))
  control(
    11,
    587,
    "日期（可空，YYYY-MM-DD）",
    x + 48 + field,
    438,
    field,
    24,
  )
  control(2, 54, self.form.date, x + 48 + field, 470, field, 34)
  control(11, 60, "", x + 24, 524, w - 48, 46)
  let cell = (w - 48) / cols
  for i = 0; i < self.session.ledger.people.length(); i = i + 1 {
    let cy = 584 + i / cols * 54
    let cx = x + 24 + i % cols * cell
    let name = self.session.ledger.people[i]
    if self.form.exact {
      control(23, 3000 + i, name, cx, cy + 4, cell / 2 - 8, 30)
      control(
        2,
        2000 + i,
        self.form.amounts[i],
        cx + cell / 2,
        cy,
        cell / 2 - 18,
        34,
      )
    } else {
      control(4, 1000 + i, name, cx, cy, cell - 16, 34)
      ignore(
        @win32.flag(1000 + i, 1, if self.form.selected[i] { 1 } else { 0 }),
      )
    }
  }
  // Extend the participant card to include all rows, even for 200 members.
  // Card is created before children; content height includes action/footer space.
  control(14, 56, "保存消费", x + w - 146, 36, 146, 40)
  control(1, 57, "取消", x + w - 242, 36, 80, 40)
  @win32.content(h + 72)
  self.preview()
}

///|
pub fn Desktop::render_view(self : Desktop) -> Unit {
  @win32.clear()
  let side = if @win32.width() < 1080 { 164 } else { 188 }
  let x = side + 28
  let w = @win32.width() - x - 28
  if self.page == 0 {
    self.overview_view(x, w)
  } else if self.page == 1 {
    self.editor_view(x, w)
  } else if self.page == 5 {
    self.members_page(x, w)
  } else if self.page == 3 {
    self.shell(
      "AI 智能录入", "用一段话记录多笔消费，发送前确认，解析后再核对。",
      900,
    )
    panel(590, x, 136, w, 244)
    control(19, 591, "模型服务", x + 24, 154, w - 48, 30)
    control(
      11,
      592,
      "服务地址 · Kimi 示例：https://api.moonshot.cn/v1",
      x + 24,
      198,
      w - 48,
      24,
    )
    control(2, 80, self.ai_config.base_url, x + 24, 228, w - 48, 34)
    let half = (w - 72) / 2
    control(11, 593, "API Key · 仅本次会话使用", x + 24, 282, half, 24)
    control(8, 81, self.ai_config.api_key, x + 24, 312, half, 34)
    control(
      11,
      594,
      "模型名称 · 如 kimi-k2.6",
      x + 48 + half,
      282,
      half,
      24,
    )
    control(2, 83, self.ai_config.model, x + 48 + half, 312, half, 34)
    panel(595, x, 402, w, 360)
    control(19, 596, "描述这份账单", x + 24, 422, w - 48, 30)
    control(
      11,
      597,
      "仅描述新增消费；默认追加，原记录保留。当前 " +
      self.session.ledger.payments.length().to_string() +
      " 笔。",
      x + 24,
      464,
      w - 48,
      26,
    )
    control(3, 82, self.ai_text, x + 24, 508, w - 48, 230)
    control(
      14,
      84,
      if self.waiting {
        "正在解析…"
      } else {
        "核对并发送解析"
      },
      x,
      784,
      206,
      42,
    )
    control(
      1,
      85,
      if self.waiting {
        "取消请求"
      } else {
        "返回账单"
      },
      x + 222,
      784,
      132,
      42,
    )
    control(28, 89, self.status, x, 844, w, 44)
    if self.waiting {
      for id in [80, 81, 82, 83, 84, 100] {
        ignore(@win32.flag(id, 4, 0))
      }
    }
  } else if self.page == 4 {
    self.review_view(x, w)
  } else {
    self.import_view(x, w)
  }
}
