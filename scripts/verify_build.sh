#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLUTTER="$ROOT_DIR/third_party/flutter/bin/flutter"
cd "$ROOT_DIR"
"$FLUTTER" pub get
"$FLUTTER" analyze
"$FLUTTER" test
"$FLUTTER" build apk --debug
test -f build/app/outputs/flutter-apk/app-debug.apk
echo "Verified debug APK: build/app/outputs/flutter-apk/app-debug.apk"
