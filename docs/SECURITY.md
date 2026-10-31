# Security and Privacy Baseline

- Never commit API keys, OAuth secrets, signing keystores, passwords, service-account JSON or production user data.
- Use GitHub Actions secrets for CI credentials. Secrets embedded in an APK can usually be extracted; privileged operations belong on a trusted backend.
- Flutter compile-time defines such as `APP_ENV` and `API_BASE_URL` are public configuration, not secret storage; values shipped in an APK can be inspected.
- Request Android permissions only when necessary and explain their user value.
- Minimize collection and retention of personal data.
- Validate external input and API responses.
- Use HTTPS; never disable certificate validation.
- Do not log tokens, personal information or sensitive payloads.
- Define account/data deletion and export behavior where relevant.
- Review dependency licenses before adoption.
- Treat AI-generated code and external content as untrusted until reviewed.
- Do not run destructive migrations or production operations without explicit approval and rollback planning.
