# Testing Strategy

- Unit tests: pure business rules, validation and transformations.
- Provider/controller tests: repository overrides, async state, state transitions and retry behavior.
- Widget tests: UI states, interactions, semantics, localization and accessibility.
- Golden tests: stable visual snapshots for important starter UI.
- Integration tests: critical journeys, plugin behavior and real app boundaries.
- Initializer shell tests: fixture-based checks for platform identity changes, validation, dry-run immutability and repeat-run idempotence.

Test observable outcomes, not private implementation details. Prefer real implementations or fakes; mock external boundaries only when needed. Cover loading, empty, error, retry, offline behavior and denied permissions where relevant. Keep tests independent and descriptive.

Generate localization before analysis/format checks:

```bash
third_party/flutter/bin/flutter pub get
third_party/flutter/bin/flutter gen-l10n
```

Run the repository checks:

```bash
bash -n scripts/bootstrap.sh scripts/init_app.sh scripts/tests/init_app_test.sh
bash scripts/tests/init_app_test.sh
third_party/flutter/bin/dart format --output=none --set-exit-if-changed lib test
third_party/flutter/bin/flutter analyze
third_party/flutter/bin/flutter test --coverage
bash scripts/check_coverage.sh
third_party/flutter/bin/flutter build apk --debug --dart-define-from-file=config/development.json
third_party/flutter/bin/flutter build web --release --dart-define-from-file=config/production.json
# macOS + Xcode only:
third_party/flutter/bin/flutter build ios --no-codesign --dart-define-from-file=config/production.json
```

Flutter CI enforces a minimum of 80% Dart line coverage for handwritten library files represented in LCOV. Generated localization code under `lib/l10n/generated/` is excluded because it is tool-generated. Platform build jobs compile Android and Web on Linux and iOS without code signing on macOS.
