import 'package:flutter/material.dart';

import 'package:sevix_worker/features/wallet/payment_history_screen.dart';
import 'package:sevix_worker/features/wallet/payout_settings_screen.dart';
import 'package:sevix_worker/features/wallet/withdrawal_request_screen.dart';

class WalletScreen extends StatefulWidget {
  final VoidCallback onBack;
  final String selectedLanguage;

  const WalletScreen({
    super.key,
    required this.onBack,
    required this.selectedLanguage,
  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String _period = 'daily';
  String _txFilter = 'all';

  String get _language => widget.selectedLanguage;

  String _title() {
    switch (_language) {
      case 'si':
        return 'වොලට්';
      case 'ta':
        return 'வாலெட்';
      default:
        return 'Wallet';
    }
  }

  String _earningsTitle() {
    switch (_language) {
      case 'si':
        return 'ආදායම් දසුන';
      case 'ta':
        return 'வருமான பார்வை';
      default:
        return 'Earnings View';
    }
  }

  String _transactionsTitle() {
    switch (_language) {
      case 'si':
        return 'ගනුදෙනු';
      case 'ta':
        return 'பரிவர்த்தனைகள்';
      default:
        return 'Transactions';
    }
  }

  String _periodLabel(String key) {
    if (_language == 'si') {
      switch (key) {
        case 'daily':
          return 'දිනපතා';
        case 'weekly':
          return 'සතිපතා';
        case 'monthly':
          return 'මාසික';
      }
    }

    if (_language == 'ta') {
      switch (key) {
        case 'daily':
          return 'தினசரி';
        case 'weekly':
          return 'வாராந்திர';
        case 'monthly':
          return 'மாதாந்திர';
      }
    }

    switch (key) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return key;
    }
  }

  String _filterLabel(String key) {
    if (_language == 'si') {
      switch (key) {
        case 'all':
          return 'සියල්ල';
        case 'credit':
          return 'ආදායම්';
        case 'payout':
          return 'ගෙවීම්';
      }
    }

    if (_language == 'ta') {
      switch (key) {
        case 'all':
          return 'அனைத்தும்';
        case 'credit':
          return 'வரவு';
        case 'payout':
          return 'செலுத்தல்';
      }
    }

    switch (key) {
      case 'all':
        return 'All';
      case 'credit':
        return 'Credits';
      case 'payout':
        return 'Payouts';
      default:
        return key;
    }
  }

  String _pendingLabel() {
    switch (_language) {
      case 'si':
        return 'පොරොත්තුවෙන් ගෙවීම්';
      case 'ta':
        return 'நிலுவை செலுத்தல்கள்';
      default:
        return 'Pending Payouts';
    }
  }

  String _settledLabel() {
    switch (_language) {
      case 'si':
        return 'සම්පූර්ණ කළ ගෙවීම්';
      case 'ta':
        return 'செலுத்தி முடித்தவை';
      default:
        return 'Settled Payouts';
    }
  }

  String _requestWithdrawLabel() {
    switch (_language) {
      case 'si':
        return 'මුදල් ඉල්ලීම';
      case 'ta':
        return 'பணம் பெற கோரிக்கை';
      default:
        return 'Request Withdrawal';
    }
  }

  String _statementLabel() {
    switch (_language) {
      case 'si':
        return 'වාර්තාව';
      case 'ta':
        return 'அறிக்கை';
      default:
        return 'Statement';
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Map<String, int> get _earningByPeriod {
    switch (_period) {
      case 'weekly':
        return {'gross': 28500, 'jobs': 11, 'avg': 2590, 'available': 18450};
      case 'monthly':
        return {'gross': 125000, 'jobs': 47, 'avg': 2660, 'available': 18450};
      case 'daily':
      default:
        return {'gross': 5400, 'jobs': 2, 'avg': 2700, 'available': 18450};
    }
  }

  List<_WalletTransaction> get _transactions {
    final data = [
      _WalletTransaction(
        title: _language == 'en'
            ? 'Plumbing Service - Nugegoda'
            : _language == 'si'
            ? 'ප්ලම්බිං සේවාව - නුගේගොඩ'
            : 'பிளம்பிங் சேவை - நுகேகொட',
        date: 'Today, 2:40 PM',
        amount: 4200,
        type: 'credit',
      ),
      _WalletTransaction(
        title: _language == 'en'
            ? 'Payout to Bank Account'
            : _language == 'si'
            ? 'බැංකු ගිණුමට ගෙවීම'
            : 'வங்கி கணக்கிற்கு செலுத்தல்',
        date: 'Yesterday, 10:20 AM',
        amount: 5000,
        type: 'payout',
      ),
      _WalletTransaction(
        title: _language == 'en'
            ? 'Electrical Service - Dehiwala'
            : _language == 'si'
            ? 'විදුලි සේවාව - දෙහිවල'
            : 'மின்சார சேவை - தெஹிவள',
        date: 'Apr 02, 6:15 PM',
        amount: 3200,
        type: 'credit',
      ),
      _WalletTransaction(
        title: _language == 'en'
            ? 'Payout to Bank Account'
            : _language == 'si'
            ? 'බැංකු ගිණුමට ගෙවීම'
            : 'வங்கி கணக்கிற்கு செலுத்தல்',
        date: 'Apr 01, 9:00 AM',
        amount: 3800,
        type: 'payout',
      ),
    ];

    if (_txFilter == 'all') {
      return data;
    }

    return data.where((e) => e.type == _txFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final earning = _earningByPeriod;
    final tx = _transactions;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(_title()),
        actions: [
          TextButton.icon(
            onPressed: () => _showMessage(
              _language == 'en'
                  ? 'Statement downloaded'
                  : _language == 'si'
                  ? 'වාර්තාව බාගත කරන ලදී'
                  : 'அறிக்கை பதிவிறக்கப்பட்டது',
            ),
            icon: const Icon(Icons.description_outlined, size: 18),
            label: Text(_statementLabel()),
          ),
          const SizedBox(width: 8),
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
                  _earningsTitle(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: ['daily', 'weekly', 'monthly']
                      .map(
                        (p) => ChoiceChip(
                          label: Text(_periodLabel(p)),
                          selected: _period == p,
                          onSelected: (_) => setState(() => _period = p),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F1D45), Color(0xFF173775)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available Balance',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rs. ${earning['available']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _miniStat('Gross', 'Rs. ${earning['gross']}'),
                          _miniStat('Jobs', '${earning['jobs']}'),
                          _miniStat('Avg/job', 'Rs. ${earning['avg']}'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _payoutStatCard(
                        title: _pendingLabel(),
                        value: 'Rs. 5,200',
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _payoutStatCard(
                        title: _settledLabel(),
                        value: 'Rs. 86,900',
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              PaymentHistoryScreen(selectedLanguage: _language),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: Text(
                      _language == 'si'
                          ? 'Escrow ගෙවීම් ඉතිහාසය'
                          : _language == 'ta'
                          ? 'Escrow கட்டண வரலாறு'
                          : 'Escrow Payment History',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              PayoutSettingsScreen(selectedLanguage: _language),
                        ),
                      );
                    },
                    icon: const Icon(Icons.account_balance),
                    label: Text(
                      _language == 'si'
                          ? 'Stripe ගෙවීම් සැකසුම්'
                          : _language == 'ta'
                          ? 'Stripe பேஅவுட் அமைப்புகள்'
                          : 'Stripe Payout Settings',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WithdrawalRequestScreen(
                            selectedLanguage: _language,
                            availableBalance: earning['available'] ?? 0,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.south_east),
                    label: Text(_requestWithdrawLabel()),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _transactionsTitle(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text('${tx.length} entries'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
            child: Wrap(
              spacing: 8,
              children: ['all', 'credit', 'payout']
                  .map(
                    (type) => ChoiceChip(
                      label: Text(_filterLabel(type)),
                      selected: _txFilter == type,
                      onSelected: (_) => setState(() => _txFilter = type),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: tx.isEmpty
                ? const Center(child: Text('No transactions found.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: tx.length,
                    itemBuilder: (context, index) {
                      final item = tx[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: _transactionTile(item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _payoutStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _transactionTile(_WalletTransaction tx) {
    final isCredit = tx.type == 'credit';
    final amountColor = isCredit
        ? const Color(0xFF0F9D58)
        : const Color(0xFFEF4444);

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: amountColor.withValues(alpha: 0.14),
          child: Icon(
            isCredit ? Icons.call_received : Icons.call_made,
            color: amountColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tx.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                tx.date,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Text(
          '${isCredit ? '+' : '-'} Rs. ${tx.amount}',
          style: TextStyle(fontWeight: FontWeight.w700, color: amountColor),
        ),
      ],
    );
  }
}

class _WalletTransaction {
  final String title;
  final String date;
  final int amount;
  final String type; // credit | payout

  const _WalletTransaction({
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
  });
}
