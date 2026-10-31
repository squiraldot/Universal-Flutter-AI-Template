# AI Integration Foundation

The optional AI layer exposes a provider-independent `AiClient` contract. The
current network adapter supports text completion and incremental
OpenAI-compatible chat-completions streaming. Provider-specific adapters can
implement the same contract without changing feature code.

## Architecture: app → backend proxy → AI provider

```text
Flutter feature
    |
    | AiClient (complete / stream)
    v
OpenAiCompatibleAiClient
    |
    | HTTPS + short-lived user session token
    v
Your trusted backend proxy
    |
    | provider API key kept server-side
    v
AI provider
```

The backend should authenticate the app user, authorize the requested model
and operation, enforce per-user rate and spend limits, validate request sizes,
apply provider-specific policy, and return a normalized response or
server-sent events. Store provider credentials only in the backend's secret
manager/environment. Never proxy arbitrary user-supplied provider URLs.

## Components

- `AiClient`: provider-independent completion, streaming and close contract.
  Feature code should depend on this interface, not a concrete provider.
- `AiCancellationToken`: cooperative cancellation signal. Pass it to either
  operation; cancelling a stream subscription also aborts the request.
- `AiConfig`: endpoint root, model, timeout and bounded retry settings.
- `AiTokenProvider`: async short-lived session-token supplier called for each
  operation. It must not return a long-lived provider API key.
- `OpenAiCompatibleAiClient`: injectable HTTP adapter with bounded retries,
  exponential backoff, cancellation, typed errors and SSE parsing.
- `MockAiClient`: deterministic test double in `test/support/`; use it to
  test feature behavior without a network or provider account.

## Example

```dart
final AiClient ai = OpenAiCompatibleAiClient(
  config: AiConfig(
    baseUrl: Uri.parse('https://your-backend.example.com/v1'),
    model: 'your-configured-model',
    timeout: const Duration(seconds: 25),
    maxRetries: 2,
  ),
  tokenProvider: () async =>
      await sessionRepository.getShortLivedAiToken(),
);

final cancellation = AiCancellationToken();
try {
  final answer = await ai.complete(
    'Summarize this paragraph.',
    cancellationToken: cancellation,
  );
  // Treat model output as untrusted text.
} on AiException catch (error) {
  // Branch on error.type; show only error.message to the user.
} finally {
  ai.close();
}
```

For streaming, consume `ai.stream(prompt)` as a `Stream<String>`. Cancel the
subscription when the user leaves the screen or stops generation. A supplied
`AiCancellationToken` can also cancel either operation. Retries are bounded
(0–5 retries, two by default) and apply only to transient network failures,
timeouts and retryable server/rate-limit responses; authentication and
malformed-response errors are not retried.

## Typed errors

`AiException.type` is one of:

- `AiErrorType.network`
- `AiErrorType.authentication`
- `AiErrorType.rateLimit`
- `AiErrorType.invalidResponse`
- `AiErrorType.timeout`
- `AiErrorType.cancelled`

The exception message is safe for display. Do not display or log raw provider
response bodies, prompts, access tokens or full request headers.

## Security requirements

- **Never hardcode provider API keys.** Do not put long-lived provider secrets
  in Flutter source, assets, build arguments, app configuration, CI artifacts,
  or the shipped APK/Web bundle.
- **Values passed through `--dart-define` or
  `--dart-define-from-file` are public.** They are compiled into or otherwise
  shipped with the client and can be inspected. They are configuration, not a
  secret store. A key passed this way is exposed.
- For production, route requests through a trusted backend that authenticates
  the user, stores provider credentials server-side, and applies rate limits
  and usage controls. The token provider should return only a short-lived,
  scoped session token where possible.
- Use HTTPS for production endpoints. Do not disable certificate validation.
- Treat model output as untrusted input. Validate it before using it in
  commands, database writes, navigation, or other sensitive actions.
- Do not log prompts, access tokens, personal data, or raw provider error
  bodies by default.
- Apply server-side quotas and request-size limits; client-side retry limits
  are reliability controls, not abuse prevention.

The AI client is not wired into the starter UI. App-specific features should
receive an `AiClient` through constructor injection or their feature's
Riverpod composition root rather than constructing a provider adapter in a
widget.
