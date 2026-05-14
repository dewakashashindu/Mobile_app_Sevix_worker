import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  final String selectedLanguage;
  final VoidCallback onBack;

  const NotificationsScreen({
    super.key,
    required this.selectedLanguage,
    required this.onBack,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _filter = 'all';

  String get _language => widget.selectedLanguage;

  String _title() {
    switch (_language) {
      case 'si':
        return 'දැනුම්දීම්';
      case 'ta':
        return 'அறிவிப்புகள்';
      default:
        return 'Notifications';
    }
  }

  String _filterLabel(String key) {
    if (_language == 'si') {
      switch (key) {
        case 'all':
          return 'සියල්ල';
        case 'job':
          return 'රැකියා';
        case 'bid':
          return 'බිඩ්';
        case 'reminder':
          return 'මතක් කිරීම්';
        case 'payout':
          return 'ගෙවීම්';
      }
    }

    if (_language == 'ta') {
      switch (key) {
        case 'all':
          return 'அனைத்தும்';
        case 'job':
          return 'வேலை';
        case 'bid':
          return 'பிட்';
        case 'reminder':
          return 'நினைவூட்டல்';
        case 'payout':
          return 'செலுத்தல்';
      }
    }

    switch (key) {
      case 'all':
        return 'All';
      case 'job':
        return 'Job Alerts';
      case 'bid':
        return 'Bid Updates';
      case 'reminder':
        return 'Reminders';
      case 'payout':
        return 'Payouts';
      default:
        return key;
    }
  }

  List<_WorkerNotification> get _items {
    final data = [
      _WorkerNotification(
        type: 'job',
        title: _language == 'en'
            ? 'New Plumbing Job Nearby'
            : _language == 'si'
            ? 'නව ප්ලම්බිං රැකියාවක් ඔබට ලඟදී'
            : 'அருகில் புதிய பிளம்பிங் வேலை',
        body: _language == 'en'
            ? 'Nugegoda • Rs. 2,500 • 2.3 km away'
            : _language == 'si'
            ? 'නුගේගොඩ • Rs. 2,500 • 2.3 km දුරින්'
            : 'நுகேகொட • Rs. 2,500 • 2.3 km தொலைவில்',
        time: '2m ago',
        isRead: false,
      ),
      _WorkerNotification(
        type: 'bid',
        title: _language == 'en'
            ? 'Bid Accepted'
            : _language == 'si'
            ? 'බිඩ් එක පිළිගත්තා'
            : 'பிட் ஏற்கப்பட்டது',
        body: _language == 'en'
            ? 'Your bid for Electrical Service was accepted.'
            : _language == 'si'
            ? 'විදුලි සේවාව සඳහා ඔබගේ බිඩ් එක පිළිගන්නා ලදී.'
            : 'மின்சார சேவைக்கான உங்கள் பிட் ஏற்கப்பட்டது.',
        time: '18m ago',
        isRead: false,
      ),
      _WorkerNotification(
        type: 'bid',
        title: _language == 'en'
            ? 'Bid Rejected'
            : _language == 'si'
            ? 'බිඩ් එක ප්‍රතික්ෂේප විය'
            : 'பிட் நிராகரிக்கப்பட்டது',
        body: _language == 'en'
            ? 'Your bid for Carpentry Job was not selected.'
            : _language == 'si'
            ? 'කාපෙන්ට්‍රි රැකියාව සඳහා ඔබගේ බිඩ් එක තෝරා නොගත්තා.'
            : 'மர வேலைக்கான உங்கள் பிட் தேர்வு செய்யப்படவில்லை.',
        time: '1h ago',
        isRead: true,
      ),
      _WorkerNotification(
        type: 'reminder',
        title: _language == 'en'
            ? 'Job Reminder'
            : _language == 'si'
            ? 'රැකියා මතක් කිරීම'
            : 'வேலை நினைவூட்டல்',
        body: _language == 'en'
            ? 'Upcoming service starts in 30 minutes.'
            : _language == 'si'
            ? 'ඊළඟ සේවාව විනාඩි 30 කින් ආරම්භ වේ.'
            : 'அடுத்த சேவை 30 நிமிடங்களில் தொடங்கும்.',
        time: '3h ago',
        isRead: true,
      ),
      _WorkerNotification(
        type: 'payout',
        title: _language == 'en'
            ? 'Payout Processed'
            : _language == 'si'
            ? 'ගෙවීම සම්පූර්ණයි'
            : 'செலுத்தல் நிறைவு செய்யப்பட்டது',
        body: _language == 'en'
            ? 'Rs. 5,000 has been transferred to your bank account.'
            : _language == 'si'
            ? 'Rs. 5,000 ඔබගේ බැංකු ගිණුමට මාරු කරන ලදී.'
            : 'Rs. 5,000 உங்கள் வங்கி கணக்கிற்கு மாற்றப்பட்டது.',
        time: 'Yesterday',
        isRead: true,
      ),
    ];

    if (_filter == 'all') {
      return data;
    }

    return data.where((e) => e.type == _filter).toList();
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'job':
        return const Color(0xFF1E88E5);
      case 'bid':
        return const Color(0xFF8E24AA);
      case 'reminder':
        return const Color(0xFFF59E0B);
      case 'payout':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'job':
        return Icons.work_outline;
      case 'bid':
        return Icons.gavel_outlined;
      case 'reminder':
        return Icons.alarm_outlined;
      case 'payout':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final unread = items.where((e) => !e.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(_title()),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _language == 'en'
                        ? 'All notifications marked as read'
                        : _language == 'si'
                        ? 'සියලු දැනුම්දීම් කියවූ ලෙස සලකුණු කරන ලදී'
                        : 'அனைத்து அறிவிப்புகளும் படித்ததாக குறிக்கப்பட்டது',
                  ),
                ),
              );
            },
            child: Text(
              _language == 'en'
                  ? 'Mark all read'
                  : _language == 'si'
                  ? 'සියල්ල කියවූ ලෙස'
                  : 'அனைத்தையும் படித்தது',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _language == 'en'
                      ? 'You have $unread unread updates'
                      : _language == 'si'
                      ? 'ඔබට නොකියවූ යාවත්කාලීන $unread ක් ඇත'
                      : 'உங்களிடம் $unread படிக்காத புதுப்பிப்புகள் உள்ளன',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['all', 'job', 'bid', 'reminder', 'payout']
                      .map(
                        (type) => ChoiceChip(
                          label: Text(_filterLabel(type)),
                          selected: _filter == type,
                          onSelected: (_) => setState(() => _filter = type),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      _language == 'en'
                          ? 'No notifications'
                          : _language == 'si'
                          ? 'දැනුම්දීම් නැත'
                          : 'அறிவிப்புகள் இல்லை',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final color = _typeColor(item.type);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.14),
                            child: Icon(_typeIcon(item.type), color: color),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: item.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text('${item.body}\n${item.time}'),
                          ),
                          trailing: item.isRead
                              ? null
                              : const Icon(
                                  Icons.brightness_1,
                                  size: 10,
                                  color: Color(0xFF1E88E5),
                                ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _WorkerNotification {
  final String type; // job | bid | reminder | payout
  final String title;
  final String body;
  final String time;
  final bool isRead;

  const _WorkerNotification({
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
  });
}
