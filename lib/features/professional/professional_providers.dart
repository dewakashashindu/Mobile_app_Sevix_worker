import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import 'package:sevix_worker/features/jobs/worker_job.dart';
import 'package:sevix_worker/features/professional/mock_worker_repository.dart';
import 'package:sevix_worker/features/professional/professional_models.dart';

final mockWorkerRepositoryProvider = Provider<MockWorkerRepository>((ref) {
  return MockWorkerRepository();
});

class AiBidSuggestionState {
  final bool loading;
  final AiBidSuggestion? suggestion;

  const AiBidSuggestionState({required this.loading, required this.suggestion});

  AiBidSuggestionState copyWith({bool? loading, AiBidSuggestion? suggestion}) {
    return AiBidSuggestionState(
      loading: loading ?? this.loading,
      suggestion: suggestion ?? this.suggestion,
    );
  }
}

class AiBidSuggestionNotifier extends StateNotifier<AiBidSuggestionState> {
  final MockWorkerRepository _repository;

  AiBidSuggestionNotifier(this._repository)
    : super(const AiBidSuggestionState(loading: false, suggestion: null));

  Future<void> load(WorkerJob job) async {
    state = state.copyWith(loading: true);
    final response = await _repository.getBidSuggestion(job);
    state = state.copyWith(loading: false, suggestion: response);
  }
}

final aiBidSuggestionProvider =
    StateNotifierProvider.autoDispose<
      AiBidSuggestionNotifier,
      AiBidSuggestionState
    >((ref) {
      return AiBidSuggestionNotifier(ref.read(mockWorkerRepositoryProvider));
    });

class AnalyticsNotifier extends StateNotifier<AsyncValue<AnalyticsData>> {
  final MockWorkerRepository _repository;

  AnalyticsNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.getAnalytics);
  }
}

final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AsyncValue<AnalyticsData>>((ref) {
      return AnalyticsNotifier(ref.read(mockWorkerRepositoryProvider));
    });

class ScheduleNotifier
    extends StateNotifier<AsyncValue<List<JobScheduleItem>>> {
  final MockWorkerRepository _repository;

  ScheduleNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.getScheduleItems);
  }
}

final scheduleProvider =
    StateNotifierProvider<ScheduleNotifier, AsyncValue<List<JobScheduleItem>>>((
      ref,
    ) {
      return ScheduleNotifier(ref.read(mockWorkerRepositoryProvider));
    });

class PortfolioNotifier extends StateNotifier<AsyncValue<List<PortfolioItem>>> {
  final MockWorkerRepository _repository;

  PortfolioNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.getPortfolioItems);
  }

  Future<void> addItem(PortfolioItem item) async {
    final current = state.valueOrNull ?? const <PortfolioItem>[];
    state = AsyncValue.data([...current, item]);
  }
}

final portfolioProvider =
    StateNotifierProvider<PortfolioNotifier, AsyncValue<List<PortfolioItem>>>((
      ref,
    ) {
      return PortfolioNotifier(ref.read(mockWorkerRepositoryProvider));
    });

class SubscriptionNotifier
    extends StateNotifier<AsyncValue<List<SubscriptionPlan>>> {
  final MockWorkerRepository _repository;

  SubscriptionNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.getPlans);
  }
}

final subscriptionProvider =
    StateNotifierProvider<
      SubscriptionNotifier,
      AsyncValue<List<SubscriptionPlan>>
    >((ref) {
      return SubscriptionNotifier(ref.read(mockWorkerRepositoryProvider));
    });

class FeaturedListingNotifier extends StateNotifier<FeaturedListingState> {
  FeaturedListingNotifier()
    : super(const FeaturedListingState(boostEnabled: false, hours: 24));

  void toggleBoost(bool value) {
    state = state.copyWith(boostEnabled: value);
  }

  void setHours(int value) {
    state = state.copyWith(hours: value);
  }
}

final featuredListingProvider =
    StateNotifierProvider<FeaturedListingNotifier, FeaturedListingState>((ref) {
      return FeaturedListingNotifier();
    });

class TrustScoreNotifier
    extends StateNotifier<AsyncValue<TrustScoreBreakdown>> {
  final MockWorkerRepository _repository;

  TrustScoreNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.getTrustBreakdown);
  }
}

final trustScoreProvider =
    StateNotifierProvider<TrustScoreNotifier, AsyncValue<TrustScoreBreakdown>>((
      ref,
    ) {
      return TrustScoreNotifier(ref.read(mockWorkerRepositoryProvider));
    });

class NotificationPrefsNotifier extends StateNotifier<NotificationPreferences> {
  NotificationPrefsNotifier()
    : super(
        const NotificationPreferences(
          newJobsInRadius: true,
          paymentReceived: true,
          chatMessages: true,
          bidUpdates: true,
        ),
      );

  void setNewJobs(bool value) {
    state = state.copyWith(newJobsInRadius: value);
  }

  void setPayment(bool value) {
    state = state.copyWith(paymentReceived: value);
  }

  void setChat(bool value) {
    state = state.copyWith(chatMessages: value);
  }

  void setBidUpdates(bool value) {
    state = state.copyWith(bidUpdates: value);
  }
}

final notificationPrefsProvider =
    StateNotifierProvider<NotificationPrefsNotifier, NotificationPreferences>((
      ref,
    ) {
      return NotificationPrefsNotifier();
    });

class BiometricAuthNotifier extends StateNotifier<BiometricAuthState> {
  final LocalAuthentication _localAuth;

  BiometricAuthNotifier(this._localAuth)
    : super(const BiometricAuthState(enabled: false, message: 'Disabled'));

  Future<void> toggle(bool value) async {
    if (!value) {
      state = state.copyWith(enabled: false, message: 'Disabled');
      return;
    }

    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      if (!canCheck || !supported) {
        state = state.copyWith(
          enabled: false,
          message: 'Biometrics unavailable on this device (mock mode).',
        );
        return;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Enable biometric unlock for SEVIX Worker',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: false,
        ),
      );
      state = state.copyWith(
        enabled: authenticated,
        message: authenticated ? 'Enabled' : 'Authentication canceled',
      );
    } catch (_) {
      state = state.copyWith(
        enabled: false,
        message: 'Biometric check failed (mock fallback).',
      );
    }
  }
}

final biometricAuthProvider =
    StateNotifierProvider<BiometricAuthNotifier, BiometricAuthState>((ref) {
      return BiometricAuthNotifier(LocalAuthentication());
    });
