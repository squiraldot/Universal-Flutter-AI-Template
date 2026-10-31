# Build and Release

Flutter is a Git submodule at `third_party/flutter`, pinned to a specific stable commit. The superproject gitlink records the exact SDK commit. The `.gitmodules` entry enables shallow clones to reduce initial checkout time. Upgrade deliberately and test the toolchain as a compatible set.

## Platform prerequisites

| Platform | Build host | Tooling | CI output |
| --- | --- | --- | --- |
| Android | Linux, macOS or Windows | Flutter, JDK 17, Android SDK | Debug APK; manual signed AAB release |
| iOS | macOS only | Flutter, Xcode and iOS SDK | Unsigned iOS build validation |
| Web | Linux, macOS or Windows | Flutter and a supported browser for local testing | Production bundle in `build/web` |

The bootstrap script uses `flutter create --platforms=android,ios,web` in a temporary directory and copies only platform folders that do not already exist. It does not overwrite the app's Dart source or pubspec.

## Bootstrap

1. Install Flutter and initialize its submodule: `git submodule update --init --recursive`.
2. Install JDK and Android SDK for Android builds; install Xcode on macOS for iOS builds.
3. Run `bash scripts/bootstrap.sh`.
4. Review generated Android, iOS and Web files and commit them with `pubspec.lock`.

## Build commands

```bash
third_party/flutter/bin/flutter build apk --debug
# Run on macOS with Xcode installed:
third_party/flutter/bin/flutter build ios --no-codesign
third_party/flutter/bin/flutter build web --release
```

The Web output is written to `build/web`. Configure the hosting provider to serve this directory and route unknown paths to `index.html` when using path-based client-side routing.

## CI

- `flutter-ci.yml`: formatting, analysis, tests, coverage, Android debug APK and Web release bundle on Ubuntu; unsigned iOS build on macOS.
- `initialize-new-app.yml`: generate all three platform scaffolds, apply app identity and upload initialized source, Android APK and Web bundle artifacts.
- `initializer-script-tests.yml`: shell syntax and initializer regression tests.
- `secret-scan.yml`: Gitleaks scans the complete Git history on pushes and pull requests.
- `release-signed-aab.yml`: manually builds, signs and uploads a release Android App Bundle from `main`.
- Flutter SDK and Gradle dependency caches are enabled in Android build workflows.
- Third-party GitHub Actions are pinned to full commit SHAs.
- Dependabot has weekly schedules for GitHub Actions and Pub dependencies, but the configured zero-open-PR limits prevent it from opening version-update pull requests.

## Manual signed AAB release

The release workflow is intentionally manual and only runs when dispatched against `main`. Before using it, add these four repository Actions secrets under **Settings → Secrets and variables → Actions**:

| Secret | Value |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded upload keystore file |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | Upload key alias |
| `ANDROID_KEY_PASSWORD` | Upload key password |

Create the upload keystore locally and keep the original file in a secure password manager or offline backup. For example:

```bash
keytool -genkeypair -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
base64 -w 0 upload-keystore.jks
```

Copy the base64 output into `ANDROID_KEYSTORE_BASE64`; add the other values as separate GitHub Secrets. On macOS, use `base64 < upload-keystore.jks | tr -d '\\n'` to produce a single-line value. Never add the keystore, passwords, `key.properties`, or base64 keystore contents to Git, workflow files, artifacts, or logs. The workflow materializes the keystore only in the ephemeral runner's temporary directory, signs the generated AAB, verifies its JAR signature, and removes the temporary keystore.

In **Actions → Manual Signed AAB Release → Run workflow**, select `main`, provide the app version name and Android version code, then download the signed AAB from the run's artifact. Keep the same upload key safe for future updates; losing it can block updates unless Play App Signing recovery is available.

## iOS signing and distribution

The CI job runs `flutter build ios --no-codesign` on macOS to validate compilation without credentials. Device installation, simulator testing, archive signing, provisioning profiles, certificates, TestFlight and App Store delivery require app-specific Xcode configuration and Apple developer credentials. Those are intentionally not stored or configured in this generic template.

## Web deployment

CI uploads the static production output from `build/web`; it does not deploy it. Choose a host, configure SPA route fallback to `index.html` if needed, set cache headers and connect the app's domain through that provider. Web is intended for app-style interfaces rather than SEO-first content publishing.

## Signing and security

Never commit keystores or `key.properties`. Use GitHub Secrets for signing credentials. Secrets embedded in an APK, iOS app or Web bundle can be extracted; privileged operations belong on a trusted backend. Flutter `--dart-define` values are public configuration, not secret storage.

Debug APKs are for testing, not production. Review version/build numbers, release notes, permissions, privacy disclosures, browser compatibility and signed artifacts before distribution.
