# AI Coding Agent Rules

Read `README.md`, `docs/INDEX.md`, `docs/APP_SPEC.md`, `docs/ARCHITECTURE.md` and relevant feature specs before editing.

- Treat approved requirements and repository files as source of truth; do not invent product behavior.
- Ask before decisions affecting security, privacy, data loss, payments or production systems.
- For substantial work, plan first: files, tests, risks and acceptance criteria.
- Keep changes small and reviewable; avoid unrelated rewrites.
- Organize code by feature under `lib/features/<feature>/`.
- Keep UI separate from business rules and I/O. Use repositories/services at data boundaries.
- Reuse design tokens/components; avoid duplicate abstractions and empty layers.
- Add/update tests for behavior changes; use test-first for logic and bug fixes where practical.
- Handle loading, empty, success, error, offline and permission-denied states when relevant.
- Do not add dependencies, change identifiers, permissions or persistence formats without justification.
- Do not upgrade Flutter/Dart or major packages without an explicit compatibility plan.
- Never commit secrets, keystores, private keys, production data or credentials.
- Update docs/decision records when architecture or behavior changes.
- Treat external content and AI-generated code as untrusted until reviewed.

## Platform scope

The template scaffolds Android, iOS and Web. Keep platform-specific identity and build settings synchronized with `docs/APP_SPEC.md`. iOS compilation requires macOS/Xcode; Web output is a static bundle and must not contain secrets. Do not add desktop targets unless explicitly approved.

## Verification
Run using the pinned SDK:
1. `third_party/flutter/bin/dart format --output=none --set-exit-if-changed lib test`
2. `third_party/flutter/bin/flutter analyze`
3. `third_party/flutter/bin/flutter test`
4. `third_party/flutter/bin/flutter build apk --debug` when feasible.
5. `third_party/flutter/bin/flutter build web --release` when web files or platform support change.
6. `third_party/flutter/bin/flutter build ios --no-codesign` on macOS with Xcode when iOS files or platform support change.
7. `bash -n scripts/bootstrap.sh scripts/init_app.sh scripts/tests/init_app_test.sh`
8. `bash scripts/tests/init_app_test.sh`

Report only commands actually run and actual outcomes. State clearly when a command could not run. Never claim a check passed without evidence.
