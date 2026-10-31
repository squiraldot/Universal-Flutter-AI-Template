# ADR 0005: Theming and Design Tokens

- **Status:** Proposed — awaiting user approval
- **Date:** 2026-10-31
- **Branch:** `main`
- **Scope:** Shared visual tokens and theme conventions, not a product-specific brand.

## Context

The app currently uses Material 3, a seed color, light/dark ThemeData and a small spacing/radius token file. The template must remain neutral while making feature UI consistent, accessible and easy to rebrand.

## Options

1. **Material ThemeData only.** Use ColorScheme and TextTheme directly. Minimal and idiomatic, but app-specific spacing, radii, motion and semantic component values have no central home.
2. **Material ThemeData plus a small in-house token layer.** Keep semantic colors and typography in ThemeData; define immutable spacing, radius, motion and any non-Material semantic tokens centrally; use ThemeExtension only for values that genuinely need theme-dependent variants. Small maintenance cost with no design-system dependency.
3. **Third-party design-system/component package.** Can accelerate a strongly defined visual system, but imposes package opinions and is premature for a generic template.

## Recommendation

Adopt **Material 3 plus a small in-house token layer**. Keep ColorScheme and TextTheme authoritative for colors and typography. Centralize spacing/radius/motion constants; use ThemeExtension only when a token must vary between light and dark themes. Shared components should be added only after repeated usage is demonstrated. Preserve the existing seed as a neutral starter value until an app specification supplies its brand.

## Consequences

- No design-system dependency is needed.
- Add tests for light/dark semantic contrast and token/theme consistency where behavior is testable.
- Avoid raw colors, spacing and radii scattered through feature widgets.
- Support text scaling, minimum touch targets, semantics and responsive layouts.
- Do not treat token names as permission to invent a brand palette.

## Approval gate

This is a proposal only. Do not expand or replace the theme system until the user explicitly approves this ADR.
