# ADR 0003: Application Routing

- **Status:** Proposed — awaiting user approval
- **Date:** 2026-10-31
- **Branch:** `main`
- **Scope:** Navigation conventions across Android, iOS and Web.

## Context

The starter currently uses Flutter's built-in Navigator 1.0 with a centralized route registry. That is sufficient for the current single-screen app, but future apps may need nested navigation, URL synchronization, browser history, deep links and guarded routes.

## Options

1. **Navigator 1.0 (current).** No dependency and minimal for simple stacks. Deep links, nested navigators, URL behavior and route guards require more hand-built conventions.
2. **Navigator 2.0 APIs directly.** Full control over declarative navigation and browser URLs. Considerable boilerplate and lifecycle complexity to maintain consistently.
3. **go_router.** Declarative route configuration built on Flutter navigation, with nested routes, redirects, deep links and Web URL support. Adds a dependency and requires deliberate route organization.

## Recommendation

Adopt **go_router** as the default routing layer after approval. Keep route declarations centralized under `lib/core/routing/`, group route trees by feature, use named/path parameters for serializable route state, and keep navigation decisions in presentation code. Avoid passing large domain objects through route extras when an ID or stable identifier will do.

## Consequences

- Verify the package version against the pinned SDK and test Android, iOS and Web URL behavior.
- Add tests for initial route, unknown route, redirects/guards where used, nested navigation and browser back/forward behavior.
- Preserve the generic Home feature as the default entry point.
- Do not mix direct route generation and go_router as competing application-wide systems.

## Approval gate

This is a proposal only. Do not add a router dependency or migrate navigation until the user explicitly approves this ADR.
