#!/bin/bash
# Сборка офлайн веб-версии (PWA) в build/web.
# Использование: tool/build_pwa.sh [--base-href /путь/]
set -euo pipefail
cd "$(dirname "$0")/.."

flutter build web --release --no-web-resources-cdn "$@"

cd build/web
rm -f flutter_service_worker.js
# Не нужны в JS-сборке: отладочные символы и движок skwasm (только для --wasm).
find canvaskit -name '*.symbols' -delete
find canvaskit -name 'skwasm*' -delete

# Список файлов для офлайн-кеша (кроме самого sw.js).
files=$(find . -type f ! -name sw.js ! -name '.last_build_id' | sed 's|^\./||' | sort)
version=$(echo "$files" | xargs cat | shasum | cut -c1-12)
json=$( (echo "./"; echo "$files") | python3 -c 'import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))')

python3 - "$version" "$json" <<'PY'
import sys
version, files = sys.argv[1], sys.argv[2]
s = open('sw.js').read()
s = s.replace("'__VERSION__'", repr(version)).replace('__FILES__', files)
open('sw.js', 'w').write(s)
PY
echo "PWA готова: build/web (версия $version, файлов: $(echo "$files" | wc -l | tr -d ' '))"
