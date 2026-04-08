import 'package:flutter/material.dart';

class PaymentHistoryScreen extends StatelessWidget {
  final String selectedLanguage;

  const PaymentHistoryScreen({super.key, this.selectedLanguage = 'en'});

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
    final payments = [
      _PaymentRecord(
        title: 'Kitchen Pipe Repair',
        customer: 'Nimal Perera',
        amount: 4200,
        date: 'Today, 2:40 PM',
        escrowStatus: 'pending',
      ),
      _PaymentRecord(
        title: 'AC Wiring Fix',
        customer: 'Kamala Silva',
        amount: 3200,
        date: 'Apr 06, 11:15 AM',
        escrowStatus: 'released',
      ),
      _PaymentRecord(
        title: 'Bathroom Leak Service',
        customer: 'Sunil Fernando',
        amount: 5000,
        date: 'Apr 05, 7:05 PM',
        escrowStatus: 'in-review',
      ),
      _PaymentRecord(
        title: 'Door Handle Replacement',
        customer: 'Tharushi Jayasekara',
        amount: 2800,
        date: 'Apr 04, 5:20 PM',
        escrowStatus: 'released',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      appBar: AppBar(
        title: Text(_t('Payment History', 'ගෙවීම් ඉතිහාසය', 'கட்டண வரலாறு')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _summaryTile(
                    title: _t('Total', 'එකතුව', 'மொத்தம்'),
                    value: 'Rs. 15,200',
                    color: const Color(0xFF0B1533),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _summaryTile(
                    title: _t(
                      'Escrow Pending',
                      'Escrow පොරොත්තුවෙන්',
                      'Escrow நிலுவை',
                    ),
                    value: 'Rs. 9,200',
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _summaryTile(
                    title: _t('Released', 'නිදහස් කළ', 'விடுவிக்கப்பட்டது'),
                    value: 'Rs. 6,000',
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...payments.map(
            (payment) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                payment.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_t('Customer', 'පාරිභෝගිකයා', 'வாடிக்கையாளர்')}: ${payment.customer}',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _escrowBadge(payment.escrowStatus),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Rs. ${payment.amount}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0B1533),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          payment.date,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
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
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _escrowBadge(String status) {
    late final Color color;
    late final String label;

    switch (status) {
      case 'released':
        color = const Color(0xFF16A34A);
        label = _t(
          'Escrow Released',
          'Escrow නිදහස්',
          'Escrow விடுவிக்கப்பட்டது',
        );
        break;
      case 'in-review':
        color = const Color(0xFF2563EB);
        label = _t('Under Review', 'සමාලෝචනයේ', 'மதிப்பாய்வில்');
        break;
      case 'pending':
      default:
        color = const Color(0xFFF59E0B);
        label = _t('Escrow Pending', 'Escrow පොරොත්තුවෙන්', 'Escrow நிலுவை');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PaymentRecord {
  final String title;
  final String customer;
  final int amount;
  final String date;
  final String escrowStatus;

  const _PaymentRecord({
    required this.title,
    required this.customer,
    required this.amount,
    required this.date,
    required this.escrowStatus,
  });
}

