# Release Checklist

Use this checklist for every app release created from the template. Record the reviewer and release date in the release notes or project tracker.

## Versioning and release metadata

- [ ] Update `version` in `pubspec.yaml` using the app's semantic-versioning policy (`MAJOR.MINOR.PATCH+BUILD`).
- [ ] Confirm the user-facing version and monotonically increasing build number for each distribution channel.
- [ ] Verify Android `versionName` / `versionCode` and iOS `CFBundleShortVersionString` / `CFBundleVersion` resolve to the intended values.
- [ ] Review release notes, supported upgrade path, minimum OS versions and any migration/rollback plan.
- [ ] Confirm the release was built from the intended, reviewed commit and a clean working tree.

## Android shrinking, R8 and ProGuard

- [ ] Inspect the release build's `minifyEnabled` and `shrinkResources` settings; enable shrinking only after app/plugin compatibility has been checked.
- [ ] Review `proguard-rules.pro` and plugin-provided keep rules. Keep rules should be narrow and justified; do not add blanket keep-all rules to silence failures.
- [ ] Test the minified release APK/AAB on representative devices, including authentication, deep links, serialization/reflection, notifications and other plugin-backed flows used by the app.
- [ ] Verify crash/stack-trace deobfuscation works and archive the matching R8 mapping file securely for the exact release.
- [ ] Confirm debug builds remain debuggable and release builds do not expose debug-only endpoints, logs or diagnostics.
- [ ] Verify the signed artifact and signing certificate; never commit keystores, passwords or `key.properties`.

## Permissions and platform declarations

- [ ] Review every Android manifest permission and every iOS `Info.plist` usage-description key. Remove permissions and declarations not required by an approved feature.
- [ ] Confirm each sensitive permission (camera, microphone, photos, location, contacts, notifications, etc.) is requested only at the point of need and after a clear user explanation.
- [ ] Test granted, denied, restricted and permanently denied permission paths, including a route to system settings where appropriate.
- [ ] Check Android intent filters, exported components, network security configuration and background capabilities.
- [ ] Check iOS privacy manifests, required-reason API declarations, entitlements and background modes where applicable.
- [ ] For Web, review browser permission prompts, clipboard/media access, storage behavior and secure-context requirements.

## Privacy disclosures and data handling

- [ ] Inventory data collected, generated, transmitted, stored, shared and retained by the app and its SDKs/plugins.
- [ ] Document purposes, legal basis/consent where applicable, processors/AI providers, retention periods, deletion behavior and cross-border transfers.
- [ ] Ensure in-app privacy policy and public policy URL are current, accessible and consistent with actual behavior.
- [ ] Complete applicable Google Play Data safety and Apple App Privacy disclosures from the real release build and SDK behavior; do not infer answers from source code alone.
- [ ] Disclose AI processing clearly when prompts, files or user content are sent to an AI provider; identify relevant provider/data handling and avoid sending secrets or unnecessary personal data.
- [ ] Verify consent, opt-out, account/data deletion, export and retention controls where applicable.
- [ ] Confirm analytics, crash reporting, advertising and remote logging are disabled unless approved and disclosed; verify logs do not contain tokens, credentials or personal data.

## Final verification

- [ ] Run format, analyzer, unit/widget/golden tests and the integration smoke test.
- [ ] Run the coverage gate and confirm the configured threshold is met.
- [ ] Build and manually smoke-test the release artifact for every supported platform.
- [ ] Review accessibility, localization, offline/error states and supported device/browser versions.
- [ ] Confirm store listing, screenshots, age/content ratings, support contact and policy links are current.
- [ ] Archive artifacts, checksums, R8 mapping files and release evidence in approved access-controlled storage.
