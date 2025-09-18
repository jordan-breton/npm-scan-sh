#!/usr/bin/env bash
set -euo pipefail

# ===== INPUT (CSV from stdin or file) =====
TMP_FILE=$(mktemp)

if [ -t 0 ]; then
  CSV_FILE="compromised.csv"
  if [ ! -f "$CSV_FILE" ]; then
    echo "Usage:"
    echo "  cat compromised.csv | $0 [path]"
    echo "  or place compromised.csv in the current directory."
    exit 1
  fi
  INPUT=$(cat "$CSV_FILE")
else
  INPUT=$(cat)
fi

# Normalize into "pkg;version" per line
while IFS= read -r line; do
  [ -z "$line" ] && continue
  pkg=$(echo "$line" | cut -d';' -f1)
  versions=$(echo "$line" | cut -d';' -f2 | tr ',' ' ')
  for v in $versions; do
    echo "$pkg;${v}" | xargs >> "$TMP_FILE"
  done
done <<< "$INPUT"

# ===== TARGET DIRECTORY =====
TARGET_DIR="${1:-.}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: $TARGET_DIR is not a directory"
  exit 1
fi

echo "🔍 Scanning for compromised packages under $TARGET_DIR ..."
echo

# ===== SCAN NODE_MODULES =====
find "$TARGET_DIR" -type f -path "*/node_modules/*/package.json" | while read -r pkgfile; do
  name=$(jq -r '.name' "$pkgfile" 2>/dev/null || echo "")
  version=$(jq -r '.version' "$pkgfile" 2>/dev/null || echo "")

  if [ -z "$name" ] || [ -z "$version" ]; then
    continue
  fi

  if grep -q "^${name};${version}$" "$TMP_FILE"; then
    echo "⚠️  Compromised package found: $name@$version"
    echo "   Location: $pkgfile"
    echo
  fi
done

rm -f "$TMP_FILE"
echo "✅ Scan completed."
