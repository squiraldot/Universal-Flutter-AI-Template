#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
FIXTURE="$TMP_DIR/project"
mkdir -p "$FIXTURE/scripts" "$FIXTURE/docs" "$FIXTURE/lib/features/home/presentation" "$FIXTURE/test"
mkdir -p "$FIXTURE/android/app/src/main/kotlin/com/example/universal_app"
mkdir -p "$FIXTURE/ios/Runner.xcodeproj" "$FIXTURE/ios/Runner" "$FIXTURE/web"

cp "$ROOT_DIR/scripts/init_app.sh" "$FIXTURE/scripts/init_app.sh"
bash -n "$FIXTURE/scripts/init_app.sh"
cat > "$FIXTURE/pubspec.yaml" <<'EOF'
name: universal_app
EOF
cat > "$FIXTURE/docs/APP_SPEC.md" <<'EOF'
## Identity
- App name:
- Dart package name:
- Android application ID:
- iOS bundle identifier:
- One-sentence summary: Preserve this placeholder.
EOF
cat > "$FIXTURE/lib/app.dart" <<'EOF'
const title = 'Universal App';
EOF
cat > "$FIXTURE/lib/features/home/presentation/home_page.dart" <<'EOF'
const label = 'Universal App';
EOF
cat > "$FIXTURE/test/widget_test.dart" <<'EOF'
import 'package:universal_app/app.dart';
const expected = 'Universal App';
EOF
cat > "$FIXTURE/android/app/build.gradle.kts" <<'EOF'
android {
    namespace = "com.example.universal_app"
    defaultConfig {
        applicationId = "com.example.universal_app"
    }
}
EOF
cat > "$FIXTURE/android/app/src/main/AndroidManifest.xml" <<'EOF'
<manifest><application android:label="universal_app" /></manifest>
EOF
cat > "$FIXTURE/android/app/src/main/kotlin/com/example/universal_app/MainActivity.kt" <<'EOF'
package com.example.universal_app
class MainActivity
EOF
cat > "$FIXTURE/ios/Runner.xcodeproj/project.pbxproj" <<'EOF'
PRODUCT_BUNDLE_IDENTIFIER = com.example.universal_app;
PRODUCT_BUNDLE_IDENTIFIER = com.example.universal_app;
EOF
cat > "$FIXTURE/ios/Runner/Info.plist" <<'EOF'
<plist><dict><key>CFBundleDisplayName</key><string>universal_app</string></dict></plist>
EOF
cat > "$FIXTURE/web/index.html" <<'EOF'
<html><head><title>universal_app</title></head><body></body></html>
EOF
cat > "$FIXTURE/web/manifest.json" <<'EOF'
{"name":"universal_app","short_name":"universal_app","start_url":"."}
EOF

# Invalid identifiers must fail before changing any file.
if bash "$FIXTURE/scripts/init_app.sh" "Lifebit" "Not-valid" "com.example.lifebit" >/dev/null 2>&1; then
  echo "Expected invalid Dart package name to fail." >&2; exit 1
fi
if bash "$FIXTURE/scripts/init_app.sh" "Lifebit" lifebit "com.Invalid.id" >/dev/null 2>&1; then
  echo "Expected invalid Android application ID to fail." >&2; exit 1
fi
if bash "$FIXTURE/scripts/init_app.sh" --ios-bundle-id "com.Invalid.id" "Lifebit" lifebit com.example.lifebit >/dev/null 2>&1; then
  echo "Expected invalid iOS bundle identifier to fail." >&2; exit 1
fi

# Dry-run must describe changes while leaving the fixture untouched.
bash "$FIXTURE/scripts/init_app.sh" --dry-run --ios-bundle-id com.squiraldot.lifebit "Lifebit" lifebit com.squiraldot.lifebit >/dev/null
grep -q '^name: universal_app$' "$FIXTURE/pubspec.yaml"
grep -q 'universal_app' "$FIXTURE/web/index.html"

# Apply once, then verify Android, iOS, Web and Dart identity surfaces.
bash "$FIXTURE/scripts/init_app.sh" --ios-bundle-id com.squiraldot.lifebit "Lifebit" lifebit com.squiraldot.lifebit >/dev/null
grep -q '^name: lifebit$' "$FIXTURE/pubspec.yaml"
grep -q '^- App name: Lifebit$' "$FIXTURE/docs/APP_SPEC.md"
grep -q '^- Dart package name: lifebit$' "$FIXTURE/docs/APP_SPEC.md"
grep -q '^- Android application ID: com.squiraldot.lifebit$' "$FIXTURE/docs/APP_SPEC.md"
grep -q '^- iOS bundle identifier: com.squiraldot.lifebit$' "$FIXTURE/docs/APP_SPEC.md"
grep -q '^- One-sentence summary: Preserve this placeholder.$' "$FIXTURE/docs/APP_SPEC.md"
grep -q 'package:lifebit/app.dart' "$FIXTURE/test/widget_test.dart"
grep -q 'Lifebit' "$FIXTURE/test/widget_test.dart"
grep -q 'namespace = "com.squiraldot.lifebit"' "$FIXTURE/android/app/build.gradle.kts"
grep -q 'applicationId = "com.squiraldot.lifebit"' "$FIXTURE/android/app/build.gradle.kts"
grep -q 'package com.squiraldot.lifebit' "$FIXTURE/android/app/src/main/kotlin/com/squiraldot/lifebit/MainActivity.kt"
test ! -e "$FIXTURE/android/app/src/main/kotlin/com/example/universal_app/MainActivity.kt"
grep -q 'PRODUCT_BUNDLE_IDENTIFIER = com.squiraldot.lifebit;' "$FIXTURE/ios/Runner.xcodeproj/project.pbxproj"
grep -q '<string>Lifebit</string>' "$FIXTURE/ios/Runner/Info.plist"
grep -q '<title>Lifebit</title>' "$FIXTURE/web/index.html"
python3 - "$FIXTURE/web/manifest.json" <<'PY'
import json, pathlib, sys
data=json.loads(pathlib.Path(sys.argv[1]).read_text())
assert data["name"] == "Lifebit"
assert data["short_name"] == "Lifebit"
PY

# Omitting --ios-bundle-id defaults it to the Android application ID.
# Verify dry-run accepts that shorthand on a fresh fixture copy.
cp -R "$FIXTURE" "$TMP_DIR/default-id"
# Restore platform identity to template values for a separate idempotence check.
before="$(python3 - "$FIXTURE" <<'PY'
import hashlib, pathlib, sys
root = pathlib.Path(sys.argv[1])
print("\n".join(f"{p.relative_to(root)}:{hashlib.sha256(p.read_bytes()).hexdigest()}" for p in sorted(root.rglob("*")) if p.is_file()))
PY
)"
bash "$FIXTURE/scripts/init_app.sh" --ios-bundle-id com.squiraldot.lifebit "Lifebit" lifebit com.squiraldot.lifebit >/dev/null
after="$(python3 - "$FIXTURE" <<'PY'
import hashlib, pathlib, sys
root = pathlib.Path(sys.argv[1])
print("\n".join(f"{p.relative_to(root)}:{hashlib.sha256(p.read_bytes()).hexdigest()}" for p in sorted(root.rglob("*")) if p.is_file()))
PY
)"
test "$before" = "$after"

echo "init_app.sh tests passed (validation, dry-run, Android/iOS/Web identity, package move, idempotence)."
