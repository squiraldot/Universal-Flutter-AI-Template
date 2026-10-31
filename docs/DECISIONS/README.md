# Architecture Decision Records

Create one Markdown file per durable decision. Each record states its status, context and constraints, options, recommendation, consequences, testing implications and approval gate.

## Existing baseline

- [0001 — Minimal Universal App Baseline](0001-minimal-universal-app-baseline.md) — existing baseline proposal and approval gate.

## Proposed decisions — awaiting user approval

- [0002 — State Management](0002-state-management.md)
- [0003 — Routing](0003-routing.md)
- [0004 — Dependency Injection](0004-dependency-injection.md)
- [0005 — Theming and Design Tokens](0005-theming-design-tokens.md)
- [0006 — Localization](0006-localization.md)
- [0007 — Error Reporting and Diagnostics](0007-error-reporting.md)
- [0008 — Build Environments and Flavors](0008-environment-flavors.md)

These proposals are not implementation authorization. Approve or revise each decision explicitly before code, dependencies, configuration files or workflows are changed. All approved implementation work remains on `main`.
