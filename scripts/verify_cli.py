"""Independent golden and process-boundary checks; no network or model key."""
import json
import pathlib
import subprocess
import sys
import tempfile

exe = pathlib.Path(sys.argv[1]).resolve()

def call(*args):
    return subprocess.run([str(exe), *map(str, args)], capture_output=True,
                          encoding="utf-8", timeout=30)

with tempfile.TemporaryDirectory(prefix="spliteasy-cli-") as tmp:
    root = pathlib.Path(tmp)
    bill = root / "mixed.txt"
    bill.write_text("人：小明 小红 小刚 小美 小李\n小明 200 晚餐\n小红 75 奶茶 =小明:12 小红:15 小刚:18 小美:14 小李:16\n", encoding="utf-8")
    run = call("split", "-f", bill, "--json")
    assert run.returncode == 0, run.stderr
    result = json.loads(run.stdout)
    expected = [("小明",20000,5200,14800),("小红",7500,5500,2000),
                ("小刚",0,5800,-5800),("小美",0,5400,-5400),("小李",0,5600,-5600)]
    assert result["total_cents"] == 27500
    assert result["balances"] == [dict(person=n,paid_cents=p,due_cents=d,balance_cents=b) for n,p,d,b in expected]
    transfers = [("小刚","小明",5800),("小李","小明",5600),("小美","小明",3400),("小美","小红",2000)]
    assert result["transfers"] == [dict(zip(("from","to","amount_cents"),t)) for t in transfers]
    data = root / "账单.json"
    data.write_text(json.dumps(result["ledger"],ensure_ascii=False), encoding="utf-8")
    reread = call("split","-d",data,"--json")
    assert reread.returncode == 0 and json.loads(reread.stdout) == result
    markdown = root / "out.md"
    written = call("split","-f",bill,"-o",markdown)
    assert written.returncode == 0 and not written.stdout
    golden = pathlib.Path(__file__).resolve().parent.parent / "fixtures/expected_mixed.md"
    assert markdown.read_text(encoding="utf-8") == golden.read_text(encoding="utf-8")
    checked = call("check","-f",bill)
    assert checked.returncode == 0 and "校验通过" in checked.stdout
    bill.write_text("人：A B\n\nA 1 x @C",encoding="utf-8")
    bad = call("split","-f",bill)
    assert bad.returncode != 0 and not bad.stdout and "第 3 行" in bad.stderr
    for args in [("split","-f",bill,"-d",data),("split","-f",root/"missing"),("bad",)]:
        failure = call(*args)
        assert failure.returncode != 0 and failure.stderr and not failure.stdout
    large = dict(result["ledger"])
    p = dict(large["payments"][0]); p.update(amount_cents=9223372036854775807, participants=["小李"])
    large["payments"] = [p]
    data.write_text(json.dumps(large,ensure_ascii=False),encoding="utf-8")
    maximum = call("split","-d",data,"--json")
    assert maximum.returncode == 0, maximum.stderr
    assert json.loads(maximum.stdout)["transfers"][0]["amount_cents"] == 9223372036854775807
print("PASS: CLI golden JSON/Markdown + UTF8 files + exit codes + Int64 maximum")
