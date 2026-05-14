import 'package:flutter/material.dart';

enum AnalyticsTab { earnings, bidSuccess, ratings }

class AiBidSuggestion {
  final int minLkr;
  final int maxLkr;
  final int recommendedLkr;
  final String source;

  const AiBidSuggestion({
    required this.minLkr,
    required this.maxLkr,
    required this.recommendedLkr,
    required this.source,
  });
}

class WeeklyEarningPoint {
  final String day;
  final int amount;

  const WeeklyEarningPoint({required this.day, required this.amount});
}

class RatingTrendPoint {
  final int day;
  final double rating;

  const RatingTrendPoint({required this.day, required this.rating});
}

class AnalyticsData {
  final List<WeeklyEarningPoint> weeklyEarnings;
  final double bidAcceptanceRate;
  final List<RatingTrendPoint> ratingTrend;

  const AnalyticsData({
    required this.weeklyEarnings,
    required this.bidAcceptanceRate,
    required this.ratingTrend,
  });
}

enum JobScheduleStatus { confirmed, inProgress }

class JobScheduleItem {
  final String id;
  final String customerName;
  final DateTime start;
  final DateTime end;
  final JobScheduleStatus status;

  const JobScheduleItem({
    required this.id,
    required this.customerName,
    required this.start,
    required this.end,
    required this.status,
  });
}

class PortfolioItem {
  final String id;
  final String imagePath;
  final String caption;
  final String category;
  final bool verified;

  const PortfolioItem({
    required this.id,
    required this.imagePath,
    required this.caption,
    required this.category,
    required this.verified,
  });
}

class SubscriptionPlan {
  final String id;
  final String name;
  final int monthlyLkr;
  final List<String> features;
  final bool current;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.monthlyLkr,
    required this.features,
    required this.current,
  });
}

class FeaturedListingState {
  final bool boostEnabled;
  final int hours;

  const FeaturedListingState({required this.boostEnabled, required this.hours});

  FeaturedListingState copyWith({bool? boostEnabled, int? hours}) {
    return FeaturedListingState(
      boostEnabled: boostEnabled ?? this.boostEnabled,
      hours: hours ?? this.hours,
    );
  }
}

class TrustScoreBreakdown {
  final double punctuality;
  final double completionRate;
  final double verifiedId;
  final double customerRatings;
  final double responseTime;
  final List<String> tips;

  const TrustScoreBreakdown({
    required this.punctuality,
    required this.completionRate,
    required this.verifiedId,
    required this.customerRatings,
    required this.responseTime,
    required this.tips,
  });
}

class NotificationPreferences {
  final bool newJobsInRadius;
  final bool paymentReceived;
  final bool chatMessages;
  final bool bidUpdates;

  const NotificationPreferences({
    required this.newJobsInRadius,
    required this.paymentReceived,
    required this.chatMessages,
    required this.bidUpdates,
  });

  NotificationPreferences copyWith({
    bool? newJobsInRadius,
    bool? paymentReceived,
    bool? chatMessages,
    bool? bidUpdates,
  }) {
    return NotificationPreferences(
      newJobsInRadius: newJobsInRadius ?? this.newJobsInRadius,
      paymentReceived: paymentReceived ?? this.paymentReceived,
      chatMessages: chatMessages ?? this.chatMessages,
      bidUpdates: bidUpdates ?? this.bidUpdates,
    );
  }
}

class BiometricAuthState {
  final bool enabled;
  final String message;

  const BiometricAuthState({required this.enabled, required this.message});

  BiometricAuthState copyWith({bool? enabled, String? message}) {
    return BiometricAuthState(
      enabled: enabled ?? this.enabled,
      message: message ?? this.message,
    );
  }
}

Color scheduleColorFor(JobScheduleStatus status) {
  switch (status) {
    case JobScheduleStatus.confirmed:
      return const Color(0xFF16A34A);
    case JobScheduleStatus.inProgress:
      return const Color(0xFF2563EB);
  }
}
