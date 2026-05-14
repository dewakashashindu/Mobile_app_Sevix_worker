import 'dart:math';

import 'package:sevix_worker/features/jobs/worker_job.dart';
import 'package:sevix_worker/features/professional/professional_models.dart';

class MockWorkerRepository {
  Future<AiBidSuggestion> getBidSuggestion(WorkerJob job) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final min = (job.budgetLkr * 0.9).round();
    final max = (job.budgetLkr * 1.14).round();
    final recommended = (job.budgetLkr * 1.03).round();
    return AiBidSuggestion(
      minLkr: min,
      maxLkr: max,
      recommendedLkr: recommended,
      source: 'Gemini AI',
    );
  }

  Future<AnalyticsData> getAnalytics() async {
    await Future<void>.delayed(const Duration(milliseconds: 320));
    return AnalyticsData(
      weeklyEarnings: const [
        WeeklyEarningPoint(day: 'Mon', amount: 7600),
        WeeklyEarningPoint(day: 'Tue', amount: 5400),
        WeeklyEarningPoint(day: 'Wed', amount: 8800),
        WeeklyEarningPoint(day: 'Thu', amount: 9200),
        WeeklyEarningPoint(day: 'Fri', amount: 10500),
        WeeklyEarningPoint(day: 'Sat', amount: 12300),
        WeeklyEarningPoint(day: 'Sun', amount: 6400),
      ],
      bidAcceptanceRate: 0.72,
      ratingTrend: List.generate(
        30,
        (index) => RatingTrendPoint(
          day: index + 1,
          rating: 4.2 + (index * 0.02) + sin(index / 2.8) * 0.08,
        ),
      ),
    );
  }

  Future<List<JobScheduleItem>> getScheduleItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    final now = DateTime.now();
    return [
      JobScheduleItem(
        id: 'sch-1',
        customerName: 'Nimal Perera',
        start: DateTime(now.year, now.month, now.day, 9),
        end: DateTime(now.year, now.month, now.day, 11),
        status: JobScheduleStatus.confirmed,
      ),
      JobScheduleItem(
        id: 'sch-2',
        customerName: 'Kamala Silva',
        start: DateTime(now.year, now.month, now.day + 1, 13),
        end: DateTime(now.year, now.month, now.day + 1, 16),
        status: JobScheduleStatus.inProgress,
      ),
      JobScheduleItem(
        id: 'sch-3',
        customerName: 'Sunil Fernando',
        start: DateTime(now.year, now.month, now.day + 3, 8),
        end: DateTime(now.year, now.month, now.day + 3, 10),
        status: JobScheduleStatus.confirmed,
      ),
    ];
  }

  Future<List<PortfolioItem>> getPortfolioItems() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const [
      PortfolioItem(
        id: 'pf-1',
        imagePath: '',
        caption: 'Bathroom Leak Fix',
        category: 'Plumbing',
        verified: true,
      ),
      PortfolioItem(
        id: 'pf-2',
        imagePath: '',
        caption: 'Distribution Board Repair',
        category: 'Electrical',
        verified: false,
      ),
      PortfolioItem(
        id: 'pf-3',
        imagePath: '',
        caption: 'Kitchen Sink Line Replacement',
        category: 'Plumbing',
        verified: true,
      ),
    ];
  }

  Future<List<SubscriptionPlan>> getPlans() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return const [
      SubscriptionPlan(
        id: 'basic',
        name: 'Basic',
        monthlyLkr: 0,
        current: true,
        features: [
          'Standard listing visibility',
          'Basic support',
          'Service fee: 12%',
        ],
      ),
      SubscriptionPlan(
        id: 'professional',
        name: 'Professional',
        monthlyLkr: 4900,
        current: false,
        features: ['Priority support', 'Advanced analytics', 'Service fee: 9%'],
      ),
      SubscriptionPlan(
        id: 'premium',
        name: 'Premium',
        monthlyLkr: 8900,
        current: false,
        features: [
          'Top listing boost credits',
          'Deep analytics + forecast',
          'Service fee: 7%',
        ],
      ),
    ];
  }

  Future<TrustScoreBreakdown> getTrustBreakdown() async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    return const TrustScoreBreakdown(
      punctuality: 0.88,
      completionRate: 0.92,
      verifiedId: 1.0,
      customerRatings: 0.9,
      responseTime: 0.78,
      tips: [
        'Arrive on time for your next 3 jobs to boost score by 5%.',
        'Reply to new chats within 10 minutes to improve response score.',
        'Upload before/after proof photos for every completed job.',
      ],
    );
  }
}
