# Build and Release

Flutter is a Git submodule at `third_party/flutter`, pinned to a specific stable commit. The superproject gitlink records the exact SDK commit. Upgrade deliberately and test the toolchain as a compatible set.

## Bootstrap
1. Install JDK and Android SDK prerequisites.
2. Run `git submodule update --init --recursive`.
3. Run `bash scripts/bootstrap.sh`.
4. Review and commit generated Android files and `pubspec.lock`.

## CI
- `ci.yml`: formatting, analysis and tests.
- `build-debug-apk.yml`: debug APK build and artifact upload.
- Workflows expect the submodule to be initialized and pinned.
- Keep Flutter, JDK, Android SDK, Gradle and Android Gradle Plugin compatible.

Never commit keystores or key.properties. Add a protected release workflow only after signing, versioning and destination are decided. Debug APKs are for testing, not production.
