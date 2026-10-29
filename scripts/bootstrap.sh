#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLUTTER_BIN="$ROOT_DIR/third_party/flutter/bin/flutter"

if [[ ! -x "$FLUTTER_BIN" ]]; then
  echo "Flutter submodule missing. Run: git submodule update --init --recursive"
  exit 1
fi

"$FLUTTER_BIN" --version

# Generate the Android scaffold in a temporary project so existing app Dart files
# and pubspec.yaml are not overwritten by flutter create.
if [[ ! -d "$ROOT_DIR/android" ]]; then
  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT
  "$FLUTTER_BIN" create --platforms=android --project-name universal_app --org com.example "$TMP_DIR/scaffold"
  cp -R "$TMP_DIR/scaffold/android" "$ROOT_DIR/android"
  if [[ ! -f "$ROOT_DIR/.metadata" && -f "$TMP_DIR/scaffold/.metadata" ]]; then
    cp "$TMP_DIR/scaffold/.metadata" "$ROOT_DIR/.metadata"
  fi
fi

(cd "$ROOT_DIR" && "$FLUTTER_BIN" pub get)
echo "Bootstrap complete. Review generated Android files and commit them for a stable project scaffold."
