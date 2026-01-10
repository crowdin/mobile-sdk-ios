#!/bin/bash

# Check if version argument is provided
if [ -z "$1" ]; then
    echo "Usage: ./bump_version.sh <new_version>"
    exit 1
fi

NEW_VERSION=$1
PODSPEC_FILE="CrowdinSDK.podspec"
SWIFT_VERSION_FILE="Sources/CrowdinSDK/CrowdinSDK/CrowdinSDK+Version.swift"

# Update CrowdinSDK.podspec
# Using sed to find the line starting with spec.version and replace the version
sed -i '' "s/spec.version *= *'.*'/spec.version          = '$NEW_VERSION'/g" "$PODSPEC_FILE"

# Update CrowdinSDK+Version.swift
# Using sed to find the line starting with public static let version and replace the version
sed -i '' "s/public static let currentVersion = \".*\"/public static let currentVersion = \"$NEW_VERSION\"/g" "$SWIFT_VERSION_FILE"

echo "Successfully updated version to $NEW_VERSION in:"
echo "- $PODSPEC_FILE"
echo "- $SWIFT_VERSION_FILE"
