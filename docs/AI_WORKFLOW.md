# AI Development Workflow

Before coding, read `AGENTS.md`, `APP_SPEC.md` and relevant feature docs. Inspect current files, restate the outcome and identify critical unknowns. For substantial work, propose a plan listing files, tests, risks and acceptance criteria.

Implement small vertical slices. Add a failing test first for logic/bug fixes where practical. Format, analyze, run focused and full tests. Build APK after native/config/dependency changes when feasible. Review diffs for secrets, duplicate code and unrelated edits. Update docs when behavior changes. Never regenerate customized Android files blindly.

## Task prompt
Read `AGENTS.md`, `docs/INDEX.md`, `docs/APP_SPEC.md`, `docs/ARCHITECTURE.md` and the relevant feature spec first. Inspect existing code. Implement only: [specific outcome]. Follow existing patterns and design tokens. Add/update tests. Do not add dependencies or change public behavior without justification. Run formatting, analysis, tests and relevant build; report actual results, files changed, limitations and migrations. Never claim checks passed unless run.

Use feature branches/PRs for meaningful changes. Avoid destructive history changes. Never put secrets in prompts, code or logs.
