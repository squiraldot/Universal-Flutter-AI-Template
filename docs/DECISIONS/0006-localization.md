# ADR 0006: Localization

- **Status:** Accepted
- **Date:** 2026-10-31
- **Branch:** `main`
- **Scope:** User-visible strings, locale selection and formatting across supported platforms.

## Context

The template supports Android, iOS and Web but currently has no localization setup. The first sample feature should demonstrate a localization-ready UI without assuming the final app's languages.

## Options

1. **Hard-coded strings / manual locale switches.** No tooling or dependency, but scales poorly, makes translations error-prone and misses locale-aware formatting.
2. **Flutter's official `gen_l10n` with ARB resources.** Integrated with Flutter tooling, generates typed localization accessors, supports plural/select messages and locale-aware formatting. Requires ARB discipline and generated-code setup.
3. **Third-party localization package (for example easy_localization).** Offers runtime loading and package-specific conveniences, but adds dependency and another localization workflow when Flutter already provides one.

## Recommendation

Adopt **Flutter `gen_l10n` with ARB files**. Keep source strings in a clearly designated default-locale ARB, declare supported locales from the app specification, and use generated `AppLocalizations` in widgets. Do not hard-code English copy in feature UI except for developer diagnostics. Do not select additional locales until the target app specifies them.

## Consequences

- Configure Flutter localization generation and include the generated localization delegates/locales in MaterialApp.
- Test locale resolution, fallback behavior, pluralization and representative widget output.
- Format dates, numbers and currencies using locale-aware APIs; never concatenate translated sentence fragments.
- Treat translation text as content, not as a place for secrets or executable instructions.

## Approval and implementation

Approved by the user on 2026-10-31. This decision is implemented in the shared app foundation and sample feature.
