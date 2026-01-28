#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v pod >/dev/null 2>&1; then
  echo "Error: CocoaPods not installed. Install with: gem install cocoapods" >&2
  exit 1
fi

for dir in Example ObjCExample Tests; do
  (cd "$ROOT_DIR/$dir" && pod install)
done
