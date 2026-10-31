#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Prefer the repository-pinned SDK for local development; CI may provide Flutter
# through subosito/flutter-action and PATH instead.
FLUTTER_BIN="$ROOT_DIR/third_party/flutter/bin/flutter"
if [[ ! -x "$FLUTTER_BIN" ]]; then
  FLUTTER_BIN="$(command -v flutter || true)"
fi
if [[ -z "$FLUTTER_BIN" || ! -x "$FLUTTER_BIN" ]]; then
  echo "Flutter SDK not found. Install Flutter or initialize third_party/flutter."
  exit 1
fi

"$FLUTTER_BIN" --version

# Generate platform scaffolds in a temporary project so existing app Dart files
# and pubspec.yaml are never overwritten by flutter create.
PLATFORMS=(android ios web)
NEEDS_SCAFFOLD=false
for platform in "${PLATFORMS[@]}"; do
  if [[ ! -d "$ROOT_DIR/$platform" ]]; then
    NEEDS_SCAFFOLD=true
  fi
done

if [[ "$NEEDS_SCAFFOLD" == true ]]; then
  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT
  "$FLUTTER_BIN" create --platforms=android,ios,web --project-name universal_app --org com.example "$TMP_DIR/scaffold"
  for platform in "${PLATFORMS[@]}"; do
    if [[ ! -d "$ROOT_DIR/$platform" ]]; then
      cp -R "$TMP_DIR/scaffold/$platform" "$ROOT_DIR/$platform"
      echo "Generated $platform scaffold."
    fi
  done
  if [[ ! -f "$ROOT_DIR/.metadata" && -f "$TMP_DIR/scaffold/.metadata" ]]; then
    cp "$TMP_DIR/scaffold/.metadata" "$ROOT_DIR/.metadata"
  fi
fi

(cd "$ROOT_DIR" && "$FLUTTER_BIN" pub get)
echo "Bootstrap complete. Review generated Android, iOS and Web files and commit them for a stable project scaffold."
