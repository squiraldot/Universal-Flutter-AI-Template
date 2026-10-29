/// App-facing contract for sending a chat message to an AI assistant.
///
/// UI code depends on this interface instead of a concrete HTTP client.
abstract interface class AiChatService {
  Future<String> sendMessage(String message);
}

/// A safe, displayable error produced by the chat feature.
class AiChatException implements Exception {
  const AiChatException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Used by the starter UI until an authenticated backend is configured.
class UnavailableAiChatService implements AiChatService {
  const UnavailableAiChatService();

  @override
  Future<String> sendMessage(String message) async {
    throw const AiChatException(
      'AI backend is not connected yet. Configure a secure backend to receive '
      'real AI responses.',
    );
  }
}
