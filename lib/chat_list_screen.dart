import 'package:flutter/material.dart';

import 'chat_detail_screen.dart';
import 'chat_models.dart';
import 'error_state_view.dart';
import 'shimmer_skeleton.dart';

class ChatListScreen extends StatefulWidget {
  final String selectedLanguage;

  const ChatListScreen({super.key, this.selectedLanguage = 'en'});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  LoadErrorType? _errorType;

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

  List<ChatConversation> get _seedConversations => [
    ChatConversation(
      id: 'c1',
      name: 'Nimal Perera',
      lastMessage: _t(
        'Please come by 6 PM for the repair.',
        'කරුණාකර අලුත්වැඩියාව සඳහා සවස 6ට එන්න.',
        'பழுதுபார்ப்புக்காக மாலை 6 மணிக்கு வரவும்.',
      ),
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      unreadCount: 2,
      avatarColor: const Color(0xFF1D4ED8),
      initials: 'NP',
      messages: [
        ChatMessage(
          id: 'm1',
          type: ChatMessageType.text,
          text: _t(
            'Hi, are you available this evening?',
            'හෙලෝ, අද සවස ඔබ ලබාගත හැකිද?',
            'வணக்கம், இன்று மாலை நீங்கள் கிடைக்குமா?',
          ),
          isMe: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 17)),
          deliveryStatus: ChatDeliveryStatus.read,
        ),
        ChatMessage(
          id: 'm2',
          type: ChatMessageType.text,
          text: _t(
            'Yes, I am available. What time works for you?',
            'ඔව්, මම ලබාගත හැක. ඔබට සුදුසු වේලාව කුමක්ද?',
            'ஆம், நான் கிடைக்கிறேன். உங்களுக்கு ஏற்ற நேரம் என்ன?',
          ),
          isMe: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          deliveryStatus: ChatDeliveryStatus.read,
        ),
        ChatMessage(
          id: 'm3',
          type: ChatMessageType.image,
          text: _t('Issue photo', 'ගැටලුවේ ඡායාරූපය', 'பிரச்சனை படம்'),
          isMe: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 14)),
          deliveryStatus: ChatDeliveryStatus.read,
        ),
      ],
    ),
    ChatConversation(
      id: 'c2',
      name: 'Kamala Silva',
      lastMessage: _t(
        'Thank you. Waiting for your arrival.',
        'ස්තූතියි. ඔබ පැමිණෙන තුරු බලා සිටිමි.',
        'நன்றி. உங்கள் வருகைக்காக காத்திருக்கிறேன்.',
      ),
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 8)),
      unreadCount: 0,
      avatarColor: const Color(0xFF0EA5E9),
      initials: 'KS',
      messages: [
        ChatMessage(
          id: 'm4',
          type: ChatMessageType.text,
          text: _t(
            'I have reached nearby. Will be there in 10 minutes.',
            'මම ආසන්නයට පැමිණියා. මිනිත්තු 10කින් එන්නම්.',
            'நான் அருகில் வந்துவிட்டேன். 10 நிமிடத்தில் அங்கு வருவேன்.',
          ),
          isMe: true,
          timestamp: DateTime.now().subtract(
            const Duration(hours: 1, minutes: 12),
          ),
          deliveryStatus: ChatDeliveryStatus.delivered,
        ),
        ChatMessage(
          id: 'm5',
          type: ChatMessageType.text,
          text: _t(
            'Thank you. Waiting for your arrival.',
            'ස්තූතියි. ඔබ පැමිණෙන තුරු බලා සිටිමි.',
            'நன்றி. உங்கள் வருகைக்காக காத்திருக்கிறேன்.',
          ),
          isMe: false,
          timestamp: DateTime.now().subtract(
            const Duration(hours: 1, minutes: 8),
          ),
          deliveryStatus: ChatDeliveryStatus.read,
        ),
      ],
    ),
    ChatConversation(
      id: 'c3',
      name: 'Sunil Fernando',
      lastMessage: _t(
        'Can you share an updated quote?',
        'යාවත්කාලීන මිල ගණන් බෙදාගත හැකිද?',
        'புதுப்பிக்கப்பட்ட விலையை பகிர முடியுமா?',
      ),
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      unreadCount: 1,
      avatarColor: const Color(0xFF7C3AED),
      initials: 'SF',
      messages: [
        ChatMessage(
          id: 'm6',
          type: ChatMessageType.text,
          text: _t(
            'Can you share an updated quote?',
            'යාවත්කාලීන මිල ගණන් බෙදාගත හැකිද?',
            'புதுப்பிக்கப்பட்ட விலையை பகிர முடியுமா?',
          ),
          isMe: false,
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
          deliveryStatus: ChatDeliveryStatus.delivered,
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
      appBar: AppBar(title: Text(_t('Chats', 'සංවාද', 'அரட்டைகள்'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: _t(
                  'Search conversations',
                  'සංවාද සොයන්න',
                  'உரையாடல்களை தேடுங்கள்',
                ),
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
            child: RefreshIndicator(
              onRefresh: _loadConversations,
              child: _isLoading
                  ? ShimmerSkeleton(
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
                      children: [
                        const SizedBox(height: 60),
                        ErrorStateView(
                          type: _errorType!,
                          onRetry: _loadConversations,
                          selectedLanguage: widget.selectedLanguage,
                        ),
                      ],
                    )
                  : conversations.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
                      children: [
                        const SizedBox(height: 60),
                        _ChatEmptyState(
                          selectedLanguage: widget.selectedLanguage,
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                                builder: (_) => ChatDetailScreen(
                                  conversation: chat,
                                  selectedLanguage: widget.selectedLanguage,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
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
  final String selectedLanguage;

  const _ChatEmptyState({required this.selectedLanguage});

  String _t(String en, String si, String ta) {
    switch (selectedLanguage) {
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
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 54,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12),
            Text(
              _t(
                'No conversations yet',
                'තවම සංවාද නොමැත',
                'இன்னும் உரையாடல்கள் இல்லை',
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _t(
                'Once customers message you, conversations will appear here.',
                'පාරිභෝගිකයන් පණිවිඩ යැවූ විට, සංවාද මෙහි පෙන්වයි.',
                'வாடிக்கையாளர்கள் செய்தி அனுப்பியதும், உரையாடல்கள் இங்கே தோன்றும்.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
