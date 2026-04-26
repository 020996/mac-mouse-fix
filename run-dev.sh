#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP="$HOME/Library/Developer/Xcode/DerivedData/Mouse_Fix-gugrpqnjuhnaegczpskkhhviafkf/Build/Products/Debug/Mac Mouse Fix.app"

echo "→ Killing old processes..."
pkill -f "Mac Mouse Fix" 2>/dev/null || true
sleep 1

echo "→ Building..."
xcodebuild \
  -project "$PROJECT_DIR/Mouse Fix.xcodeproj" \
  -scheme "Fast Build" \
  -configuration Debug \
  build \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  | grep -E "error:|BUILD SUCCEEDED|BUILD FAILED"

echo "→ Signing..."
codesign --force --deep --sign - "$APP/Contents/Library/LoginItems/Mac Mouse Fix Helper.app"
codesign --force --deep --sign - "$APP"

echo "→ Copying to /Applications..."
cp -R "$APP" "/Applications/Mac Mouse Fix.app"

echo "→ Launching..."
open "/Applications/Mac Mouse Fix.app"

echo "✓ Done — app is running from /Applications"
