# Universal Flutter Template Roadmap

## Product direction

This repository is a reusable starting point for many kinds of Flutter apps: education, productivity, business, social, utility, and AI-powered apps. The default app must remain neutral and lightweight.

AI is an optional capability. AI clients, provider adapters, and sample chat screens belong in reusable or example modules; they must not define the default app experience.

## Milestones

### 1. Reliable repository foundation — baseline in place
- [x] Pinned Flutter SDK and bootstrap workflow
- [x] Automated Flutter analysis and tests workflow
- [x] Automated Android debug APK build and artifact upload workflow
- [x] Documented security, testing, architecture, and release expectations

### 2. Universal app core — next priority
- [ ] Define stable app entry points and environment/configuration boundaries
- [ ] Establish routing/navigation conventions that scale beyond one screen
- [ ] Add reusable theme tokens, typography, spacing, and component conventions
- [ ] Establish consistent loading, empty, error, and retry patterns
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
- [ ] Keep chat as an optional example feature, not the default app flow
- [ ] Add other integrations only as independent, documented modules

### 5. Template usability and release readiness
- [ ] Document the “new app from template” workflow end-to-end
- [ ] Verify bootstrap from a clean checkout
- [ ] Verify analysis, tests, and APK build on the current PR head
- [ ] Add a release checklist for app-specific package IDs, icons, permissions, signing, and privacy disclosures

## Working rules

- Prefer a small, tested core over preinstalling every possible package.
- Add dependencies only when a concrete reusable need justifies them.
- Every optional module must be removable without breaking the default starter.
- Do not merge a milestone until the latest CI and APK workflows pass.
