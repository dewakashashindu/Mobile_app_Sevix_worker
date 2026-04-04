import 'dart:async';

import 'package:flutter/material.dart';

import 'chat_models.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatConversation conversation;
  final String selectedLanguage;

  const ChatDetailScreen({
    super.key,
    required this.conversation,
    this.selectedLanguage = 'en',
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  late List<ChatMessage> _messages;
  bool _isTyping = false;

  String _t(String en, String si, String ta) {
    switch (widget.selectedLanguage) {
      case 'si':
        return si;
      case 'ta':
        return ta;
      case 'en':
      default:
        return en;
    }
  }

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

  void _updateDeliveryStatus(String messageId, ChatDeliveryStatus status) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index < 0) return;
    setState(() {
      _messages[index] = _messages[index].copyWith(deliveryStatus: status);
    });
  }

  void _sendTextMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    final messageId = DateTime.now().microsecondsSinceEpoch.toString();
    _appendMessage(
      ChatMessage(
        id: messageId,
        type: ChatMessageType.text,
        text: text,
        isMe: true,
        timestamp: DateTime.now(),
        deliveryStatus: ChatDeliveryStatus.sent,
      ),
    );

    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      _updateDeliveryStatus(messageId, ChatDeliveryStatus.delivered);
    });
    Future<void>.delayed(const Duration(milliseconds: 1550), () {
      if (!mounted) return;
      _updateDeliveryStatus(messageId, ChatDeliveryStatus.read);
    });

    _simulateTypingReply();
  }

  void _sendImageMessage() {
    final messageId = DateTime.now().microsecondsSinceEpoch.toString();
    _appendMessage(
      ChatMessage(
        id: messageId,
        type: ChatMessageType.image,
        text: _t('Image message', 'ඡායාරූප පණිවිඩය', 'படச் செய்தி'),
        isMe: true,
        timestamp: DateTime.now(),
        deliveryStatus: ChatDeliveryStatus.sent,
      ),
    );

    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      _updateDeliveryStatus(messageId, ChatDeliveryStatus.delivered);
    });
    Future<void>.delayed(const Duration(milliseconds: 1550), () {
      if (!mounted) return;
      _updateDeliveryStatus(messageId, ChatDeliveryStatus.read);
    });

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
        text: _t(
          'Got it. I will get back to you shortly.',
          'හරි. මම ඉක්මනින් ඔබට පිළිතුරු දෙන්නම්.',
          'சரி. விரைவில் உங்களிடம் மீண்டும் தொடர்புகொள்கிறேன்.',
        ),
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
        child: Text(
          _t('Typing...', 'ටයිප් කරමින්...', 'தட்டச்சு செய்கிறார்...'),
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
      ),
    );
  }

  (IconData, Color, String) _deliveryMeta(ChatDeliveryStatus status) {
    switch (status) {
      case ChatDeliveryStatus.sent:
        return (
          Icons.done,
          const Color(0xFFCBD5E1),
          _t('Sent', 'යවන ලදී', 'அனுப்பப்பட்டது'),
        );
      case ChatDeliveryStatus.delivered:
        return (
          Icons.done_all,
          const Color(0xFFCBD5E1),
          _t('Delivered', 'ලැබුණා', 'சென்றது'),
        );
      case ChatDeliveryStatus.read:
        return (
          Icons.done_all,
          const Color(0xFF60A5FA),
          _t('Read', 'කියවීය', 'படிக்கப்பட்டது'),
        );
    }
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
                          _t('Image', 'ඡායාරූපය', 'படம்'),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _timeText(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: isMe
                          ? const Color.fromARGB(210, 255, 255, 255)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 6),
                    Builder(
                      builder: (_) {
                        final (icon, color, label) = _deliveryMeta(
                          message.deliveryStatus,
                        );
                        return Tooltip(
                          message: label,
                          child: Icon(icon, size: 14, color: color),
                        );
                      },
                    ),
                  ],
                ],
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
                    tooltip: _t(
                      'Send image message',
                      'ඡායාරූප පණිවිඩය යවන්න',
                      'படச் செய்தியை அனுப்பு',
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendTextMessage(),
                      decoration: InputDecoration(
                        hintText: _t(
                          'Type a message',
                          'පණිවිඩයක් ටයිප් කරන්න',
                          'செய்தி தட்டச்சு செய்யவும்',
                        ),
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
