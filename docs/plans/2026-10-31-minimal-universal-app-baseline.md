# Minimal Universal App Baseline Implementation Plan

> **For agentic workers:** Use the host's available task-by-task implementation workflow. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the approved ADR 0001 baseline using existing Flutter/Dart SDK capabilities, feature-first organization, and focused tests.

**Architecture:** Keep reusable cross-cutting contracts in `lib/core/` and the existing home screen in `lib/features/home/`. Use Material 3, Navigator 1.0, Dart sealed classes, `dart:developer`, and compile-time environment defines; add no package dependencies.

**Tech Stack:** Flutter 3.47.8 (CI-pinned), Dart SDK constraint `>=3.13.0 <4.0.0`, Flutter Material, `flutter_test`.

## Global Constraints

- Perform all repository changes directly on `main`; do not create or switch branches.
- Do not add, remove, or upgrade dependencies; do not edit `pubspec.yaml` or introduce a lockfile.
- Preserve the current home screen copy and app-agnostic product behavior.
- Keep core independent of features; keep feature implementation private to its module.
- Never log credentials, tokens, personal information, prompts, or request/response bodies.
- Treat compile-time environment values as public configuration, never as secret storage.
- Follow `AGENTS.md` verification commands and report only checks actually run.
- No app-specific state management, persistence, deep-linking, telemetry, or provider integration is in scope.

---

### Task 1: Shared theme tokens

**Files:**
- Create: `lib/core/theme/app_tokens.dart`
- Modify: `lib/core/theme/app_theme.dart`
- Modify: `lib/features/home/presentation/home_page.dart` to consume spacing tokens
- Create: `test/core/theme/app_theme_test.dart`

**Interfaces:**
- `abstract final class AppSpacing` exposes immutable named spacing constants (4, 8, 12, 16, 24, 32 logical pixels).
- `abstract final class AppRadii` exposes immutable named radius constants (4, 8, 12, 16 logical pixels).
- `AppTheme.light()` and `AppTheme.dark()` remain the public theme factories and continue using the existing green seed `0xFF65C466`.

- [x] **Step 1: Add focused tests** for Material 3 enabled, matching seed-derived primary color across brightnesses, and non-null shared typography/color schemes.
- [ ] **Step 2: Verify RED** by running `third_party/flutter/bin/flutter test test/core/theme/app_theme_test.dart`; the token import/expectations should fail before implementation.
- [x] **Step 3: Implement** immutable spacing/radius tokens and refactor theme construction to share the seed and typography configuration while retaining brightness-specific ColorSchemes.
- [ ] **Step 4: Verify GREEN** with the focused test command.
- [ ] **Step 5: Run integration check** using `third_party/flutter/bin/flutter test`; existing home launch behavior remains unchanged.
- [ ] **Step 6: Commit** the passing task as `feat(theme): add shared app design tokens`.

### Task 2: Typed errors and operation results

**Files:**
- Create: `lib/core/errors/app_error.dart`
- Create: `lib/core/errors/result.dart`
- Create: `test/core/errors/result_test.dart`

**Interfaces:**
- `final class AppError` has required `code` and safe `message`, plus optional `cause` and `stackTrace`.
- `sealed class Result<T>` has `Success<T>(T value)` and `Failure<T>(AppError error)`.
- Result variants expose their payloads; no exception-catching helper or forced conversion of all functions is added.

- [x] **Step 1: Add focused tests** for success retaining its value, failure retaining its typed error, and AppError retaining code/message/optional diagnostics.
- [ ] **Step 2: Verify RED** with `third_party/flutter/bin/flutter test test/core/errors/result_test.dart`; tests should fail because the types do not exist.
- [x] **Step 3: Implement** the minimal sealed hierarchy and immutable error value object. Technical cause/stack trace remain diagnostic-only and are not included in the safe message by default.
- [ ] **Step 4: Verify GREEN** with the focused test command.
- [ ] **Step 5: Run integration check** using `third_party/flutter/bin/flutter analyze` and `third_party/flutter/bin/flutter test`.
- [ ] **Step 6: Commit** the passing task as `feat(core): add typed result and app errors`.

### Task 3: Privacy-conscious logging abstraction

**Files:**
- Create: `lib/core/logging/app_logger.dart`
- Create: `test/core/logging/app_logger_test.dart`

**Interfaces:**
- `abstract interface class AppLogger` exposes `debug`, `info`, `warning`, and `error` methods with a message and optional component/scope; error also accepts optional error and stack trace.
- `DeveloperAppLogger` implements the interface with `dart:developer` and accepts an injectable sink for deterministic tests.
- The logging contract has no arbitrary context-map or payload parameter.

- [x] **Step 1: Add focused tests** using a fake sink to assert each level, scope, error object, and stack trace are forwarded with the expected diagnostic level.
- [ ] **Step 2: Verify RED** with `third_party/flutter/bin/flutter test test/core/logging/app_logger_test.dart`.
- [x] **Step 3: Implement** the interface and default developer-log adapter. Keep sensitive data out of the API and document that callers must not embed sensitive values in messages.
- [ ] **Step 4: Verify GREEN** with the focused test command.
- [ ] **Step 5: Run integration check** using `third_party/flutter/bin/flutter analyze` and `third_party/flutter/bin/flutter test`.
- [ ] **Step 6: Commit** the passing task as `feat(core): add privacy-conscious logging`.

### Task 4: Validated build-time environment configuration

**Files:**
- Create: `lib/core/config/app_environment.dart`
- Create: `test/core/config/app_environment_test.dart`
- Modify: `docs/SECURITY.md` only if the implementation needs to document the exact public define names.

**Interfaces:**
- `enum AppEnvironmentName { development, staging, production }`.
- Immutable `AppEnvironment` exposes `name` and nullable `apiBaseUrl` (`Uri`).
- `AppEnvironment.fromBuildDefines()` reads `APP_ENV` (default `development`) and optional `API_BASE_URL` using `String.fromEnvironment`.
- `AppEnvironment.fromValues({required String name, String? apiBaseUrl})` is a deterministic testable constructor. Unsupported environment names and malformed/non-absolute/non-HTTP(S) URLs throw `FormatException`.

- [x] **Step 1: Add focused tests** for development default, all three supported names, absent API URL, valid HTTP/HTTPS absolute URL, and rejection of unsupported names, malformed URLs, relative URLs, and unsupported schemes.
- [ ] **Step 2: Verify RED** with `third_party/flutter/bin/flutter test test/core/config/app_environment_test.dart`.
- [x] **Step 3: Implement** immutable parsing/validation and compile-time define loading. No dotenv, file reads, secrets, or network calls.
- [ ] **Step 4: Verify GREEN** with the focused test command.
- [ ] **Step 5: Run integration check** using `third_party/flutter/bin/flutter analyze` and `third_party/flutter/bin/flutter test`.
- [ ] **Step 6: Commit** the passing task as `feat(config): add validated app environment`.

### Task 5: Centralized routing and app-shell integration

**Files:**
- Create: `lib/core/routing/app_routes.dart`
- Create: `lib/core/routing/app_router.dart`
- Create: `lib/core/routing/unknown_route_page.dart`
- Modify: `lib/app.dart`
- Create: `test/core/routing/app_router_test.dart`

**Interfaces:**
- `abstract final class AppRoutes` exposes the home path `/` and not-found path `/not-found`.
- `abstract final class AppRouter` exposes a route factory compatible with `MaterialApp.onGenerateRoute`.
- The home route builds the existing `HomePage`; unknown names return a safe not-found page with a way back to home.
- `UniversalApp` uses `initialRoute: AppRoutes.home`, centralized route generation, and `onUnknownRoute` as a final safe fallback. Existing title, theme mode, light/dark themes, and home copy are preserved.

- [x] **Step 1: Add focused tests** for home initial route, named not-found route, arbitrary unknown route fallback, and tapping the not-found action returning to home.
- [ ] **Step 2: Verify RED** with `third_party/flutter/bin/flutter test test/core/routing/app_router_test.dart` and the updated widget test.
- [x] **Step 3: Implement** route registry, route generation, not-found UI, and app-shell wiring. Avoid deep-link parsing or route packages.
- [ ] **Step 4: Verify GREEN** with the focused routing and widget tests.
- [ ] **Step 5: Run integration checks**:
  - `third_party/flutter/bin/dart format --output=none --set-exit-if-changed lib test`
  - `third_party/flutter/bin/flutter analyze`
  - `third_party/flutter/bin/flutter test`
  - `third_party/flutter/bin/flutter build apk --debug` when the pinned SDK and Android toolchain are available.
- [ ] **Step 6: Commit** the passing task as `feat(routing): centralize app navigation`.

## Unresolved product decisions

None block this approved baseline. Deep links, nested navigation, a state-management framework, remote logging/telemetry, secrets management, and app-specific configuration remain out of scope and require separate evidence and approval before adoption.


## Execution record

- Tests were authored before their corresponding implementation files.
- The approved baseline source and focused tests have been added directly to `main`; no dependency manifest was changed.
- Focused tests, formatting, analysis, and APK build remain unverified in this session: the repository checkout could not be cloned because the execution environment could not resolve `github.com`, and no local Flutter/Dart executable is installed. Re-run the commands above in the repository or rely on the repository CI result before treating the baseline as verified.
