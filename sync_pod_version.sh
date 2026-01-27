#!/usr/bin/env bash
set -euo pipefail

# Configuration
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PODSPEC_FILE="$ROOT_DIR/CrowdinSDK.podspec"
SWIFT_VERSION_FILE="$ROOT_DIR/Sources/CrowdinSDK/CrowdinSDK/CrowdinSDK+Version.swift"

# Ensure files exist
if [ ! -f "$PODSPEC_FILE" ]; then
    echo "Error: $PODSPEC_FILE not found."
    exit 1
fi
if [ ! -f "$SWIFT_VERSION_FILE" ]; then
    echo "Error: $SWIFT_VERSION_FILE not found."
    exit 1
fi

# Extract version from Podspec
VERSION=$(sed -n "s/.*spec.version.*= *'\\([^']*\\)'.*/\\1/p" "$PODSPEC_FILE")

if [ -z "$VERSION" ]; then
    echo "Error: Could not extract version from $PODSPEC_FILE"
    exit 1
fi

# Create temp file with expected content
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT
cat <<EOF > "$TEMP_FILE"
//
//  CrowdinSDK+Version.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/16/19.
//

import Foundation

extension CrowdinSDK {
    public static let currentVersion = "$VERSION"
}
EOF

# Ensure compare works against current file
if ! cmp -s "$TEMP_FILE" "$SWIFT_VERSION_FILE"; then
    mv "$TEMP_FILE" "$SWIFT_VERSION_FILE"
    echo "Auto-updated $SWIFT_VERSION_FILE to version $VERSION"
    git add "$SWIFT_VERSION_FILE"
fi
