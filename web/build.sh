#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"
# Remove the published copy first so a failed build cannot leave a stale success.
rm -f web/spliteasy.js
moon build --target js --release
artifact="_build/js/release/build/web/web.js"
if [[ ! -s "$artifact" ]]; then
  echo "未找到 MoonBit JS 产物：$artifact" >&2
  exit 1
fi
cp "$artifact" web/spliteasy.js
echo "已生成 web/spliteasy.js"
