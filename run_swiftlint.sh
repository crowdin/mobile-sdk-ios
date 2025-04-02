#!/bin/bash

# Check if SwiftLint is installed
if which swiftlint >/dev/null; then
  echo "SwiftLint is installed, running on Sources directory..."
else
  echo "SwiftLint not installed, you can install it using:"
  echo "brew install swiftlint"
  echo "or"
  echo "mint install realm/SwiftLint"
  exit 1
fi

# Run SwiftLint only on the Sources directory
swiftlint --config .swiftlint.yml Sources/CrowdinSDK
