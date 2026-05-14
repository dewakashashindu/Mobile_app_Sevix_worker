import 'package:flutter/material.dart';

enum ChatMessageType { text, image }

enum ChatDeliveryStatus { sent, delivered, read }

class ChatMessage {
  final String id;
  final ChatMessageType type;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final ChatDeliveryStatus deliveryStatus;

  const ChatMessage({
    required this.id,
    required this.type,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.deliveryStatus = ChatDeliveryStatus.delivered,
  });

  ChatMessage copyWith({
    String? id,
    ChatMessageType? type,
    String? text,
    bool? isMe,
    DateTime? timestamp,
    ChatDeliveryStatus? deliveryStatus,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      type: type ?? this.type,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      timestamp: timestamp ?? this.timestamp,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    );
  }
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

