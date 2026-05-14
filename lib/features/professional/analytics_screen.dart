import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sevix_worker/features/professional/professional_models.dart';
import 'package:sevix_worker/features/professional/professional_providers.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  AnalyticsTab _tab = AnalyticsTab.earnings;

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Dashboard')),
      body: analyticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Unable to load analytics')),
        data: (data) {
          return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SegmentedButton<AnalyticsTab>(
                      segments: const [
                        ButtonSegment(
                          value: AnalyticsTab.earnings,
                          label: Text('Earnings'),
                          icon: Icon(Icons.payments_outlined),
                        ),
                        ButtonSegment(
                          value: AnalyticsTab.bidSuccess,
                          label: Text('Bid Success'),
                          icon: Icon(Icons.trending_up),
                        ),
                        ButtonSegment(
                          value: AnalyticsTab.ratings,
                          label: Text('Ratings'),
                          icon: Icon(Icons.star_outline),
                        ),
                      ],
                      selected: {_tab},
                      onSelectionChanged: (set) {
                        setState(() {
                          _tab = set.first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: switch (_tab) {
                        AnalyticsTab.earnings => _EarningsView(data: data),
                        AnalyticsTab.bidSuccess => _BidSuccessView(data: data),
                        AnalyticsTab.ratings => _RatingsView(data: data),
                      },
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 320.ms)
              .slideY(begin: 0.08, end: 0, duration: 320.ms);
        },
      ),
    );
  }
}

class _EarningsView extends StatelessWidget {
  final AnalyticsData data;

  const _EarningsView({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxAmount = data.weeklyEarnings
        .map((e) => e.amount)
        .reduce(max)
        .toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Earnings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.weeklyEarnings.map((point) {
                  final ratio = (point.amount / maxAmount).clamp(0.0, 1.0);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${point.amount ~/ 1000}k',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Flexible(
                            child: FractionallySizedBox(
                              heightFactor: ratio,
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0B1533),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(point.day),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BidSuccessView extends StatelessWidget {
  final AnalyticsData data;

  const _BidSuccessView({required this.data});

  @override
  Widget build(BuildContext context) {
    final ratePercent = (data.bidAcceptanceRate * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bid Acceptance Rate',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 170,
                  height: 170,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: data.bidAcceptanceRate,
                        strokeWidth: 14,
                        backgroundColor: const Color(0xFFE2E8F0),
                        color: const Color(0xFF16A34A),
                      ),
                      Text(
                        '$ratePercent%',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Text(
              'Keep response times fast to improve conversion.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingsView extends StatelessWidget {
  final AnalyticsData data;

  const _RatingsView({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rating Trend (Last 30 days)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: CustomPaint(
                painter: _LineChartPainter(data.ratingTrend),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<RatingTrendPoint> points;

  _LineChartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      return;
    }

    const minRating = 3.5;
    const maxRating = 5.0;

    final linePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = (size.width / (points.length - 1)) * i;
      final normalized =
          (points[i].rating - minRating) / (maxRating - minRating);
      final y = size.height - (normalized.clamp(0.0, 1.0) * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
