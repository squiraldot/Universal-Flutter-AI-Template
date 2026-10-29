import '../../../core/ai/ai_exception.dart';
import '../../../core/ai/openai_compatible_ai_client.dart';
import '../domain/ai_chat_service.dart';

/// Adapts the core HTTP client to the chat feature's app-facing contract.
class OpenAiCompatibleChatService implements AiChatService {
  const OpenAiCompatibleChatService(this._client);

  final OpenAiCompatibleAiClient _client;

  @override
  Future<String> sendMessage(String message) async {
    try {
      return await _client.complete(message);
    } on AiException catch (error) {
      throw AiChatException(error.message);
    }
  }
}
