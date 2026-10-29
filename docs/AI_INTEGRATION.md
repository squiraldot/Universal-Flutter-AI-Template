# AI Integration Foundation

The core AI layer currently supports the text-chat subset of APIs compatible
with the OpenAI `/chat/completions` request and response format.

## Components

- `AiConfig`: endpoint root, model name and request timeout.
- `AiTokenProvider`: async token supplier called for each request.
- `OpenAiCompatibleAiClient`: injectable HTTP client for testability.
- `AiException`: user-safe errors without leaking raw provider response bodies.

## Security requirements

- Never commit provider API keys or put long-lived provider secrets in Flutter
  source, assets, build arguments, or the shipped APK. Mobile binaries can be
  inspected by users.
- For production, route requests through a trusted backend that authenticates
  the user, stores provider credentials server-side, and applies rate limits
  and usage controls. The token provider should return only a short-lived,
  scoped session token where possible.
- Use HTTPS for production endpoints.
- Treat model output as untrusted input. Validate it before using it in commands,
  database writes, navigation, or other sensitive actions.
- Do not log prompts, access tokens, or raw provider error bodies by default.

## Example

```dart
final ai = OpenAiCompatibleAiClient(
  config: AiConfig(
    baseUrl: Uri.parse('https://your-backend.example.com/v1'),
    model: 'your-configured-model',
  ),
  tokenProvider: () async => await sessionRepository.getShortLivedAiToken(),
);

try {
  final answer = await ai.complete('Summarize this paragraph.');
  // Present answer as untrusted text.
} on AiException catch (error) {
  // Show error.message to the user; keep technical details out of the UI.
} finally {
  ai.close();
}
```

The example intentionally uses a backend endpoint. A production backend should
adapt the provider-specific API to this contract and keep provider credentials
off-device. The client is not wired into the starter UI yet; app-specific
screens should depend on a feature-level abstraction rather than constructing
this client directly.
