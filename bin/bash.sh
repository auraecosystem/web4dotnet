#!/bin/bash

# Web4 Frontend Asset Inspector
git clone --depth=1 https://github.com/github/copilot.vim.git `
  $HOME/AppData/Local/nvim/pack/github/start/copilot.vim
TARGET_URL="${1:-https://Aexample.com}"

HTML_FILE="web4-frontend.html"

echo "[+] Downloading frontend..."
curl -L -s "$TARGET_URL" -o "$HTML_FILE"

echo "[+] Extracting JavaScript assets..."

grep -ioE 'https?://[^"]+\.js' "$HTML_FILE" | sort -u > web4-js-assets.txt

echo "[+] Checking asset availability..."

while read -r asset; do
    status=$(curl -L -s -o /dev/null -w "%{http_code}" "$asset")
    echo "$status $asset"
done < web4-js-assets.txt > web4-asset-status.txt

echo "[+] Complete"

echo "HTML: $HTML_FILE"
echo "Assets: web4-js-assets.txt"
echo "Status: web4-asset-status.txt"
