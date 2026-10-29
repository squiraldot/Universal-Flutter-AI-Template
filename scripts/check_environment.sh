#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLUTTER_BIN="$ROOT_DIR/third_party/flutter/bin/flutter"
[[ -x "$FLUTTER_BIN" ]] || { echo "Flutter submodule missing"; exit 1; }
"$FLUTTER_BIN" --version
"$FLUTTER_BIN" doctor -v
java -version
