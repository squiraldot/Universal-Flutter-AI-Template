# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-10-31

### Added
- App-agnostic Flutter starter application with a feature-first structure,
  Material 3 light/dark themes, a home screen, and widget tests.
- Pinned Flutter stable SDK submodule and Android bootstrap workflow.
- `scripts/init_app.sh` to validate and apply an app name, Dart package name,
  and Android application ID across Dart, pubspec, app specification, Gradle,
  manifest resources, and MainActivity. Includes dry-run support, guarded
  updates, and fixture-based validation/idempotence tests.
- Repository guidance and documentation for app specifications, architecture,
  roadmap, AI-assisted development, quality gates, UI conventions, security,
  testing, decisions, and Android builds/releases.
- Optional provider-independent AI foundation: validated endpoint/model/timeout
  configuration, request-time token provider, injectable HTTP client, and a
  minimal OpenAI-compatible chat-completions client with user-safe errors.
- GitHub issue templates for bug reports and feature requests, plus a reusable
  pull-request verification checklist and feature-specification template.

### Security
- Gitleaks workflow scans the full Git history on pushes and pull requests to
  `main`, with manual dispatch support.
- Signed release credentials are read from GitHub Actions secrets and the
  temporary keystore is removed from the runner after signing.

### CI
- GitHub Actions run Flutter formatting, analysis, tests, coverage checks, and
  debug APK builds with downloadable artifacts.
- Manual signed Android App Bundle workflow builds from `main`, verifies the
  JAR signature, and uploads the signed AAB as an artifact.
- Manual initialize-new-app workflow can preview or apply app identity changes,
  run initializer and Flutter checks, and upload source and debug APK artifacts.
- Dependabot defines weekly GitHub Actions and Pub update schedules with
  grouped ecosystems; zero-open-PR limits currently prevent version-update PRs.
- Flutter SDK and Android build tooling are pinned/configured for reproducible
  CI and release workflows.
