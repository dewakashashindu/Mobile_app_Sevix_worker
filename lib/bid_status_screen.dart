import 'package:flutter/material.dart';

import 'worker_job.dart';

class BidStatusScreen extends StatelessWidget {
  final WorkerJob job;
  final int bidAmount;
  final String eta;
  final String note;
  final String status;

  const BidStatusScreen({
    super.key,
    required this.job,
    required this.bidAmount,
    required this.eta,
    required this.note,
    required this.status,
  });

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

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return Scaffold(
      appBar: AppBar(title: const Text('Bid Status')),
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
                        const Text(
                          'Current Bid Status',
                          style: TextStyle(color: Colors.black54),
                        ),
                        Text(
                          status,
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
                    Text('Your Bid: Rs. $bidAmount'),
                    const SizedBox(height: 4),
                    Text('ETA: $eta'),
                    const SizedBox(height: 4),
                    if (note.isNotEmpty) Text('Note: $note'),
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
                child: const Text('Back To Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
