# Mac Mouse Fix — Dev Guide (Local Build)

## Những thay đổi đã làm

| File | Thay đổi |
|------|----------|
| `Shared/License/Retrieve/GetLicenseState.swift` | Bypass licensing — luôn trả về `isLicensed: true` |
| `App/UI/Main/Tabs/GeneralTabController.swift` | Bỏ `assert(false)` khi SMAppService lỗi (không crash nữa) |
| `Helper/UNIXSignals.m` | Bỏ `assert` signal handler (cho phép launch từ terminal) |

---

## Lần đầu setup

### 1. Build
```bash
cd /Users/diepmac/Documents/MyCode/mac-mouse-fix

xcodebuild \
  -project "Mouse Fix.xcodeproj" \
  -scheme "Fast Build" \
  -configuration Debug \
  build \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO
```

### 2. Ad-hoc sign (bắt buộc để app xuất hiện trong Accessibility)
```bash
APP="$HOME/Library/Developer/Xcode/DerivedData/Mouse_Fix-gugrpqnjuhnaegczpskkhhviafkf/Build/Products/Debug/Mac Mouse Fix.app"

# Sign Helper trước
codesign --force --deep --sign - \
  "$APP/Contents/Library/LoginItems/Mac Mouse Fix Helper.app"

# Sign main app
codesign --force --deep --sign - "$APP"
```

### 3. Chạy app
```bash
APP="$HOME/Library/Developer/Xcode/DerivedData/Mouse_Fix-gugrpqnjuhnaegczpskkhhviafkf/Build/Products/Debug/Mac Mouse Fix.app"

"$APP/Contents/MacOS/Mac Mouse Fix" &
```

### 4. Cấp quyền Accessibility
- Trong app: bật toggle **"Enable Mac Mouse Fix"**
- macOS sẽ mở System Settings → Privacy & Security → Accessibility
- Tìm **Mac Mouse Fix Helper** → bật ON

---

## Khi sửa code → build lại

```bash
# 1. Kill app cũ
pkill -f "Mac Mouse Fix"

# 2. Build lại
xcodebuild \
  -project "Mouse Fix.xcodeproj" \
  -scheme "Fast Build" \
  -configuration Debug \
  build \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO

# 3. Sign lại
APP="$HOME/Library/Developer/Xcode/DerivedData/Mouse_Fix-gugrpqnjuhnaegczpskkhhviafkf/Build/Products/Debug/Mac Mouse Fix.app"
codesign --force --deep --sign - "$APP/Contents/Library/LoginItems/Mac Mouse Fix Helper.app"
codesign --force --deep --sign - "$APP"

# 4. Chạy lại
"$APP/Contents/MacOS/Mac Mouse Fix" &
```

---

## Script tiện lợi (chạy 1 lệnh)

Lưu đoạn này thành file `run-dev.sh` ở root project:

```bash
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

echo "→ Launching..."
"$APP/Contents/MacOS/Mac Mouse Fix" &

echo "✓ Done"
```

Chạy bằng:
```bash
chmod +x run-dev.sh
./run-dev.sh
```

---

## Lưu ý

- **DerivedData path** chứa hash `Mouse_Fix-gugrpqnjuhnaegczpskkhhviafkf` — nếu bạn xóa DerivedData thì hash thay đổi, cần cập nhật lại path trong script.  
  Tìm path mới bằng: `find ~/Library/Developer/Xcode/DerivedData -name "Mac Mouse Fix.app" -maxdepth 5 2>/dev/null`

- Mỗi lần build lại phải **sign lại** — Xcode overwrite signature khi build.

- Nếu Accessibility không nhận Helper sau khi build lại, vào System Settings → Privacy & Security → Accessibility → tắt rồi bật lại **Mac Mouse Fix Helper**.
