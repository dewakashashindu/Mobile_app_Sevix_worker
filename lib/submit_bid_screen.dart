import 'dart:async';

import 'package:flutter/material.dart';

import 'bid_status_screen.dart';
import 'press_scale.dart';
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

  int get _suggestedBidPrice {
    final base = widget.job.budgetLkr;
    final urgencyMultiplier = switch (widget.job.urgency) {
      'high' => 1.08,
      'medium' => 1.04,
      _ => 1.00,
    };
    final distanceBoost = (widget.job.distanceKm > 8)
        ? 250
        : (widget.job.distanceKm > 4)
        ? 150
        : 0;

    final suggested = (base * urgencyMultiplier).round() + distanceBoost;
    return suggested;
  }

  Future<void> _showSuccessCheckAnimation() async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Bid submitted',
      barrierColor: Colors.black.withValues(alpha: 0.28),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return const Center(child: _SuccessCheckDialog());
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 180),
    );
  }

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

    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 850), () {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }),
    );
    await _showSuccessCheckAnimation();
    if (!mounted) return;

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
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFECF3FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCFE0FF)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFF1D4ED8)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Suggested bid price: Rs. $_suggestedBidPrice',
                      style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _amountController.text = _suggestedBidPrice.toString();
                      setState(() {});
                    },
                    child: const Text('Use'),
                  ),
                ],
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
            PressScale(
              onTap: _submitting ? null : _submitBid,
              child: SizedBox(
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
                  label: Text(
                    _submitting ? 'Submitting...' : 'Confirm & Submit',
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

class _SuccessCheckDialog extends StatefulWidget {
  const _SuccessCheckDialog();

  @override
  State<_SuccessCheckDialog> createState() => _SuccessCheckDialogState();
}

class _SuccessCheckDialogState extends State<_SuccessCheckDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
    _scale = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 190,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF16A34A),
                size: 54,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Bid Submitted',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
