import 'package:flutter/material.dart';

import 'chat_detail_screen.dart';
import 'chat_models.dart';
import 'error_state_view.dart';
import 'shimmer_skeleton.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  LoadErrorType? _errorType;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _errorType = null;
    });

    try {
      await Future<void>.delayed(const Duration(milliseconds: 850));
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorType = LoadErrorType.data;
      });
    }
  }

  static final List<ChatConversation> _seedConversations = [
    ChatConversation(
      id: 'c1',
      name: 'Nimal Perera',
      lastMessage: 'Please come by 6 PM for the repair.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      unreadCount: 2,
      avatarColor: const Color(0xFF1D4ED8),
      initials: 'NP',
      messages: [
        ChatMessage(
          id: 'm1',
          type: ChatMessageType.text,
          text: 'Hi, are you available this evening?',
          isMe: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 17)),
        ),
        ChatMessage(
          id: 'm2',
          type: ChatMessageType.text,
          text: 'Yes, I am available. What time works for you?',
          isMe: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        ChatMessage(
          id: 'm3',
          type: ChatMessageType.image,
          text: 'Issue photo',
          isMe: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 14)),
        ),
      ],
    ),
    ChatConversation(
      id: 'c2',
      name: 'Kamala Silva',
      lastMessage: 'Thank you. Waiting for your arrival.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 8)),
      unreadCount: 0,
      avatarColor: const Color(0xFF0EA5E9),
      initials: 'KS',
      messages: [
        ChatMessage(
          id: 'm4',
          type: ChatMessageType.text,
          text: 'I have reached nearby. Will be there in 10 minutes.',
          isMe: true,
          timestamp: DateTime.now().subtract(
            const Duration(hours: 1, minutes: 12),
          ),
        ),
        ChatMessage(
          id: 'm5',
          type: ChatMessageType.text,
          text: 'Thank you. Waiting for your arrival.',
          isMe: false,
          timestamp: DateTime.now().subtract(
            const Duration(hours: 1, minutes: 8),
          ),
        ),
      ],
    ),
    ChatConversation(
      id: 'c3',
      name: 'Sunil Fernando',
      lastMessage: 'Can you share an updated quote?',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      unreadCount: 1,
      avatarColor: const Color(0xFF7C3AED),
      initials: 'SF',
      messages: [
        ChatMessage(
          id: 'm6',
          type: ChatMessageType.text,
          text: 'Can you share an updated quote?',
          isMe: false,
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    return '${time.day}/${time.month}';
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final conversations = _seedConversations.where((conversation) {
      if (query.isEmpty) return true;
      return conversation.name.toLowerCase().contains(query) ||
          conversation.lastMessage.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      appBar: AppBar(title: const Text('Chats')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search conversations',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? ShimmerSkeleton(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
                      itemCount: 7,
                      itemBuilder: (_, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            children: [
                              SkeletonBox(
                                width: 48,
                                height: 48,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(24),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SkeletonBox(width: 130, height: 14),
                                    SizedBox(height: 8),
                                    SkeletonBox(width: 180, height: 12),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              SkeletonBox(width: 28, height: 12),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : _errorType != null
                ? ErrorStateView(type: _errorType!, onRetry: _loadConversations)
                : conversations.isEmpty
                ? const _ChatEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
                    itemCount: conversations.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final chat = conversations[index];
                      return _ConversationTile(
                        conversation: chat,
                        timeText: _formatTimestamp(chat.timestamp),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ChatDetailScreen(conversation: chat),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final String timeText;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.timeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: conversation.avatarColor,
                child: Text(
                  conversation.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conversation.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeText,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (conversation.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        conversation.unreadCount > 99
                            ? '99+'
                            : '${conversation.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.chat_bubble_outline, size: 54, color: Color(0xFF94A3B8)),
            SizedBox(height: 12),
            Text(
              'No conversations yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Once customers message you, conversations will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
