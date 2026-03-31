#!/usr/bin/env bash
set -euo pipefail

MANIFEST=$(curl -sSf "https://static.devin.ai/cli/current/manifest.json")
VERSION=$(echo "$MANIFEST" | jq -r .version)

if [ -f "versions/${VERSION}.json" ]; then
  echo "Already tracked: ${VERSION}"
  exit 0
fi

echo "New version: ${VERSION}"

declare -A PLATFORM_MAP=(
  ["aarch64-apple-darwin"]="aarch64-darwin"
  ["x86_64-apple-darwin"]="x86_64-darwin"
  ["aarch64-unknown-linux"]="aarch64-linux"
  ["x86_64-unknown-linux"]="x86_64-linux"
)

TMPFILE=$(mktemp)
echo "{\"version\": \"${VERSION}\", \"platforms\": {" > "$TMPFILE"
first=true
for devin_plat in "${!PLATFORM_MAP[@]}"; do
  nix_plat="${PLATFORM_MAP[$devin_plat]}"
  url=$(echo "$MANIFEST" | jq -r ".platforms[\"${devin_plat}\"].url")
  sha256hex=$(echo "$MANIFEST" | jq -r ".platforms[\"${devin_plat}\"].sha256")
  sri=$(nix hash convert --hash-algo sha256 --to sri "$sha256hex")
  $first || echo "," >> "$TMPFILE"
  printf '"%s": {"url": "%s", "hash": "%s"}' "$nix_plat" "$url" "$sri" >> "$TMPFILE"
  first=false
done
echo "}}" >> "$TMPFILE"

jq . "$TMPFILE" > "versions/${VERSION}.json"
rm "$TMPFILE"
echo "Created versions/${VERSION}.json"
