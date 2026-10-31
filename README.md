# Universal Flutter AI App Template

A reusable foundation for building Android, iOS and Web apps with Flutter, with optional AI integration modules.

## Why this exists

Starting a new Flutter app often means rebuilding the same project structure, quality checks, documentation habits and CI setup. This template brings those foundations together so a new project can begin with a consistent, reviewable baseline instead of copying a one-off app.

It is intentionally app-agnostic. It does not prescribe a chat app, a particular product workflow, or a fixed set of screens. The target app's approved specification determines what gets built.

## Supported platforms

- **Android** — debug APK build in Linux CI; signed AAB release remains a separate manual workflow.
- **iOS** — unsigned iOS build in macOS CI. Xcode/macOS is required; App Store distribution and signing are not configured by this template.
- **Web** — production bundle built in Linux CI and uploaded as an artifact. Hosting/deployment is intentionally left to the app owner.

Flutter Web is intended for app-style experiences. It is not a replacement for an SEO-first, content-heavy public website.

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
5. Generate Android, iOS and Web scaffolds with `bash scripts/bootstrap.sh`.
6. Initialize the app identity with `bash scripts/init_app.sh [--ios-bundle-id <id>] "<App Name>" <dart_package_name> <android.applicationId>`.
7. Implement only the approved scope, keeping architecture decisions documented.
8. Run formatting, analysis, tests and platform builds; review GitHub Actions before release.

## What this template provides

- AI agent instructions and app-specific specifications
- Feature-first Flutter starter structure with a replaceable, app-agnostic home screen
- Android, iOS and Web native/web scaffolding generated without overwriting Dart source
- Pinned Flutter SDK Git submodule with shallow-clone configuration
- GitHub Actions for CI, Android APK and Web artifacts, unsigned iOS build, new-app initialization, secret scanning and manual signed-AAB releases
- Dependabot configuration for weekly GitHub Actions and Pub dependency updates; automatic update pull requests are disabled by the current zero-open-PR limits
- Security, testing, architecture and release guidance
- Optional provider-independent AI client foundation for apps that need AI

## Core architecture conventions

- **State and dependency injection:** Riverpod 3 providers and feature-owned async controllers; constructor injection for plain Dart classes.
- **Navigation:** go_router with centralized route definitions and Web URL support.
- **UI system:** Material 3 themes plus shared spacing, radius and motion tokens.
- **Localization:** Flutter `gen_l10n` with ARB resources. Generate before analysis with `flutter gen-l10n`.
- **Error reporting:** local Flutter framework/platform error forwarding through the injectable logger; raw exception payloads are not sent to logs and no remote telemetry SDK is enabled by default.
- **Sample feature:** a small task checklist at `/sample-tasks` demonstrates repository injection, loading/empty/error/retry states and state updates.

## Run with an environment

After `flutter pub get`, generate localization and run one of the explicit public configuration files:

```bash
third_party/flutter/bin/flutter gen-l10n
third_party/flutter/bin/flutter run --dart-define-from-file=config/development.json
third_party/flutter/bin/flutter run --dart-define-from-file=config/staging.json
third_party/flutter/bin/flutter build apk --release --dart-define-from-file=config/production.json
```

The JSON files contain only `APP_ENV` names. `--dart-define-from-file` does not encrypt values; never place secrets in them. These Dart configurations do not create native Android product flavors or iOS schemes.

The default starter screen stays app-agnostic. This repository is a template, not a prebuilt chat application: app-specific screens and features must be added only from the target app's approved specification.

No folder structure can guarantee zero issues for every app. This template reduces avoidable problems; app-specific plugins, backend, permissions, browser constraints and release configuration still require validation.

## First setup

1. Create a repository from this template or copy it into a new app repository.
2. Initialize submodules: `git submodule update --init --recursive`.
3. Run `bash scripts/bootstrap.sh` with Flutter installed. Android builds additionally require JDK and Android SDK; iOS builds require macOS and Xcode.
4. Initialize the app identity using the script below.
5. Review and commit generated platform files and `pubspec.lock`.
6. Push to GitHub and inspect CI artifacts.

## Initialize a new app

After `scripts/bootstrap.sh` has generated the platform projects, run:

```bash
bash scripts/init_app.sh --ios-bundle-id com.squiraldot.lifebit "Lifebit" lifebit com.squiraldot.lifebit
```

The arguments are the human-readable app name (1–50 characters), lowercase Dart package name, and reverse-domain Android application ID. The optional `--ios-bundle-id` sets the iOS bundle identifier; when omitted, it defaults to the Android application ID.

Preview all planned changes without writing files:

```bash
bash scripts/init_app.sh --dry-run --ios-bundle-id com.example.my_app "My App" my_app com.example.my_app
```

The script updates `pubspec.yaml`, Dart package imports, starter app titles and widget-test expectations, `docs/APP_SPEC.md`, Android Gradle identity and launcher label, iOS Xcode bundle ID and display name, Web document title and web manifest names, and the Android `MainActivity` package/path. It validates expected files and patterns before writing, refuses ambiguous configurations, and is safe to rerun with the same values. It does not run `flutter pub get`; run that after initialization to refresh the lockfile.

Run the script's fixture-based safety checks with `bash scripts/tests/init_app_test.sh`. They cover invalid input, dry-run immutability, Android/iOS/Web identity updates, MainActivity relocation and repeat-run idempotence.

Changing platform identifiers later may also require separate updates to store listings, signing/release configuration, Apple provisioning and external service registrations.

## Initialize from GitHub Actions

You can initialize a fresh app without running the scripts locally:

1. Open the repository's **Actions** tab and select **Initialize New App**.
2. Choose **Run workflow** and enter the app name, Dart package name, Android application ID and optional iOS bundle ID.
3. Leave **Dry run** unchecked to generate all three platform scaffolds, apply identity, run initializer tests, formatting, analysis and Flutter tests, then build a debug APK and Web bundle.
4. Open the completed workflow run's **Artifacts** section.

A dry run uploads only the initialization preview. A full run uploads the initialized source archive, debug APK and Web bundle. The workflow does not commit generated files back to the template repository; download the source artifact and use it as the starting point for your new app repository.

The workflow runs on a clean GitHub-hosted Ubuntu runner. It requires no repository secrets. iOS compilation is validated separately on macOS by the main Flutter CI workflow.

## Manual signed AAB release

For a production Android App Bundle, configure the four repository Actions secrets documented in [Build and Release](docs/BUILD_AND_RELEASE.md), then run **Manual Signed AAB Release** from the Actions tab against `main`. The workflow uploads a signature-verified AAB artifact and never writes signing credentials into the repository.

## Commands

```bash
git submodule update --init --recursive
bash scripts/bootstrap.sh
bash scripts/init_app.sh --dry-run --ios-bundle-id com.example.my_app "My App" my_app com.example.my_app
bash scripts/init_app.sh --ios-bundle-id com.example.my_app "My App" my_app com.example.my_app
third_party/flutter/bin/flutter pub get
third_party/flutter/bin/flutter gen-l10n
third_party/flutter/bin/dart format lib test
third_party/flutter/bin/flutter analyze
third_party/flutter/bin/flutter test --coverage
bash scripts/check_coverage.sh
third_party/flutter/bin/flutter build apk --debug --dart-define-from-file=config/development.json
third_party/flutter/bin/flutter build ios --no-codesign --dart-define-from-file=config/production.json  # macOS + Xcode only
third_party/flutter/bin/flutter build web --release --dart-define-from-file=config/production.json
```

Read `AGENTS.md` and relevant docs before coding. Never commit secrets, signing keys, service-account files or production user data.
