#!/usr/bin/env bash
# Builds the app and launches it in an iOS simulator.
# Usage: run-simulator.sh [device name]   (default: "iPhone 17")
set -euo pipefail

cd "$(dirname "$0")/.."

DEVICE="${1:-${SIMULATOR_DEVICE:-iPhone 17}}"
BUNDLE_ID="com.keyboardkabuki.app"

xcodebuild \
  -project App.xcodeproj \
  -scheme App \
  -configuration Debug \
  -destination "platform=iOS Simulator,name=$DEVICE" \
  -derivedDataPath build \
  build

xcrun simctl boot "$DEVICE" 2>/dev/null || true
open -a Simulator
xcrun simctl install "$DEVICE" build/Build/Products/Debug-iphonesimulator/App.app
xcrun simctl launch "$DEVICE" "$BUNDLE_ID"
