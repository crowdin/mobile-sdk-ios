#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SWIFTLINT_CONFIG="$ROOT_DIR/.swiftlint.yml"
SWIFTLINT_TARGET="$ROOT_DIR/Sources/CrowdinSDK"

# Check if SwiftLint is installed
if ! command -v swiftlint >/dev/null 2>&1; then
  cat <<'EOF' >&2
SwiftLint not installed. Install with:
  brew install swiftlint
or
  mint install realm/SwiftLint
EOF
  exit 1
fi

if [ ! -f "$SWIFTLINT_CONFIG" ]; then
  echo "SwiftLint config not found at $SWIFTLINT_CONFIG" >&2
  exit 1
fi

# Run SwiftLint only on the Sources directory
swiftlint --config "$SWIFTLINT_CONFIG" "$SWIFTLINT_TARGET"
