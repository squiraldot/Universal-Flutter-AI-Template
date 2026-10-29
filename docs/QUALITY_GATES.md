# Quality Gates

## Every code change
- Matches approved requirements and existing conventions.
- Formatting passes; no new analyzer errors.
- Relevant tests pass.
- No secrets or sensitive logs introduced.
- Diff reviewed; docs updated when needed.

## When relevant
- Android build passes after plugin, Gradle, manifest, permission or native changes.
- Persistence migrations include data-loss and rollback review.
- Loading, empty, error, offline and permission-denied states are covered.
- UI checked for small screens, text scaling, dark theme and accessibility.
- Critical journeys have integration tests where practical.

## Release
- Version/build number and release notes reviewed.
- Signing uses protected secrets.
- Permissions/privacy disclosures reviewed.
- Release artifact verified.
