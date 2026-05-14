import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sevix_worker/features/jobs/submit_bid_screen.dart';
import 'package:sevix_worker/features/jobs/worker_job.dart';

class JobDetailScreen extends StatefulWidget {
  final WorkerJob job;
  final String selectedLanguage;

  const JobDetailScreen({
    super.key,
    required this.job,
    this.selectedLanguage = 'en',
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

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
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final diff = widget.job.bidDeadline.difference(now);
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _durationText(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      appBar: AppBar(
        title: Text(_t('Job Details', 'වැඩ විස්තර', 'வேலை விவரங்கள்')),
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
                      '${job.category} ${_t('Request', 'ඉල්ලීම', 'கோரிக்கை')}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_t('Customer', 'පාරිභෝගිකයා', 'வாடிக்கையாளர்')}: ${job.customerName}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_t('Budget', 'අයවැය', 'பட்ஜெட்')}: Rs. ${job.budgetLkr}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_t('Estimated Time', 'ඇස්තමේන්තුගත කාලය', 'மதிப்பிடப்பட்ட நேரம்')}: ${job.estimatedTime}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_t('Distance', 'දුර', 'தூரம்')}: ${job.distanceKm.toStringAsFixed(1)} km',
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
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Color(0xFFEF4444)),
                    const SizedBox(width: 8),
                    Text(
                      _t(
                        'Bid window closes in:',
                        'ලංසු කාලය අවසන් වන්නේ:',
                        'ஏல சாளரம் மூடப்படுவது:',
                      ),
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      _durationText(_remaining),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEF4444),
                      ),
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
                      _t('Map', 'සිතියම', 'வரைபடம்'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFDDE8FF), Color(0xFFF6FAFF)],
                        ),
                        border: Border.all(color: const Color(0xFFCFD8EA)),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.map_outlined,
                              size: 44,
                              color: Color(0xFF0B1533),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${job.latitude.toStringAsFixed(4)}, ${job.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _t(
                                'Map integration placeholder',
                                'සිතියම් ඒකාබද්ධ කිරීම සඳහා තාවකාලික පෙන්නුම',
                                'வரைபட ஒருங்கிணைப்புக்கான இடமாற்று',
                              ),
                            ),
                          ],
                        ),
                      ),
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
                      _t(
                        'Customer Note',
                        'පාරිභෝගික සටහන',
                        'வாடிக்கையாளர் குறிப்பு',
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(job.customerNote),
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
                      _t('Photos', 'ඡායාරූප', 'புகைப்படங்கள்'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, i) {
                          final label = job.photoLabels[i];
                          return Container(
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEDEFF5), Color(0xFFF8F9FC)],
                              ),
                              border: Border.all(
                                color: const Color(0xFFDFE2EA),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.photo_camera_back_outlined),
                                const SizedBox(height: 6),
                                Text(
                                  label,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemCount: job.photoLabels.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_remaining == Duration.zero) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _t(
                            'Bid window has closed for this job request.',
                            'මෙම වැඩ ඉල්ලීම සඳහා ලංසු කාලය අවසන් වී ඇත.',
                            'இந்த வேலை கோரிக்கைக்கான ஏல சாளரம் மூடப்பட்டுள்ளது.',
                          ),
                        ),
                      ),
                    );
                    return;
                  }

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SubmitBidScreen(
                        job: job,
                        selectedLanguage: widget.selectedLanguage,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.gavel),
                label: Text(
                  _remaining == Duration.zero
                      ? _t(
                          'Bid Window Closed',
                          'ලංසු කාලය අවසන්',
                          'ஏல சாளரம் மூடப்பட்டது',
                        )
                      : _t('Place Bid', 'ලංසුව තබන්න', 'ஏலம் இடுக'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

