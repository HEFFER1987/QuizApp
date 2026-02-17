#!/bin/bash
set -e

# 1. Generate code SwiftGen
if which swiftgen >/dev/null; then
  swiftgen config run --config swiftgen.yml
else
  echo "error: SwiftGen not installed. Run 'brew install swiftgen'"
  exit 1
fi

# 2. Generate Xcode-project
if which xcodegen >/dev/null; then
  xcodegen generate
else
  echo "error: XcodeGen not installed. Run 'brew install xcodegen'"
  exit 1
fi
