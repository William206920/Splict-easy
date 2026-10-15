"""Loopback fixture server verifies transport and consent, never a real model."""
import http.server
import json
import os
import pathlib
import subprocess
import sys
import tempfile
import threading
import time

cli = str(pathlib.Path(sys.argv[1]).resolve())
smoke = str(pathlib.Path(sys.argv[2]).resolve())
people = ["小明","小红","小刚","小美","小李"]
ledger = {"schema_version":1,"people":people,"ambiguous":[],"payments":[
    dict(payer="小明",amount_cents=20000,split_mode="equal",participants=people,shares=[],description="晚餐",date=""),
    dict(payer="小红",amount_cents=7500,split_mode="exact",participants=[],shares=[dict(person=n,amount_cents=a) for n,a in zip(people,[1200,1500,1800,1400,1600])],description="奶茶",date="")]}
state = {"mode":"success","calls":0}

class Handler(http.server.BaseHTTPRequestHandler):
    def log_message(self,*args):
        pass
    def do_POST(self):
        state["calls"] += 1
        assert self.path == "/v1/chat/completions"
        assert self.headers["Authorization"] == "Bearer fixture-key-not-real"
        request = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
        assert request["model"] == "fixture-model"
        assert request["messages"][-1]["role"] == "user"
        mode = state["mode"]
        if mode == "timeout": time.sleep(32)
        code = 401 if mode == "auth" else 200
        data = dict(ledger)
        if mode == "ambiguous": data["ambiguous"] = ["未说明谁付款"]
        if mode == "invalid_amount":
            data = json.loads(json.dumps(ledger)); data["payments"][1]["amount_cents"] = 7400
        body = json.dumps({"choices":[{"message":{"content":json.dumps(data,ensure_ascii=False)}}]},ensure_ascii=False).encode()
        if mode == "bad_json": body = b"not-json"
        self.send_response(code)
        self.send_header("Content-Type","application/json; charset=utf-8")
        self.send_header("Content-Length",str(len(body)))
        self.end_headers()
        try: self.wfile.write(body)
        except (BrokenPipeError,ConnectionResetError,ConnectionAbortedError): pass

server = http.server.ThreadingHTTPServer(("127.0.0.1",0),Handler)
threading.Thread(target=server.serve_forever,daemon=True).start()
base = f"http://127.0.0.1:{server.server_port}/v1"
environment = dict(os.environ,MOONBIT_BASE_URL=base,MOONBIT_API_KEY="fixture-key-not-real",MOONBIT_MODEL="fixture-model")
try:
    with tempfile.TemporaryDirectory(prefix="spliteasy-ai-fixture-") as temp:
        file = pathlib.Path(temp)/"free.txt"
        file.write_text("我们是小明、小红、小刚、小美、小李。小明付晚餐200元，五人平摊。小红付奶茶75元，个人分别12、15、18、14、16元。",encoding="utf-8")
        def run(answers):
            return subprocess.run([cli,"split","-f",str(file),"--ai","--json"],input=answers,encoding="utf-8",capture_output=True,env=environment,timeout=45)
        before=state["calls"]
        cancelled=run("no\n")
        assert cancelled.returncode != 0 and not cancelled.stdout and state["calls"]==before
        no_input=run("")
        assert no_input.returncode != 0 and not no_input.stdout and state["calls"]==before
        success=run("yes\nyes\n")
        assert success.returncode == 0,success.stderr
        result=json.loads(success.stdout)
        assert [b["balance_cents"] for b in result["balances"]]==[14800,2000,-5800,-5400,-5600]
        assert result["transfers"][-1]["amount_cents"]==2000
        after=run("yes\nno\n")
        assert after.returncode != 0 and not after.stdout and "取消" in after.stderr
        for mode in ["ambiguous","invalid_amount","bad_json","auth","timeout"]:
            state["mode"]=mode
            failure=run("yes\nyes\n")
            assert failure.returncode != 0 and not failure.stdout,mode
        state["mode"]="success"
        gui_env=dict(environment,SPLITEASY_AI_TEST_BASE_URL=base)
        native=subprocess.run([smoke],capture_output=True,encoding="utf-8",env=gui_env,timeout=90)
        assert native.returncode == 0,native.stdout+native.stderr
        assert "PASS: GUI asynchronous AI fixture" in native.stdout
        print("PASS: loopback AI fixture HTTP + two confirmations + cancellation + errors + GUI async preview")
        print("This is a deterministic local fixture, NOT a real model demonstration.")
finally:
    server.shutdown()
    server.server_close()
