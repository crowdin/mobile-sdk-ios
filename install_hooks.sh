#!/bin/bash

# Configure git hooks to use the script in the root directory
# Use absolute path from git rev-parse to ensure correctness regardless of where script is run
GIT_ROOT=$(git rev-parse --show-toplevel)
git config core.hooksPath "$GIT_ROOT"

# Make scripts executable
chmod +x "$GIT_ROOT/pre-commit"
chmod +x "$GIT_ROOT/sync_pod_version.sh"
chmod +x "$GIT_ROOT/run_swiftlint.sh"

echo "Git hooks installed successfully."
