# AI Chat Starter Feature

## Goal
Provide a reusable, provider-independent example of a text-chat flow.

## Boundaries
- Presentation depends on the `AiChatService` interface only.
- The OpenAI-compatible adapter delegates to the core client.
- The starter home page uses `UnavailableAiChatService` until an authenticated
  backend is configured. It must not pretend to provide real AI responses.
- Provider credentials remain on a trusted backend; do not place API keys in
  app assets, source code, or APK build configuration.

## Behavior
- Trim input and do not submit empty messages.
- Display the user's message and the assistant reply.
- Show a loading state while a reply is pending.
- Show safe, user-readable errors when the request fails.
- Allow the conversation to be cleared when no request is in progress.
- Support the app's light and dark themes.

## Acceptance criteria
- A successful fake service displays both the submitted message and response.
- Empty messages are not sent.
- Service failures produce a visible, user-safe error.
- The starter app clearly tells users that a backend is required for live AI.
