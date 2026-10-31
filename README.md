# Universal Flutter AI App Template

A reusable foundation for building different kinds of Flutter apps, with optional AI integration modules.

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
2. Fill `docs/APP_SPEC.md`.
3. Initialize submodules: `git submodule update --init --recursive`.
4. Run `bash scripts/bootstrap.sh` with JDK and Android SDK installed.
5. Review and commit generated Android files and `pubspec.lock`.
6. Push to GitHub and inspect CI/APK workflow results.

## Commands
```bash
git submodule update --init --recursive
bash scripts/bootstrap.sh
third_party/flutter/bin/dart format lib test
third_party/flutter/bin/flutter analyze
third_party/flutter/bin/flutter test
third_party/flutter/bin/flutter build apk --debug
```

Read `AGENTS.md` and relevant docs before coding. Never commit secrets, signing keys, service-account files or production user data.
