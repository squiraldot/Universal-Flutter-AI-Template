#!/usr/bin/env bash
set -euo pipefail

coverage_file="${1:-coverage/lcov.info}"
required_coverage="${COVERAGE_THRESHOLD:-80}"

if [[ ! -f "$coverage_file" ]]; then
  echo "Coverage report not found: $coverage_file" >&2
  exit 2
fi

if ! awk -v required="$required_coverage" 'BEGIN {
  if (required !~ /^[0-9]+([.][0-9]+)?$/ || required < 0 || required > 100) {
    exit 1
  }
}'; then
  echo "COVERAGE_THRESHOLD must be a number between 0 and 100 (received: $required_coverage)." >&2
  exit 2
fi

awk -v required="$required_coverage" '
  /^SF:/ {
    source_path = substr($0, 4)
    in_library = source_path ~ /(^|\/)lib\// && source_path !~ /(^|\/)lib\/l10n\/generated\//
    next
  }

  /^DA:/ && in_library {
    split(substr($0, 4), fields, ",")
    total_lines++
    if ((fields[2] + 0) > 0) {
      covered_lines++
    }
  }

  /^end_of_record/ {
    in_library = 0
  }

  END {
    if (total_lines == 0) {
      print "No handwritten lib/ line coverage records found." > "/dev/stderr"
      exit 2
    }

    percentage = covered_lines * 100 / total_lines
    printf "Dart line coverage: %.2f%% (%d/%d); required: %.2f%%\n", \
      percentage, covered_lines, total_lines, required

    if (percentage + 0.000001 < required) {
      print "Coverage is below the configured threshold." > "/dev/stderr"
      exit 1
    }
  }
' "$coverage_file"
