# Universal Flutter Template Roadmap

## Product direction

This repository is a reusable starting point for Android, iOS and Web apps built with Flutter: education, productivity, business, social, utility and AI-powered apps. The default app must remain neutral and lightweight.

AI is an optional capability. The provider-independent AI client belongs in an optional reusable module; it must not define the default app experience. App-specific UI and workflows must come from the target app's approved specification.

## Milestones

### 1. Reliable multi-platform repository foundation — baseline in place
- [x] Pinned Flutter SDK and Android, iOS and Web bootstrap workflow
- [x] Automated Flutter formatting, analysis and tests workflow
- [x] Automated Android debug APK and Web release bundle builds
- [x] Unsigned iOS build validation on macOS CI
- [x] Documented security, testing, architecture and release expectations

### 2. Universal app core — next priority
- [ ] Define stable app entry points and environment/configuration boundaries
- [ ] Establish routing/navigation conventions that scale beyond one screen
- [ ] Add reusable theme tokens, typography, spacing and component conventions
- [ ] Establish consistent loading, empty, error and retry patterns
- [ ] Keep the default Home screen generic and easy to replace
- [ ] Add focused tests for the core app shell

### 3. Common app infrastructure
- [ ] Select and document a state-management approach based on maintainability
- [ ] Add repository/service boundaries and typed result/error conventions
- [ ] Add a storage abstraction with a small tested implementation only when needed
- [ ] Add privacy-conscious logging and environment-specific configuration
- [ ] Document dependency and package-addition rules

### 4. Optional capability modules
- [ ] Keep AI integration behind a provider-independent contract
- [ ] Keep provider credentials on a trusted backend
- [ ] Add integrations only as independent, documented modules when a real app requires them

### 5. Template usability and release readiness
- [ ] Document the “new app from template” workflow end-to-end
- [ ] Verify bootstrap from a clean checkout on Linux and macOS
- [ ] Verify Android, iOS and Web builds on the current CI head
- [ ] Add a release checklist for app-specific package IDs, icons, permissions, signing, hosting and privacy disclosures

## Platform boundaries

- Android debug builds and signed AAB releases are supported; signed release remains manual.
- iOS is validated with an unsigned build on macOS. Signing, provisioning and App Store delivery remain app-owner responsibilities.
- Web production output is built and uploaded as an artifact. Hosting, domains, routing fallbacks and deployment are app-owner responsibilities.
- Flutter Web is best suited to app-like interfaces; SEO-heavy public content sites may need a separate web stack.

## Working rules

- Prefer a small, tested core over preinstalling every possible package.
- Add dependencies only when a concrete reusable need justifies them.
- Every optional module must be removable without breaking the default starter.
- Do not invent app features from the template name or AI-generated assumptions; follow the filled app specification.
- Do not merge a milestone until the latest CI and platform build workflows pass.
