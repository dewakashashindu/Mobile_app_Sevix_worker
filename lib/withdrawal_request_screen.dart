import 'package:flutter/material.dart';

class WithdrawalRequestScreen extends StatefulWidget {
  final String selectedLanguage;
  final int availableBalance;

  const WithdrawalRequestScreen({
    super.key,
    required this.selectedLanguage,
    required this.availableBalance,
  });

  @override
  State<WithdrawalRequestScreen> createState() =>
      _WithdrawalRequestScreenState();
}

class _WithdrawalRequestScreenState extends State<WithdrawalRequestScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _method = 'bank';

  String get _language => widget.selectedLanguage;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _title() {
    switch (_language) {
      case 'si':
        return 'මුදල් ඉල්ලීම';
      case 'ta':
        return 'பணம் பெற கோரிக்கை';
      default:
        return 'Withdrawal Request';
    }
  }

  String _submitLabel() {
    switch (_language) {
      case 'si':
        return 'ඉල්ලීම යවන්න';
      case 'ta':
        return 'கோரிக்கையை அனுப்பு';
      default:
        return 'Submit Request';
    }
  }

  void _submit() {
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _language == 'en'
                ? 'Enter a valid amount'
                : _language == 'si'
                ? 'වලංගු මුදලක් ඇතුළත් කරන්න'
                : 'சரியான தொகையை உள்ளிடவும்',
          ),
        ),
      );
      return;
    }

    if (amount > widget.availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _language == 'en'
                ? 'Amount exceeds available balance'
                : _language == 'si'
                ? 'මුදල ලබාගත හැකි ශේෂයට වඩා වැඩිය'
                : 'தொகை கிடைக்கும் இருப்பை மீறுகிறது',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _language == 'en'
              ? 'Withdrawal request submitted'
              : _language == 'si'
              ? 'මුදල් ඉල්ලීම යවන ලදී'
              : 'பணம் பெறும் கோரிக்கை அனுப்பப்பட்டது',
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      appBar: AppBar(title: Text(_title())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Balance',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs. ${widget.availableBalance}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0B1533),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount (LKR)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _method,
                      items: const [
                        DropdownMenuItem(
                          value: 'bank',
                          child: Text('Bank Transfer'),
                        ),
                        DropdownMenuItem(
                          value: 'mobile',
                          child: Text('Mobile Wallet'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _method = v);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Withdrawal Method',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Note (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: Text(_submitLabel()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
