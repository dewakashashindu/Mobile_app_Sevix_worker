import 'dart:async';

import 'package:flutter/material.dart';

import 'chat_models.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatConversation conversation;

  const ChatDetailScreen({super.key, required this.conversation});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  late List<ChatMessage> _messages;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages = List<ChatMessage>.from(widget.conversation.messages);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 120,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  void _appendMessage(ChatMessage message) {
    final index = _messages.length;
    _messages.add(message);
    _listKey.currentState?.insertItem(
      index,
      duration: const Duration(milliseconds: 260),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _sendTextMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _appendMessage(
      ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: ChatMessageType.text,
        text: text,
        isMe: true,
        timestamp: DateTime.now(),
      ),
    );

    _simulateTypingReply();
  }

  void _sendImageMessage() {
    _appendMessage(
      ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: ChatMessageType.image,
        text: 'Image message',
        isMe: true,
        timestamp: DateTime.now(),
      ),
    );

    _simulateTypingReply();
  }

  Future<void> _simulateTypingReply() async {
    if (_isTyping) return;

    setState(() {
      _isTyping = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() {
      _isTyping = false;
    });

    _appendMessage(
      ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: ChatMessageType.text,
        text: 'Got it. I will get back to you shortly.',
        isMe: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  String _timeText(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 8, left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          'Typing...',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, Animation<double> animation) {
    final isMe = message.isMe;

    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          padding: message.type == ChatMessageType.text
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
              : const EdgeInsets.all(8),
          constraints: const BoxConstraints(maxWidth: 270),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFF0B1533) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isMe
                ? null
                : Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (message.type == ChatMessageType.text)
                Text(
                  message.text,
                  style: TextStyle(
                    color: isMe ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              if (message.type == ChatMessageType.image)
                Container(
                  width: 180,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: isMe
                          ? const [Color(0xFF1E3A8A), Color(0xFF2563EB)]
                          : const [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          color: isMe ? Colors.white : const Color(0xFF334155),
                          size: 30,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Image',
                          style: TextStyle(
                            color: isMe
                                ? Colors.white
                                : const Color(0xFF334155),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                _timeText(message.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: isMe
                      ? const Color.fromARGB(210, 255, 255, 255)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: widget.conversation.avatarColor,
              child: Text(
                widget.conversation.initials,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.conversation.name),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AnimatedList(
                key: _listKey,
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                initialItemCount: _messages.length,
                itemBuilder: (context, index, animation) {
                  return _buildMessageBubble(_messages[index], animation);
                },
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isTyping
                  ? Padding(
                      key: const ValueKey('typing'),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _buildTypingIndicator(),
                    )
                  : const SizedBox.shrink(key: ValueKey('no-typing')),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 10,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _sendImageMessage,
                    icon: const Icon(Icons.image_outlined),
                    tooltip: 'Send image message',
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendTextMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF0B1533),
                    child: IconButton(
                      onPressed: _sendTextMessage,
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
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
