# ADR 0004: Dependency Injection

- **Status:** Accepted
- **Date:** 2026-10-31
- **Branch:** `main`
- **Scope:** Construction and lifecycle of application services, repositories and feature dependencies.

## Context

The template needs replaceable dependencies for tests and platform-specific implementations. State management is also proposed separately; choosing overlapping service-locator and provider systems would create two sources of truth.

## Options

1. **Constructor injection/manual composition.** Explicit dependencies and no package. Excellent for small graphs, but app-wide scopes and large object graphs require manual wiring.
2. **Riverpod providers as the composition mechanism.** Lazy construction, lifecycle management, overrides for tests and reuse of the proposed state-management framework. Couples construction to Riverpod and should not become a global service locator.
3. **get_it (optionally with injectable code generation).** Familiar service locator and convenient global lookup. Adds a separate dependency/lifecycle model, can hide dependencies and overlaps with Riverpod if both are adopted.

## Recommendation

Use **constructor injection at feature boundaries and Riverpod providers as the composition root** if ADR 0002 is approved. Do not add get_it or injectable. Keep constructors explicit for plain Dart classes; use providers to assemble repositories, services and platform adapters. Keep core contracts independent of concrete feature UI.

If ADR 0002 is not approved, revisit this recommendation rather than introducing Riverpod solely for DI.

## Consequences

- Dependencies remain replaceable in unit/widget tests through constructor arguments and provider overrides.
- Avoid reading providers from arbitrary global locations; pass dependencies through the owning feature's composition.
- Keep lifecycle-sensitive resources (clients, controllers, streams) explicitly disposed.
- Do not create abstractions for dependencies that have no real boundary or test value.

## Approval and implementation

Approved by the user on 2026-10-31. This decision is implemented in the shared app foundation and sample feature.
