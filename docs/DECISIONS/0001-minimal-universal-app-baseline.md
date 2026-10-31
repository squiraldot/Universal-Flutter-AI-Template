# ADR 0001: Minimal Universal App Baseline

- **Status:** Proposed
- **Date:** 2026-10-31
- **Branch:** `main`
- **Scope:** Shared application foundation only; no product-specific features.

## Context

The template already has a feature-first directory convention, a minimal Material 3 light/dark theme, a single home screen, Flutter tests, and CI quality gates. It does not yet define shared routing, typed operation outcomes, centralized logging, or environment configuration.

The roadmap identifies these as the next foundation milestones. The baseline should remain app-agnostic, easy to replace, testable, and free of unnecessary dependencies.

## Decision proposal

Adopt native Flutter and Dart capabilities for the first baseline. Do not add a package for routing, state management, logging, environment loading, or result types at this stage.

### 1. Theme tokens

- Keep Material 3 and the existing seed color `0xFF65C466` as the current brand seed; do not invent an app-specific visual identity.
- Centralize semantic colors through `ColorScheme` and typography through `TextTheme`.
- Add a small immutable token surface for spacing and corner radii under `lib/core/theme/`.
- Keep light and dark themes derived from the same semantic token source.
- Feature widgets should use theme values and spacing/radius tokens rather than scattering raw colors and dimensions.
- Do not introduce a design-system package or a large component library.

### 2. Routing

- Use Flutter's built-in Navigator 1.0 and a centralized route registry under `lib/core/routing/`.
- Define route names and route generation in one place; keep `MaterialApp` free of feature-specific navigation decisions.
- The existing home feature remains the initial route.
- Unknown routes resolve to a small app-level not-found screen or safe fallback.
- Keep navigation calls at the presentation boundary. Use typed route arguments where a route needs data.
- Do not add a router package or deep-linking framework until an actual app requirement needs it.

### 3. Error and result contract

- Add a small generic sealed `Result<T>` type using Dart language features, with success and failure variants.
- Add a typed `AppError` carrying a stable error code and safe user-facing message; optionally retain an underlying cause and stack trace for diagnostics.
- Keep technical exception details out of UI messages.
- Convert exceptions at I/O boundaries into typed failures; do not catch and silently discard errors.
- Do not force every synchronous method into `Result`. Use it for operations whose expected failure is part of the contract.
- Avoid a third-party functional-programming or result package.

### 4. Logging

- Provide a small injectable logger interface and a default implementation backed by `dart:developer`.
- Support debug, info, warning, and error events, including optional error and stack trace fields.
- Keep logs structured enough to identify a feature/component and event.
- Never log credentials, tokens, personal data, request/response bodies, or other sensitive payloads.
- Keep logging calls behind the core abstraction so a future telemetry provider can be added without changing features.
- Do not add a logging SDK or remote telemetry by default.

### 5. Environment configuration

- Add an immutable `AppEnvironment` configuration under `lib/core/config/`.
- Read non-secret build-time values using `String.fromEnvironment`, such as environment name and optional API base URL.
- Support explicit development, staging, and production values with a documented safe default.
- Validate configured URLs and reject malformed values early.
- Keep secrets out of the Flutter client and out of compile-time defines; APK contents are inspectable.
- Do not add dotenv packages or environment files containing secrets.

## Proposed feature-first placement

```text
lib/
  app.dart
  main.dart
  core/
    config/
      app_environment.dart
    errors/
      app_error.dart
      result.dart
    logging/
      app_logger.dart
    routing/
      app_routes.dart
      app_router.dart
    theme/
      app_theme.dart
      app_tokens.dart
  features/
    home/
      presentation/
        home_page.dart
```

Only create files needed by the approved implementation. Keep core independent of features; feature modules must not depend on another feature's private implementation.

## Testing proposal

- Theme tests: light/dark themes expose the expected semantic color scheme and typography.
- Routing tests: home route resolves, named navigation works, and unknown routes fail safely.
- Result/error tests: success and failure preserve their values, codes, and safe messages.
- Logging tests: logger forwards levels and diagnostic metadata without exposing sensitive payloads; test the abstraction using a fake sink.
- Environment tests: defaults, supported environment names, optional URL parsing, and invalid URL rejection.
- Retain and update the existing app launch widget test.
- Run repository-mandated format, analyze, test, and debug APK build checks where the pinned SDK is available.

## Alternatives considered

1. **Package-driven baseline:** packages such as a declarative router, state-management framework, and logging SDK. Rejected for now because the current app has one screen and no demonstrated need for these dependencies.
2. **Continue without shared contracts:** keep home-only navigation and ad hoc errors/configuration. Rejected because it leaves the roadmap's reusable foundation undefined.
3. **Native Flutter/Dart baseline (proposed):** uses existing SDK capabilities, keeps dependency count unchanged, and leaves clear extension points.

## Consequences

- No new dependency is required for this baseline.
- The initial architecture stays small and replaceable.
- Navigator 1.0 may need reconsideration if deep links, nested navigation, or complex route state become requirements.
- Compile-time environment values are configuration, not secret storage.
- A future package proposal must state the concrete requirement, alternatives, maintenance/compatibility implications, and tests before adoption.

## Approval gate

This ADR is a proposal, not implementation authorization. Do not add dependencies or implement the baseline until the user explicitly approves this decision. After approval, implement feature-first with tests and keep all work on `main`.
