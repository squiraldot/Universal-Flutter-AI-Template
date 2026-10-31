import 'package:flutter/material.dart';

import '../domain/ai_chat_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    required this.chatService,
    this.showSetupNotice = false,
    super.key,
  });

  final AiChatService chatService;
  final bool showSetupNotice;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}

class _ChatPageState extends State<ChatPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = <_ChatMessage>[];
  bool _isSending = false;
  String? _errorMessage;
  bool _emptyPromptHint = false;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _inputController.text.trim();
    if (_isSending) return;
    if (message.isEmpty) {
      setState(() => _emptyPromptHint = true);
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(text: message, isUser: true));
      _inputController.clear();
      _isSending = true;
      _errorMessage = null;
      _emptyPromptHint = false;
    });
    _scrollToBottom();

    try {
      final reply = await widget.chatService.sendMessage(message);
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: reply, isUser: false));
      });
    } on AiChatException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _errorMessage = 'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Clear conversation',
            onPressed: _isSending
                ? null
                : () {
                    setState(() {
                      _messages.clear();
                      _errorMessage = null;
                      _emptyPromptHint = false;
                    });
                  },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            if (widget.showSetupNotice)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.info_outline),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Starter preview: connect a secure backend to enable '
                        'real AI responses. Provider secrets must stay off '
                        'the device.',
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.auto_awesome,
                              size: 44,
                              color: colors.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your AI chat starts here',
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Send a message to try the chat flow.',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      key: const Key('chat-messages'),
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return Align(
                          alignment: message.isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 320),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: message.isUser
                                  ? colors.primaryContainer
                                  : colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SelectableText(message.text),
                          ),
                        );
                      },
                    ),
            ),
            if (_isSending)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text('Thinking…'),
                  ],
                ),
              ),
            if (_errorMessage != null)
              Container(
                key: const Key('chat-error'),
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: colors.onErrorContainer),
                ),
              ),
            if (_emptyPromptHint)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Type a message to begin.'),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      key: const Key('chat-input'),
                      controller: _inputController,
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Ask something…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    key: const Key('chat-send'),
                    tooltip: 'Send message',
                    onPressed: _isSending ? null : _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
