#!/bin/bash
# Сборка офлайн-версии и публикация на GitHub Pages.
# Использование: tool/deploy_pages.sh
# Сайт: https://<логин>.github.io/<репозиторий>/ (ветка gh-pages).
set -euo pipefail
cd "$(dirname "$0")/.."

remote=$(git remote get-url origin)
repo=$(basename -s .git "$remote")

tool/build_pwa.sh --base-href "/$repo/"

# Публикуем только готовую сборку отдельным коммитом в ветку gh-pages.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cp -R build/web/. "$tmp"
touch "$tmp/.nojekyll"
git -C "$tmp" init -q -b gh-pages
git -C "$tmp" add -A
git -C "$tmp" commit -q -m "Публикация $(date '+%Y-%m-%d %H:%M')"
git -C "$tmp" push -q -f "$remote" gh-pages
echo "Опубликовано: ветка gh-pages в $remote"
