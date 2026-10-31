import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_app/features/chat/domain/ai_chat_service.dart';
import 'package:universal_app/features/chat/presentation/chat_page.dart';

class _FakeChatService implements AiChatService {
  _FakeChatService(this.reply);

  final Future<String> Function(String message) reply;
  String? lastMessage;

  @override
  Future<String> sendMessage(String message) {
    lastMessage = message;
    return reply(message);
  }
}

void main() {
  testWidgets(
    'sends a message and displays the assistant reply',
    (tester) async {
      final service = _FakeChatService((_) async => 'Hello from the assistant');

      await tester.pumpWidget(
        MaterialApp(home: ChatPage(chatService: service)),
      );

      await tester.enterText(
        find.byKey(const Key('chat-input')),
        '  Hi there  ',
      );
      await tester.tap(find.byKey(const Key('chat-send')));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(service.lastMessage, 'Hi there');
      expect(find.text('Hi there'), findsOneWidget);
      expect(find.text('Hello from the assistant'), findsOneWidget);
    },
  );

  testWidgets('shows a useful error when the service fails', (tester) async {
    final service = _FakeChatService(
      (_) async => throw const AiChatException(
        'Connect an AI backend to enable chat.',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: ChatPage(chatService: service)),
    );

    await tester.enterText(find.byKey(const Key('chat-input')), 'Hello');
    await tester.tap(find.byKey(const Key('chat-send')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Connect an AI backend to enable chat.'), findsOneWidget);
  });

  testWidgets('does not send an empty message', (tester) async {
    var calls = 0;
    final service = _FakeChatService((_) async {
      calls++;
      return 'This should not appear';
    });

    await tester.pumpWidget(
      MaterialApp(home: ChatPage(chatService: service)),
    );

    await tester.tap(find.byKey(const Key('chat-send')));
    await tester.pump();

    expect(calls, 0);
    expect(find.text('Type a message to begin.'), findsOneWidget);
  });
}
