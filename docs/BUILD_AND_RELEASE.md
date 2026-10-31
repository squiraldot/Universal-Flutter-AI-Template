# Build and Release

Flutter is a Git submodule at `third_party/flutter`, pinned to a specific stable commit. The superproject gitlink records the exact SDK commit. The `.gitmodules` entry enables shallow clones to reduce initial checkout time. Upgrade deliberately and test the toolchain as a compatible set.

## Bootstrap
1. Install JDK and Android SDK prerequisites.
2. Run `git submodule update --init --recursive`.
3. Run `bash scripts/bootstrap.sh`.
4. Review and commit generated Android files and `pubspec.lock`.

## CI
- `flutter-ci.yml`: formatting, analysis, tests and debug APK artifact.
- `initialize-new-app.yml`: generate a new app identity and downloadable source/APK artifacts.
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

## Signing and security

Never commit keystores or `key.properties`. Use GitHub Secrets for signing credentials. Secrets embedded in an APK/AAB can usually be extracted; privileged operations belong on a trusted backend. Flutter `--dart-define` values are public configuration, not secret storage.

Debug APKs are for testing, not production. Review the version/build number, release notes, permissions, privacy disclosures and signed artifact before distribution.
