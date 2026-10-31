#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

coverage_file="$tmp_dir/lcov.info"
cat > "$coverage_file" <<'LCOV'
TN:
SF:lib/sample.dart
DA:1,1
DA:2,1
DA:3,1
DA:4,1
DA:5,0
end_of_record
SF:lib/l10n/generated/app_localizations.dart
DA:1,0
end_of_record
SF:test/sample_test.dart
DA:1,0
end_of_record
LCOV

COVERAGE_THRESHOLD=80 bash "$repo_root/scripts/check_coverage.sh" "$coverage_file"

if COVERAGE_THRESHOLD=81 bash "$repo_root/scripts/check_coverage.sh" "$coverage_file"; then
  echo "Coverage gate unexpectedly passed below the requested threshold." >&2
  exit 1
fi

if COVERAGE_THRESHOLD=101 bash "$repo_root/scripts/check_coverage.sh" "$coverage_file"; then
  echo "Coverage gate unexpectedly accepted an out-of-range threshold." >&2
  exit 1
fi

echo "Coverage gate tests passed."
