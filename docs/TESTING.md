# Testing Strategy

- Unit tests: pure business rules, validation and transformations.
- Widget tests: UI states, interactions, semantics and accessibility.
- Golden tests: stable visual snapshots for important starter UI.
- Integration tests: critical journeys, plugin behavior and real app boundaries.

Test observable outcomes, not private implementation details. Prefer real implementations or fakes; mock external boundaries only when needed. Cover errors, empty data, offline behavior and denied permissions where relevant. Keep tests independent and descriptive; avoid brittle snapshots and timing-based assertions.

Flutter CI runs the full test suite with coverage and enforces a minimum of 80% Dart line coverage for the library files represented in the LCOV report. The threshold can be adjusted locally with `COVERAGE_THRESHOLD`.

```bash
third_party/flutter/bin/dart format --output=none --set-exit-if-changed lib test
third_party/flutter/bin/flutter analyze
third_party/flutter/bin/flutter test --coverage
bash scripts/check_coverage.sh
third_party/flutter/bin/flutter build apk --debug
```
