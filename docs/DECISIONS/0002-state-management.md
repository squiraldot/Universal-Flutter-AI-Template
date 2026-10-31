# ADR 0002: State Management

- **Status:** Proposed — awaiting user approval
- **Date:** 2026-10-31
- **Branch:** `main`
- **Scope:** Shared state-management convention for future features.

## Context

The template is app-agnostic and currently has a small starter screen. It should support testable feature state without forcing every widget or simple interaction through a framework. The current dependency set does not include a state-management package.

## Options

1. **Flutter primitives (`setState`, `ValueNotifier`, `ChangeNotifier`).** No dependency, low learning cost and appropriate for local/limited state. Larger cross-screen state and lifecycle ownership need conventions and can become manual.
2. **Riverpod.** Compile-time-friendly provider composition, scoped state, async loading/error handling and test overrides. Adds a dependency and a framework concept that contributors must learn; avoid mixing Riverpod generations or legacy provider APIs.
3. **BLoC/Cubit.** Explicit event/state or method/state contracts and strong separation for complex workflows. More boilerplate and dependencies than this neutral starter currently justifies.

## Recommendation

Adopt **Riverpod 3.x** for shared feature/application state, subject to compatibility verification against the pinned Flutter/Dart SDK before adding packages. Keep ephemeral widget-only state in Flutter primitives. Put providers beside the feature that owns them; expose only intentional shared contracts. Do not add code generation initially.

This balances testability and async state handling with a feature-first architecture. If the first sample feature needs only local state, keep that local and demonstrate the provider pattern only where it adds value.

## Consequences

- Add the selected Riverpod package(s) only after approval and verify the exact compatible release.
- Test providers with overrides/container isolation; widget tests should assert observable states.
- Do not introduce GetX, Provider, BLoC or a second state framework alongside the selected convention without a new ADR.
- State management is not a persistence solution; storage remains behind repository/service boundaries.

## Approval gate

This is a proposal only. Do not add dependencies or implement state management until the user explicitly approves this ADR.
