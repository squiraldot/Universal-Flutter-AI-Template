# Universal Flutter AI App Template

A reusable foundation for building different kinds of Flutter apps, with optional AI integration modules.

## Why this exists

Starting a new Flutter app often means rebuilding the same project structure, quality checks, documentation habits and CI setup. This template brings those foundations together so a new project can begin with a consistent, reviewable baseline instead of copying a one-off app.

It is intentionally app-agnostic. It does not prescribe a chat app, a particular product workflow, or a fixed set of screens. The target app's approved specification determines what gets built.

## Who it's for

- Developers starting a new Flutter application who want a maintainable baseline.
- Small teams that want shared conventions for architecture, testing, security and CI.
- Developers using AI coding assistants who need one clear, repository-level source of instructions.
- Projects that may need AI capabilities but want provider-specific integrations to remain optional.

## Example workflow

1. Create a repository from this template (or copy it into a new app repository).
2. Read `AGENTS.md` and the documentation listed in `docs/INDEX.md`.
3. Define the target app in `docs/APP_SPEC.md`.
4. Initialize the pinned Flutter SDK submodule: `git submodule update --init --recursive`.
5. Generate the Android scaffold with `bash scripts/bootstrap.sh`.
6. Initialize the app identity with `bash scripts/init_app.sh "<App Name>" <dart_package_name> <android.applicationId>`.
7. Implement only the approved scope, keeping architecture decisions documented.
8. Run formatting, analysis, tests and a debug APK build; review GitHub Actions before merging.

## What this template provides

- AI agent instructions and app-specific specifications
- Feature-first Dart structure with optional complexity only when needed
- Pinned Flutter SDK Git submodule
- GitHub Actions for analysis/tests and debug APK artifacts
- Security, testing, architecture and release guidance
- Optional provider-independent AI client foundation for apps that need AI

The default starter screen stays app-agnostic. This repository is a template, not a prebuilt chat application: app-specific screens and features must be added only from the target app's approved specification.

No folder structure can guarantee zero issues for every app. This template reduces avoidable problems; app-specific plugins, backend, permissions and release configuration still require validation.

## First setup

1. Create a repository from this template or copy it into a new app repository.
2. Initialize submodules: `git submodule update --init --recursive`.
3. Run `bash scripts/bootstrap.sh` with JDK and Android SDK installed.
4. Initialize the app identity using the script below.
5. Review and commit generated Android files and `pubspec.lock`.
6. Push to GitHub and inspect CI/APK workflow results.

## Initialize a new app

After `scripts/bootstrap.sh` has generated the Android project, run:

```bash
bash scripts/init_app.sh "Lifebit" lifebit com.squiraldot.lifebit
```

The three arguments are the human-readable app name (1–50 characters), lowercase Dart package name, and reverse-domain Android application ID.

Preview all planned changes without writing files:

```bash
bash scripts/init_app.sh --dry-run "Lifebit" lifebit com.squiraldot.lifebit
```

The script updates `pubspec.yaml`, Dart package imports, starter app titles and widget-test expectations, `docs/APP_SPEC.md`, Android Gradle namespace/application ID, launcher label, and the `MainActivity` package/path. It validates expected files and patterns before writing, refuses ambiguous Android configurations, and is safe to rerun with the same values. It does not run `flutter pub get`; run that after initialization to refresh the lockfile.

The Android scaffold must exist first. Changing an application ID later may also require separate updates to store listings, signing/release configuration and external service registrations.

## Commands

```bash
git submodule update --init --recursive
bash scripts/bootstrap.sh
bash scripts/init_app.sh --dry-run "My App" my_app com.example.my_app
bash scripts/init_app.sh "My App" my_app com.example.my_app
third_party/flutter/bin/dart format lib test
third_party/flutter/bin/flutter analyze
third_party/flutter/bin/flutter test
third_party/flutter/bin/flutter build apk --debug
```

Read `AGENTS.md` and relevant docs before coding. Never commit secrets, signing keys, service-account files or production user data.
