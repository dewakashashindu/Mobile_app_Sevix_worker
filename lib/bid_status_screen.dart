import 'package:flutter/material.dart';

import 'worker_job.dart';

class BidStatusScreen extends StatelessWidget {
  final WorkerJob job;
  final int bidAmount;
  final String eta;
  final String note;
  final String status;
  final String selectedLanguage;

  const BidStatusScreen({
    super.key,
    required this.job,
    required this.bidAmount,
    required this.eta,
    required this.note,
    required this.status,
    this.selectedLanguage = 'en',
  });

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

  Color _statusColor() {
    switch (status) {
      case 'Accepted':
        return const Color(0xFF10B981);
      case 'Rejected':
        return const Color(0xFFEF4444);
      case 'Pending':
      default:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _statusIcon() {
    switch (status) {
      case 'Accepted':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.cancel;
      case 'Pending':
      default:
        return Icons.schedule;
    }
  }

  String _statusLabel() {
    switch (status) {
      case 'Accepted':
        return _t('Accepted', 'පිළිගන්නා ලදී', 'ஏற்கப்பட்டது');
      case 'Rejected':
        return _t('Rejected', 'ප්‍රතික්ෂේප කරන ලදී', 'நிராகரிக்கப்பட்டது');
      case 'Pending':
      default:
        return _t('Pending', 'පොරොත්තු', 'நிலுவையில்');
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return Scaffold(
      appBar: AppBar(
        title: Text(_t('Bid Status', 'ලංසු තත්ත්වය', 'ஏலம் நிலை')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(_statusIcon(), color: color, size: 36),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t(
                            'Current Bid Status',
                            'වර්තමාන ලංසු තත්ත්වය',
                            'தற்போதைய ஏல நிலை',
                          ),
                          style: TextStyle(color: Colors.black54),
                        ),
                        Text(
                          _statusLabel(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${job.category} • ${job.customerName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_t('Your Bid', 'ඔබගේ ලංසුව', 'உங்கள் ஏலம்')}: Rs. $bidAmount',
                    ),
                    const SizedBox(height: 4),
                    Text('${_t('ETA', 'ETA', 'ETA')}: $eta'),
                    const SizedBox(height: 4),
                    if (note.isNotEmpty)
                      Text('${_t('Note', 'සටහන', 'குறிப்பு')}: $note'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(
                  _t(
                    'Back To Home',
                    'මුල් පිටුවට යන්න',
                    'முகப்புக்கு திரும்பு',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
