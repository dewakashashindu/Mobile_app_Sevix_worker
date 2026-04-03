import 'package:flutter/material.dart';

import 'bid_status_screen.dart';
import 'worker_job.dart';

class SubmitBidScreen extends StatefulWidget {
  final WorkerJob job;

  const SubmitBidScreen({super.key, required this.job});

  @override
  State<SubmitBidScreen> createState() => _SubmitBidScreenState();
}

class _SubmitBidScreenState extends State<SubmitBidScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _etaController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.job.budgetLkr.toString();
    _etaController.text = widget.job.estimatedTime;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _etaController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitBid() async {
    final amount = int.tryParse(_amountController.text.trim());
    final eta = _etaController.text.trim();
    final note = _noteController.text.trim();

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid bid amount')));
      return;
    }

    if (eta.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter ETA / completion duration')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    setState(() {
      _submitting = false;
    });

    final statuses = ['Pending', 'Accepted', 'Rejected'];
    final status = statuses[DateTime.now().second % 3];

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BidStatusScreen(
          job: widget.job,
          bidAmount: amount,
          eta: eta,
          note: note,
          status: status,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Bid')),
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
                    Text(
                      '${widget.job.category} - ${widget.job.customerName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Customer budget: Rs. ${widget.job.budgetLkr}'),
                    const SizedBox(height: 4),
                    Text('Location: ${widget.job.location}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Bid Amount (LKR)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _etaController,
              decoration: const InputDecoration(
                labelText: 'ETA / Completion Duration',
                hintText: 'e.g. 1-2 hours',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Optional Note',
                hintText: 'Add details for the customer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submitBid,
                icon: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_submitting ? 'Submitting...' : 'Confirm & Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
