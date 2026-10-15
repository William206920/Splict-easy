#!/usr/bin/env python3
"""Run MoonBit's fixed demo, verify independent goldens and lossless integer JSON."""
import argparse
import json
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--target', choices=['native', 'js'], default='native')
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
run = subprocess.run(['moon', 'run', 'examples/report', '--target', args.target], cwd=root, text=True, capture_output=True)
if run.returncode:
    raise RuntimeError(run.stderr)
outputs = json.loads(run.stdout)
assert outputs['dinner_markdown'] == (root/'fixtures/expected_dinner.md').read_text()
assert outputs['mixed_json'] == (root/'fixtures/expected_mixed.json').read_text()
for key, amount in [('max_json', 9223372036854775807), ('large_json', 9007199254740993)]:
    data = json.loads(outputs[key])
    assert data['total_cents'] == amount
    assert type(data['total_cents']) is int
    assert data['balances'][0]['paid_cents'] == amount
    assert data['balances'][1]['balance_cents'] == -amount
    assert data['transfers'][0]['amount_cents'] == amount
    assert data['payments'][0]['shares'][0]['amount_cents'] == amount
special = json.loads(outputs['special_json'])
assert special['balances'][0]['person'] == '<img/src=x/onerror=alert(1)>'
assert special['payments'][0]['date'] == '</p><img/src=x/onerror=alert(2)>'
assert special['payments'][0]['description'] == '茶</h3><script>alert(1)</script>&"\'|\n第二行'
assert json.loads(outputs['controls_encoded']) == ''.join(map(chr,range(32)))+'中文😀<>&\u2028\u2029'
for key in ['dinner_html', 'mixed_html', 'special_html', 'no_transfer_html']:
    assert '<script' not in outputs[key]
    assert '<img/' not in outputs[key]
assert 'role="alert"' in outputs['error_html']
assert '<script>' not in outputs['error_html']
assert '无需转账' in outputs['no_transfer_html']
generated = root/'docs/generated'
generated.mkdir(exist_ok=True)
if args.target == 'native':
    extensions = {'dinner_markdown':'.md','mixed_json':'.json','dinner_html':'.html','mixed_html':'.html','max_json':'.json','large_json':'.json','special_html':'.html','special_markdown':'.md','special_json':'.json','no_transfer_html':'.html','error_html':'.html'}
    for key, ext in extensions.items():
        (generated/(key+ext)).write_text(outputs[key])
    (generated/'outputs-native.json').write_text(json.dumps(outputs,ensure_ascii=False,indent=2)+'\n')
else:
    assert outputs == json.loads((generated/'outputs-native.json').read_text()), 'Native and JS report bytes differ'
result = {'target':args.target,'golden_markdown_exact':True,'golden_json_exact':True,'int64_json_python_roundtrip':True,'all_control_characters_roundtrip':True,'special_text_roundtrip':True,'passed':True}
(generated/('verification-'+args.target+'.json')).write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(result,ensure_ascii=False))
