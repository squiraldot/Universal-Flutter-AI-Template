# Testing Strategy

- Unit tests: pure business rules, validation and transformations.
- Provider/controller tests: repository overrides, async state, state transitions and retry behavior.
- Widget tests: UI states, interactions, semantics, localization and accessibility.
- Golden tests: stable visual snapshots for important starter UI; `test/golden_test.dart` demonstrates a deterministic pixel comparison.
- Integration tests: critical journeys, plugin behavior and real app boundaries; `integration_test/app_smoke_test.dart` verifies app startup and the localized home screen on Chrome through the `flutter drive` + ChromeDriver flow.
- Shell tests: initializer safety and coverage-threshold behavior, including below-threshold and invalid-threshold cases.

Test observable outcomes, not private implementation details. Prefer real implementations or fakes; mock external boundaries only when needed. Cover loading, empty, error, retry, offline behavior and denied permissions where relevant. Keep tests independent and descriptive.

Generate localization before analysis/format checks:

```bash
third_party/flutter/bin/flutter pub get
third_party/flutter/bin/flutter gen-l10n
```

Run the repository checks:

```bash
bash -n scripts/bootstrap.sh scripts/init_app.sh scripts/check_coverage.sh scripts/tests/init_app_test.sh scripts/tests/check_coverage_test.sh
bash scripts/tests/init_app_test.sh
bash scripts/tests/check_coverage_test.sh
third_party/flutter/bin/dart format --output=none --set-exit-if-changed lib test
third_party/flutter/bin/flutter analyze
third_party/flutter/bin/flutter test --coverage
bash scripts/check_coverage.sh
# Web integration tests require Chrome and a matching ChromeDriver.
chrome_version="$(google-chrome --version | grep -oE '[0-9]+([.][0-9]+){3}' | head -n 1)"
if [[ -z "$chrome_version" ]]; then
  echo "Could not determine the installed Google Chrome version." >&2
  google-chrome --version >&2 || true
  exit 1
fi
npx --yes @puppeteer/browsers install "chromedriver@$chrome_version" --path "$HOME/.cache/chromedriver"
chromedriver_path="$(find "$HOME/.cache/chromedriver" -type f -name chromedriver -perm -u+x | head -n 1)"
export PATH="$(dirname "$chromedriver_path"):$PATH"
chromedriver --port=4444 &
third_party/flutter/bin/flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_smoke_test.dart -d web-server --browser-name=chrome --web-port=7357
third_party/flutter/bin/flutter build apk --debug --dart-define-from-file=config/development.json
third_party/flutter/bin/flutter build web --release --dart-define-from-file=config/production.json
# macOS + Xcode only:
third_party/flutter/bin/flutter build ios --no-codesign --dart-define-from-file=config/production.json
```

Flutter CI enforces a minimum of 80% Dart line coverage for handwritten library files represented in LCOV. Generated localization code under `lib/l10n/generated/` is excluded because it is tool-generated. Platform build jobs compile Android and Web on Linux and iOS without code signing on macOS.
