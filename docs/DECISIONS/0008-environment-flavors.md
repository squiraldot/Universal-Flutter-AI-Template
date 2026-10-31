# ADR 0008: Build Environments and Flavors

- **Status:** Accepted
- **Date:** 2026-10-31
- **Branch:** `main`
- **Scope:** Development, staging and production configuration for Android, iOS and Web builds.

## Context

The repository already parses public `APP_ENV` and optional `API_BASE_URL` values through `String.fromEnvironment`. The requested workflow needs repeatable environment selection using Flutter's `--dart-define-from-file` flag without placing secrets in source-controlled files or client bundles.

## Options

1. **Inline `--dart-define` arguments.** No config files and explicit per-command values, but commands become long and CI/local invocations can drift.
2. **Tracked JSON define files passed with `--dart-define-from-file`.** Short, repeatable commands and reviewable environment-specific public configuration. Values are compiled into the client and are not secret; careless files can leak credentials.
3. **dotenv or runtime-loaded environment files.** Familiar local workflow and runtime flexibility, but adds package/build complexity and still cannot protect secrets shipped to a client.

## Recommendation

Use **tracked, non-secret JSON define files** for development, staging and production, passed explicitly with `--dart-define-from-file`. Proposed paths: `config/development.json`, `config/staging.json` and `config/production.json`. Each file must set `APP_ENV` to its matching supported value and may include a public `API_BASE_URL` when the target app supplies a real endpoint. Do not invent placeholder production endpoints.

Build examples:

```bash
third_party/flutter/bin/flutter run --dart-define-from-file=config/development.json
third_party/flutter/bin/flutter build apk --release --dart-define-from-file=config/staging.json
third_party/flutter/bin/flutter build web --release --dart-define-from-file=config/production.json
```

The exact platform build matrix and flavor naming (including Android productFlavors/iOS schemes) should be added only if platform-specific identifiers, icons, signing or store tracks genuinely need to differ. Dart compile-time environments alone do not create native Android/iOS flavors.

## Security constraints

- JSON define files are public source and compiled client configuration. Never place API keys, passwords, tokens, signing material, private endpoints requiring authentication or personal data in them.
- Keep privileged credentials on a trusted backend; use CI secret stores only for server-side build/signing operations that truly require them.
- Do not add secret-bearing local override files to Git. If local overrides are later needed, document a safe ignored-file workflow and validate it.
- Validate `APP_ENV` and URLs at startup; production must not silently fall back to development.

## Consequences

- Add tests for each environment file's values, invalid/missing environment handling and URL validation.
- Document exact local and CI build commands; ensure workflows select the intended file explicitly.
- Verify that no secrets are present in tracked JSON files, generated artifacts or logs.
- This decision configures Dart compile-time environments; it does not by itself provision backend infrastructure or signing credentials.

## Approval and implementation

Approved by the user on 2026-10-31. This decision is implemented in the shared app foundation and sample feature.
