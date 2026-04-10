import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sevix_worker/features/jobs/bid_status_screen.dart';
import 'package:sevix_worker/core/press_scale.dart';
import 'package:sevix_worker/features/jobs/worker_job.dart';
import 'package:sevix_worker/features/professional/professional_providers.dart';

class SubmitBidScreen extends ConsumerStatefulWidget {
  final WorkerJob job;
  final String selectedLanguage;

  const SubmitBidScreen({
    super.key,
    required this.job,
    this.selectedLanguage = 'en',
  });

  @override
  ConsumerState<SubmitBidScreen> createState() => _SubmitBidScreenState();
}

class _SubmitBidScreenState extends ConsumerState<SubmitBidScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _etaController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _submitting = false;

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

  (int, int) get _competitiveRange {
    final min = (widget.job.budgetLkr * 0.9).round();
    final max = (widget.job.budgetLkr * 1.12).round();
    return (min, max);
  }

  Future<void> _showSuccessCheckAnimation() async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: _t(
        'Bid submitted',
        'ලංසුව යොමු කරන ලදී',
        'ஏலம் சமர்ப்பிக்கப்பட்டது',
      ),
      barrierColor: Colors.black.withValues(alpha: 0.28),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Center(
          child: _SuccessCheckDialog(
            label: _t(
              'Bid Submitted',
              'ලංසුව යොමු කරන ලදී',
              'ஏலம் சமர்ப்பிக்கப்பட்டது',
            ),
          ),
        );
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
    unawaited(ref.read(aiBidSuggestionProvider.notifier).load(widget.job));
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'Enter a valid bid amount',
              'වලංගු ලංසු මුදලක් ඇතුළත් කරන්න',
              'சரியான ஏலத் தொகையை உள்ளிடவும்',
            ),
          ),
        ),
      );
      return;
    }

    if (eta.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'Enter ETA / completion duration',
              'ETA / අවසන් කාලය ඇතුළත් කරන්න',
              'ETA / முடிக்கும் காலத்தை உள்ளிடவும்',
            ),
          ),
        ),
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
    unawaited(HapticFeedback.mediumImpact());

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
          selectedLanguage: widget.selectedLanguage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiBidSuggestionProvider);
    final aiSuggestion = aiState.suggestion;
    final range = aiSuggestion == null
        ? _competitiveRange
        : (aiSuggestion.minLkr, aiSuggestion.maxLkr);
    final suggestedPrice = aiSuggestion?.recommendedLkr ?? _suggestedBidPrice;

    return Scaffold(
      appBar: AppBar(
        title: Text(_t('Submit Bid', 'ලංසුව යොමු කරන්න', 'ஏலம் சமர்ப்பி')),
      ),
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
                    Text(
                      '${_t('Customer budget', 'පාරිභෝගික අයවැය', 'வாடிக்கையாளர் பட்ஜெட்')}: Rs. ${widget.job.budgetLkr}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_t('Location', 'ස්ථානය', 'இடம்')}: ${widget.job.location}',
                    ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFF1D4ED8)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${aiState.loading ? 'Gemini AI: Analyzing...' : 'Gemini AI'}\n${_t('Recommended Range', 'නිර්දේශිත පරාසය', 'பரிந்துரைக்கப்பட்ட வரம்பு')}: Rs. ${range.$1} - Rs. ${range.$2}\n${_t('Suggested bid', 'නිර්දේශිත ලංසුව', 'பரிந்துரைக்கப்பட்ட ஏலம்')}: Rs. $suggestedPrice',
                      style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _amountController.text = suggestedPrice.toString();
                      setState(() {});
                    },
                    child: Text(
                      _t(
                        'Apply Suggested',
                        'නිර්දේශිත මුදල යොදන්න',
                        'பரிந்துரையைப் பயன்படுத்து',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _t(
                  'Bid Amount (LKR)',
                  'ලංසු මුදල (LKR)',
                  'ஏலத் தொகை (LKR)',
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _etaController,
              decoration: InputDecoration(
                labelText: _t(
                  'ETA / Completion Duration',
                  'ETA / අවසන් කාලය',
                  'ETA / முடிக்கும் நேரம்',
                ),
                hintText: _t(
                  'e.g. 1-2 hours',
                  'උදා: පැය 1-2',
                  'எ.கா: 1-2 மணி நேரம்',
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: _t(
                  'Optional Note',
                  'විකල්ප සටහන',
                  'விருப்ப குறிப்பு',
                ),
                hintText: _t(
                  'Add details for the customer',
                  'පාරිභෝගිකයාට විස්තර එක් කරන්න',
                  'வாடிக்கையாளருக்கான விவரங்களைச் சேர்க்கவும்',
                ),
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
                    _submitting
                        ? _t(
                            'Submitting...',
                            'යොමු කරමින්...',
                            'சமர்ப்பிக்கப்படுகிறது...',
                          )
                        : _t(
                            'Confirm & Submit',
                            'තහවුරු කර යොමු කරන්න',
                            'உறுதி செய்து சமர்ப்பிக்கவும்',
                          ),
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
  final String label;

  const _SuccessCheckDialog({required this.label});

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
            Text(
              widget.label,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
