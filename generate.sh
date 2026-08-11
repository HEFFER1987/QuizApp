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

# 3. Configure build server for SourceKit-LSP (Cursor / VS Code)
if which xcode-build-server >/dev/null; then
  xcode-build-server config -project QuizApp.xcodeproj -scheme QuizApp-iOS
else
  echo "warning: xcode-build-server not installed. Install with 'brew install xcode-build-server' so Cursor resolves XCTest in test targets."
fi
