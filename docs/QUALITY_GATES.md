# Quality Gates

## Every code change
- Matches approved requirements and existing conventions.
- Formatting passes; no new analyzer errors.
- Relevant unit, widget and golden tests pass.
- Flutter CI enforces at least 80% Dart line coverage for handwritten library files represented in LCOV; generated localization output is excluded. Set `COVERAGE_THRESHOLD` to override the default deliberately.
- The integration smoke test runs in CI on Chrome.
- No secrets or sensitive logs introduced.
- Diff reviewed; docs updated when needed.

## When relevant
- Android build passes after plugin, Gradle, manifest, permission or native changes.
- iOS unsigned build passes on macOS after plugin, Xcode project, plist, permission or native changes.
- Web release build passes after browser, web manifest, HTML, plugin or web-specific changes.
- Persistence migrations include data-loss and rollback review.
- Loading, empty, error, offline and permission-denied states are covered.
- UI checked for small screens, text scaling, dark theme and accessibility.
- Web UI checked for responsive layouts, browser console errors, keyboard access and supported browser behavior.
- Critical journeys have integration tests where practical.

## Release
- Complete [the release checklist](RELEASE_CHECKLIST.md).
- Version/build number and release notes reviewed.
- Android/iOS signing uses protected credentials and platform-specific release configuration.
- Web hosting, SPA fallback and cache behavior reviewed.
- Permissions/privacy disclosures reviewed.
- Release artifacts verified.
