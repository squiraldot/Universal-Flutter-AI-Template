# ADR 0007: Error Reporting and Diagnostics

- **Status:** Accepted
- **Date:** 2026-10-31
- **Branch:** `main`
- **Scope:** Error boundaries, safe user feedback, diagnostics and optional remote crash reporting.

## Context

The repository already has an `AppError` contract and an injectable `AppLogger` backed by `dart:developer`. It does not yet define how uncaught Flutter/platform errors are handled or whether the generic template should transmit diagnostics to a third party.

## Options

1. **Local diagnostics only.** Use Flutter/framework error hooks and the existing logger. No external dependency or data transfer, but no centralized production crash visibility.
2. **Provider SDK by default (for example Sentry or Firebase Crashlytics).** Rich crash grouping and release diagnostics, but adds a vendor dependency, configuration burden and privacy/data-processing obligations. Crashlytics does not cover Flutter Web in the same way as mobile.
3. **Provider-neutral reporting contract with opt-in adapters.** Keep local logging and safe error handling as the default; define a small reporting boundary only when a real app needs remote telemetry, then select a provider based on its platforms, privacy terms and operational needs. Avoid an unused abstraction until the first adapter is approved.

## Recommendation

Keep **local diagnostics as the default** using the existing `AppLogger`, `AppError` and Flutter's framework/platform error hooks. Do not enable remote reporting in the template. When a target app requires remote crash reporting, add a narrowly scoped adapter after a separate provider/privacy review; Sentry is a candidate for cross-platform coverage, while Crashlytics may fit mobile-only Firebase apps.

Present safe, actionable messages to users; retain technical causes and stack traces only in controlled diagnostics. Never log tokens, personal data, full request/response bodies or secrets.

## Consequences

- After approval, add tests for uncaught error forwarding, safe UI messages and logger redaction boundaries.
- Define whether fatal errors are rethrown after reporting; do not silently swallow them.
- Remote reporting requires explicit consent/legal/privacy review where applicable, retention controls and platform verification.
- Do not add a remote SDK or transmit user data in this generic template by default.

## Approval and implementation

Approved by the user on 2026-10-31. This decision is implemented in the shared app foundation and sample feature.
