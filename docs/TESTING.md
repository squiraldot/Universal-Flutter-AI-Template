# Testing Strategy

- Unit tests: pure business rules, validation and transformations.
- Widget tests: UI states, interactions, semantics and accessibility.
- Golden tests: stable visual snapshots for important starter UI.
- Integration tests: critical journeys, plugin behavior and real app boundaries.
- Initializer shell tests: fixture-based checks for platform identity changes, validation, dry-run immutability and repeat-run idempotence.

Test observable outcomes, not private implementation details. Prefer real implementations or fakes; mock external boundaries only when needed. Cover errors, empty data, offline behavior and denied permissions where relevant. Keep tests independent and descriptive; avoid brittle snapshots and timing-based assertions.

Flutter CI runs the full test suite with coverage and enforces a minimum of 80% Dart line coverage for the library files represented in the LCOV report. Platform build jobs additionally compile Android and Web on Linux and iOS without code signing on macOS.

```bash
bash -n scripts/bootstrap.sh scripts/init_app.sh scripts/tests/init_app_test.sh
bash scripts/tests/init_app_test.sh
third_party/flutter/bin/dart format --output=none --set-exit-if-changed lib test
third_party/flutter/bin/flutter analyze
third_party/flutter/bin/flutter test --coverage
bash scripts/check_coverage.sh
third_party/flutter/bin/flutter build apk --debug
third_party/flutter/bin/flutter build web --release
# macOS + Xcode only:
third_party/flutter/bin/flutter build ios --no-codesign
```
