# Testing Strategy

- Unit tests: pure business rules, validation and transformations.
- Widget tests: UI states, interactions, semantics and accessibility.
- Integration tests: critical journeys, plugin behavior and real app boundaries.

Test observable outcomes, not private implementation details. Prefer real implementations or fakes; mock external boundaries only when needed. Cover errors, empty data, offline behavior and denied permissions where relevant. Keep tests independent and descriptive; avoid brittle snapshots and timing-based assertions.

```bash
third_party/flutter/bin/dart format --output=none --set-exit-if-changed lib test
third_party/flutter/bin/flutter analyze
third_party/flutter/bin/flutter test
third_party/flutter/bin/flutter build apk --debug
```
