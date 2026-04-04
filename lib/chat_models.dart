import 'package:flutter/material.dart';

enum ChatMessageType { text, image }

class ChatMessage {
  final String id;
  final ChatMessageType type;
  final String text;
  final bool isMe;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.type,
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}

class ChatConversation {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final Color avatarColor;
  final String initials;
  final List<ChatMessage> messages;

  const ChatConversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.avatarColor,
    required this.initials,
    required this.messages,
  });
}
