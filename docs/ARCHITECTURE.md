# Architecture Guidelines

## Default feature-first layout
```text
lib/
  main.dart
  app.dart
  core/ config/ constants/ errors/ routing/ theme/ utils/ widgets/
  data/ models/ repositories/ services/
  features/<feature>/
    data/
    domain/        # Add only when business rules justify it
    presentation/
    <feature>_module.dart
  shared/ components/ widgets/
```

## Dependency direction
- Presentation depends on feature contracts/use cases, not concrete storage or HTTP clients.
- Data adapters implement repository contracts when useful.
- Core must not depend on app features.
- Features must not reach into another feature's private implementation.
- Avoid circular dependencies.

Choose state management, routing and persistence based on actual requirements; document durable decisions in `docs/DECISIONS/`. Avoid premature abstractions.

Model loading, success, empty and failure states explicitly. Validate external input at boundaries and map I/O exceptions to user-safe errors. Define offline/retry/cache/conflict behavior when relevant.
