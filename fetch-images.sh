#!/usr/bin/env bash

set -e

PAGE_DIR="$1"
MD_FILE="$PAGE_DIR/index.md"

if [[ ! -f "$MD_FILE" ]]; then
  echo "❌ index.md not found in $PAGE_DIR"
  exit 1
fi

echo "📄 Processing: $MD_FILE"

TMP_FILE="$(mktemp)"
cp "$MD_FILE" "$TMP_FILE"

i=1

# پیدا کردن URLهای http/https
grep -Eo 'https?://[^") ]+' "$MD_FILE" | while read -r url; do
  echo "⬇️  Downloading: $url"

  # حذف query string
  clean_url="${url%%\?*}"

  ext="${clean_url##*.}"
  [[ "$ext" == "$clean_url" ]] && ext="jpg"

  filename="image-$i.$ext"
  filepath="$PAGE_DIR/$filename"

  # دانلود
  curl -L --silent --fail "$url" -o "$filepath"

  echo "   ✔ Saved as $filename"

  # جایگزینی URL با نام فایل
  sed -i "s|$url|$filename|g" "$TMP_FILE"

  ((i++))
done

mv "$TMP_FILE" "$MD_FILE"

echo "🎉 Done. Images downloaded and front-matter updated."
