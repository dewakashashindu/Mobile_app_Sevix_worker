import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:sevix_worker/features/auth/language_select_screen.dart';
import 'package:sevix_worker/features/auth/login_screen.dart';
import 'package:sevix_worker/features/auth/signup_screen.dart';
import 'package:sevix_worker/features/auth/otp_screen.dart';
import 'package:sevix_worker/core/settings_screen.dart';
import 'package:sevix_worker/features/jobs/job_feed_screen.dart';
import 'package:sevix_worker/features/jobs/worker_job.dart';
import 'package:sevix_worker/features/jobs/bid_status_screen.dart';
import 'package:sevix_worker/features/wallet/wallet_screen.dart';
import 'package:sevix_worker/features/communication/notifications_screen.dart';
import 'package:sevix_worker/features/profile/worker_profile_data.dart';
import 'package:sevix_worker/features/communication/chat_list_screen.dart';
import 'package:sevix_worker/features/profile/work_history_screen.dart';
import 'package:sevix_worker/features/profile/professional_profile_screen.dart';
import 'package:sevix_worker/features/execution/job_execution_screen.dart';
import 'package:sevix_worker/features/wallet/payment_history_screen.dart';
import 'package:sevix_worker/features/professional/analytics_screen.dart';
import 'package:sevix_worker/features/professional/schedule_calendar_screen.dart';
import 'package:sevix_worker/features/professional/portfolio_management_screen.dart';
import 'package:sevix_worker/features/professional/subscription_plan_screen.dart';
import 'package:sevix_worker/features/professional/featured_listing_screen.dart';
import 'package:sevix_worker/features/professional/trust_score_detail_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

const Curve kGlobalAnimationCurve = Curves.easeOutExpo;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _setDarkMode(bool enabled) {
    setState(() {
      _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sevix Worker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B1533)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B1533),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: _RootScreen(
        isDarkMode: _themeMode == ThemeMode.dark,
        onThemeToggle: _setDarkMode,
      ),
    );
  }
}

enum _AuthScreen { language, login, signup, otp, authenticated }

enum _TabType { home, bookings, chat, settings }

class JobRequest {
  final String id;
  final String customerName;
  final String serviceType;
  final String location;
  final String distance;
  final String estimatedTime;
  final String payment;
  final String urgency; // 'low' | 'medium' | 'high'

  JobRequest({
    required this.id,
    required this.customerName,
    required this.serviceType,
    required this.location,
    required this.distance,
    required this.estimatedTime,
    required this.payment,
    required this.urgency,
  });
}

class EarningsData {
  final int today;
  final int week;
  final int month;
  final int pending;
  final int completedJobs;

  const EarningsData({
    required this.today,
    required this.week,
    required this.month,
    required this.pending,
    required this.completedJobs,
  });
}

class _RootScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeToggle;

  const _RootScreen({required this.isDarkMode, required this.onThemeToggle});

  @override
  State<_RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<_RootScreen>
    with SingleTickerProviderStateMixin {
  String? _language; // 'en', 'si', 'ta'
  _AuthScreen _authScreen = _AuthScreen.language;
  String _pendingPhoneNumber = '';
  WorkerProfileData _profileData = WorkerProfileData.empty();

  _TabType _activeTab = _TabType.home;
  bool _isOnline = true;

  String _userName = 'Worker';
  String _workerType = 'Plumber';
  String _currentLocation = 'Colombo, Sri Lanka';
  final int _unreadMessages = 3;
  final int _serviceRadius = 5;
  final double _rating = 4.8;
  final int _activeJobsCount = 2;
  String _earningsWindow = 'today';

  late List<JobRequest> _jobRequests;
  late EarningsData _earnings;
  late final AnimationController _livePulseController;

  @override
  void initState() {
    super.initState();
    _livePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat();

    _jobRequests = [
      JobRequest(
        id: '1',
        customerName: 'Nimal Perera',
        serviceType: 'Plumbing',
        location: 'Nugegoda, Colombo',
        distance: '2.3 km',
        estimatedTime: '1-2 hours',
        payment: 'Rs. 2,500',
        urgency: 'high',
      ),
      JobRequest(
        id: '2',
        customerName: 'Kamala Silva',
        serviceType: 'Electrical',
        location: 'Dehiwala',
        distance: '4.1 km',
        estimatedTime: '2-3 hours',
        payment: 'Rs. 3,200',
        urgency: 'medium',
      ),
      JobRequest(
        id: '3',
        customerName: 'Sunil Fernando',
        serviceType: 'Carpentry',
        location: 'Maharagama',
        distance: '3.8 km',
        estimatedTime: '3-4 hours',
        payment: 'Rs. 4,500',
        urgency: 'low',
      ),
    ];

    _earnings = const EarningsData(
      today: 5400,
      week: 28500,
      month: 125000,
      pending: 8200,
      completedJobs: 47,
    );
  }

  @override
  void dispose() {
    _livePulseController.dispose();
    super.dispose();
  }

  String _greeting() {
    switch (_language) {
      case 'si':
        return 'හෙලෝ';
      case 'ta':
        return 'வணக்கம்';
      case 'en':
      default:
        return 'Hello';
    }
  }

  String _localized({
    required String en,
    required String si,
    required String ta,
  }) {
    switch (_language) {
      case 'si':
        return si;
      case 'ta':
        return ta;
      case 'en':
      default:
        return en;
    }
  }

  double _parseDistanceKm(String input) {
    final cleaned = input.toLowerCase().replaceAll('km', '').trim();
    return double.tryParse(cleaned) ?? 0;
  }

  int _parseBudgetLkr(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  List<WorkerJob> _toWorkerJobs() {
    final now = DateTime.now();
    return _jobRequests.asMap().entries.map((entry) {
      final index = entry.key;
      final job = entry.value;
      return WorkerJob(
        id: job.id,
        customerName: job.customerName,
        category: job.serviceType,
        location: job.location,
        distanceKm: _parseDistanceKm(job.distance),
        budgetLkr: _parseBudgetLkr(job.payment),
        urgency: job.urgency,
        estimatedTime: job.estimatedTime,
        customerNote:
            'Please arrive on time and bring required tools. Customer prefers a quick diagnosis before starting the full repair.',
        photoLabels: const ['Issue Area 1', 'Issue Area 2', 'Reference View'],
        latitude: 6.9271 + (index * 0.01),
        longitude: 79.8612 + (index * 0.01),
        bidDeadline: now.add(Duration(minutes: 8 + (index * 3))),
      );
    }).toList();
  }

  String _workerTypeFromId(String id) {
    switch (id) {
      case 'plumber':
        return 'Plumber';
      case 'electrician':
        return 'Electrician';
      case 'carpenter':
        return 'Carpenter';
      case 'painter':
        return 'Painter';
      case 'ac-technician':
        return 'AC Technician';
      case 'mechanic':
        return 'Mechanic';
      default:
        return 'Worker';
    }
  }

  bool _matchesWorkerSkill(WorkerJob job) {
    final type = _workerType.toLowerCase();
    final category = job.category.toLowerCase();
    if (category.contains(type) || type.contains(category)) {
      return true;
    }

    if (type.contains('plumber') && category.contains('plumb')) return true;
    if (type.contains('electric') && category.contains('electric')) return true;
    if (type.contains('carpenter') && category.contains('carpent')) return true;
    if (type.contains('painter') && category.contains('paint')) return true;
    if (type.contains('mechanic') && category.contains('mechanic')) return true;
    return false;
  }

  void _openJobFeed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JobFeedScreen(
          jobs: _toWorkerJobs(),
          selectedLanguage: _language ?? 'en',
        ),
      ),
    );
  }

  void _openBidStatus() {
    final jobs = _toWorkerJobs();
    if (jobs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No jobs available for bid status yet.')),
      );
      return;
    }

    final source = jobs.first;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BidStatusScreen(
          job: source,
          bidAmount: source.budgetLkr,
          eta: source.estimatedTime,
          note: '',
          status: 'Pending',
          selectedLanguage: _language ?? 'en',
        ),
      ),
    );
  }

  void _openWallet() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WalletScreen(
          onBack: () => Navigator.of(context).pop(),
          selectedLanguage: _language ?? 'en',
        ),
      ),
    );
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationsScreen(
          selectedLanguage: _language ?? 'en',
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _openProfilePortfolio() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ProfessionalProfileScreen(selectedLanguage: _language ?? 'en'),
      ),
    );
  }

  void _openAnalyticsDashboard() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
  }

  void _openScheduleCalendar() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ScheduleCalendarScreen()));
  }

  void _openPortfolioManager() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PortfolioManagementScreen()),
    );
  }

  void _openSubscriptionPlans() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SubscriptionPlanScreen()));
  }

  void _openFeaturedListing() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const FeaturedListingScreen()));
  }

  void _openTrustScoreDetails() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TrustScoreDetailScreen()));
  }

  void _openPaymentHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PaymentHistoryScreen(selectedLanguage: _language ?? 'en'),
      ),
    );
  }

  void _openActiveJobExecution() {
    final jobs = _toWorkerJobs();
    if (jobs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active job available right now.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JobExecutionScreen(
          job: jobs.first,
          selectedLanguage: _language ?? 'en',
        ),
      ),
    );
  }

  Future<void> _updateCurrentLocationFromDevice() async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Location permission is required to use GPS.'),
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _currentLocation =
            '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
      });

      messenger.showSnackBar(
        const SnackBar(content: Text('Current location updated from GPS.')),
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to fetch current location.')),
      );
    }
  }

  LatLng? _parseLatLngFromLocationText(String text) {
    final parts = text.split(',');
    if (parts.length < 2) {
      return null;
    }

    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) {
      return null;
    }

    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      return null;
    }

    return LatLng(lat, lng);
  }

  Future<String?> _pickLocationFromMap() async {
    const fallback = LatLng(6.9271, 79.8612);
    final initial = _parseLatLngFromLocationText(_currentLocation) ?? fallback;

    final picked = await showDialog<LatLng>(
      context: context,
      builder: (_) => _LocationMapPickerDialog(initialPosition: initial),
    );

    if (picked == null) {
      return null;
    }

    return '${picked.latitude.toStringAsFixed(5)}, ${picked.longitude.toStringAsFixed(5)}';
  }

  Future<void> _openCurrentLocationChanger() async {
    final controller = TextEditingController(text: _currentLocation);
    const useDeviceLocationAction = '__use_device_location__';
    const pickOnMapAction = '__pick_on_map__';

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change Current Location'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Location',
            hintText: 'City, area, or coordinates',
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (value) {
            Navigator.of(dialogContext).pop(value.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(useDeviceLocationAction),
            child: const Text('Use GPS'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(pickOnMapAction),
            child: const Text('Pick on Map'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result == null) {
      return;
    }

    if (result == useDeviceLocationAction) {
      await _updateCurrentLocationFromDevice();
      return;
    }

    if (result == pickOnMapAction) {
      final mapValue = await _pickLocationFromMap();
      if (mapValue == null || !mounted) {
        return;
      }

      setState(() {
        _currentLocation = mapValue;
      });
      return;
    }

    final trimmed = result.trim();
    if (trimmed.isEmpty) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _currentLocation = trimmed;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Auth flow
    if (_authScreen == _AuthScreen.language) {
      return LanguageSelectScreen(
        onLanguageSelect: (code) {
          setState(() {
            _language = code;
            _authScreen = _AuthScreen.login;
          });
        },
      );
    }

    if (_authScreen == _AuthScreen.login) {
      return LoginScreen(
        selectedLanguage: _language ?? 'en',
        onLoginSuccess: () {
          setState(() {
            _authScreen = _AuthScreen.authenticated;
          });
        },
        onNavigateToSignup: () {
          setState(() {
            _authScreen = _AuthScreen.signup;
          });
        },
      );
    }

    if (_authScreen == _AuthScreen.signup) {
      return SignupScreen(
        selectedLanguage: _language ?? 'en',
        onSignUpSuccess: (profile) {
          setState(() {
            _profileData = profile;
            _userName = profile.fullName.isEmpty ? _userName : profile.fullName;
            if (profile.workerTypes.isNotEmpty) {
              _workerType = _workerTypeFromId(profile.workerTypes.first);
            }
            _pendingPhoneNumber = '+94 000 0000';
            _authScreen = _AuthScreen.otp;
          });
        },
        onNavigateToLogin: () {
          setState(() {
            _authScreen = _AuthScreen.login;
          });
        },
      );
    }

    if (_authScreen == _AuthScreen.otp) {
      return OtpScreen(
        selectedLanguage: _language ?? 'en',
        phoneNumber: _pendingPhoneNumber,
        onVerifySuccess: () {
          setState(() {
            _authScreen = _AuthScreen.authenticated;
          });
        },
        onBack: () {
          setState(() {
            _authScreen = _AuthScreen.login;
          });
        },
      );
    }

    // Main authenticated app
    final theme = Theme.of(context);
    final textPrimary = theme.textTheme.bodyLarge?.color ?? Colors.black87;
    final workerJobs = _toWorkerJobs();
    final matchingLeads = workerJobs
        .where((job) => job.distanceKm >= 1 && job.distanceKm <= 50)
        .where(_matchesWorkerSkill)
        .toList();
    final activeJob = workerJobs.isNotEmpty ? workerJobs.first : null;
    final earningsValue = _earningsWindow == 'today'
        ? _earnings.today
        : _earnings.week;
    final baseline = _earningsWindow == 'today'
        ? (_earnings.week / 7).round()
        : _earnings.month;
    final delta = earningsValue - baseline;
    final deltaSign = delta >= 0 ? '+' : '-';
    final deltaPercent = baseline == 0
        ? 0
        : ((delta.abs() / baseline) * 100).round();
    final isDarkMode = widget.isDarkMode;
    final pageBackground = isDarkMode
        ? const Color(0xFF111215)
        : const Color(0xFFF3F6FC);
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF0B1533);
    final bodyColor = isDarkMode
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF334155);

    Widget body;
    switch (_activeTab) {
      case _TabType.home:
        body = SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? const [
                            Color(0xFF07101E),
                            Color(0xFF0B1533),
                            Color(0xFF173775),
                          ]
                        : const [
                            Color(0xFF07122D),
                            Color(0xFF0B1533),
                            Color(0xFF173775),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0B1533).withOpacity(0.28),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -24,
                      top: -24,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -16,
                      bottom: -34,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_greeting()} $_userName!',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _localized(
                                    en: 'Welcome to Sevix Worker',
                                    si: 'Sevix Worker වෙත සාදරයෙන් පිළිගනිමු',
                                    ta: 'Sevix Worker-க்கு வரவேற்கிறோம்',
                                  ),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.82),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: _openNotifications,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _localized(
                            en: 'Jobs are matched based on your profile and service area',
                            si: 'ඔබගේ පැතිකඩ සහ සේවා පරාසය අනුව රැකියා ගැලපේ',
                            ta: 'உங்கள் சுயவிவரம் மற்றும் சேவை பகுதியின் அடிப்படையில் வேலைகள் பொருத்தப்படுகின்றன',
                          ),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.92),
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _headerChip(
                              icon: Icons.work_outline,
                              label:
                                  '${_jobRequests.length} ${_localized(en: 'new jobs', si: 'නව රැකියා', ta: 'புதிய வேலைகள்')}',
                            ),
                            _headerChip(
                              icon: Icons.history_toggle_off,
                              label:
                                  '$_activeJobsCount ${_localized(en: 'active', si: 'සක්‍රීය', ta: 'செயலில்')}',
                            ),
                            _headerChip(
                              icon: Icons.location_on_outlined,
                              label:
                                  '$_serviceRadius ${_localized(en: 'km radius', si: 'කි.මී. පරාසය', ta: 'கிமீ வரம்பு')}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _glassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.map_outlined,
                                  color: Color(0xFF0B1533),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Visible on Customer Map',
                                    style: TextStyle(
                                      color: titleColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                _buildLiveStatusToggle(),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: isDarkMode
                                      ? const [
                                          Color(0xFF13213A),
                                          Color(0xFF0F172A),
                                        ]
                                      : const [
                                          Color(0xFFDCE8FF),
                                          Color(0xFFF3F8FF),
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: isDarkMode
                                      ? const Color(0xFF2C3144)
                                      : const Color(0xFFC9D8F8),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _isOnline
                                      ? _localized(
                                          en: 'Online and discoverable for nearby customers',
                                          si: 'සක්‍රීයයි - අසල ගනුදෙනුකරුවන්ට දැකිය හැක',
                                          ta: 'ஆன்லைனில் - அருகிலுள்ள வாடிக்கையாளர்களுக்கு காணப்படும்',
                                        )
                                      : _localized(
                                          en: 'Offline - hidden from customer map',
                                          si: 'අක්‍රියයි - පාරිභෝගික සිතියමෙන් සඟවා ඇත',
                                          ta: 'ஆஃப்லைன் - வாடிக்கையாளர் வரைபடத்தில் மறைக்கப்பட்டது',
                                        ),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _isOnline
                                        ? (isDarkMode
                                              ? Colors.white
                                              : const Color(0xFF0B1533))
                                        : const Color(0xFFB91C1C),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color(
                                        0xFF101521,
                                      ).withValues(alpha: 0.92)
                                    : Colors.white.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDarkMode
                                      ? const Color(0xFF2C3144)
                                      : const Color(0xFFCBD8EE),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.my_location,
                                        size: 15,
                                        color: Color(0xFF0B1533),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _localized(
                                          en: 'Worker Location',
                                          si: 'සේවක ස්ථානය',
                                          ta: 'தொழிலாளர் இருப்பிடம்',
                                        ),
                                        style: TextStyle(
                                          color: titleColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const Spacer(),
                                      TextButton.icon(
                                        onPressed: _openCurrentLocationChanger,
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        icon: const Icon(
                                          Icons.edit_location_alt_outlined,
                                          size: 16,
                                        ),
                                        label: Text(
                                          _localized(
                                            en: 'Edit',
                                            si: 'සකසන්න',
                                            ta: 'திருத்து',
                                          ),
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? const Color(0xFF93C5FD)
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _currentLocation,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: bodyColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${_localized(en: 'Service radius', si: 'සේවා පරාසය', ta: 'சேவை பரப்பு')}: $_serviceRadius km',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDarkMode
                                          ? const Color(0xFF34D399)
                                          : const Color(0xFF10B981),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openJobFeed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? const Color(0xFF0F4C81)
                              : const Color(0xFF0B1533),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.gavel_rounded),
                        label: Text(
                          _localized(
                            en: 'Start Bidding',
                            si: 'ලංසු දැමීම ආරම්භ කරන්න',
                            ta: 'போலிங்கைத் தொடங்கவும்',
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (activeJob != null)
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          color: isDarkMode
                              ? const Color(0xFF171A24)
                              : const Color(0xFFEFF6FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _localized(
                                    en: 'Active Job In Progress',
                                    si: 'සක්‍රීය රැකියාව ප්‍රගතියේ පවතී',
                                    ta: 'செயலில் உள்ள வேலை நடைபெற்று வருகிறது',
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: titleColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${activeJob.category} - ${activeJob.customerName}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: bodyColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _openActiveJobExecution,
                                  icon: const Icon(Icons.play_circle_outline),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDarkMode
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFF1D4ED8),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 1,
                                  ),
                                  label: Text(
                                    _localized(
                                      en: 'Open Active Job',
                                      si: 'සක්‍රීය රැකියාව විවෘත කරන්න',
                                      ta: 'செயலில் உள்ள வேலையைத் திறக்கவும்',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    _glassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? const Color(0xFF1F2A44)
                                        : const Color(0xFFDBEAFE),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.auto_graph_rounded,
                                    size: 18,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _localized(
                                      en: 'Earnings Summary',
                                      si: 'උපයීම් සාරාංශය',
                                      ta: 'வருமான சுருக்கம்',
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: titleColor,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: delta >= 0
                                        ? const Color(0xFFDCFCE7)
                                        : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '$deltaSign$deltaPercent%',
                                    style: TextStyle(
                                      color: delta >= 0
                                          ? const Color(0xFF166534)
                                          : const Color(0xFF991B1B),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                12,
                                14,
                                12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  colors: isDarkMode
                                      ? const [
                                          Color(0xFF0B1220),
                                          Color(0xFF1E3A8A),
                                        ]
                                      : const [
                                          Color(0xFF0F172A),
                                          Color(0xFF1E3A8A),
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF1E3A8A,
                                    ).withValues(alpha: 0.28),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _earningsWindow == 'today'
                                        ? _localized(
                                            en: 'Today\'s earnings',
                                            si: 'අද උපයීම්',
                                            ta: 'இன்றைய வருமானம்',
                                          )
                                        : _localized(
                                            en: 'Weekly earnings',
                                            si: 'සතිපතා උපයීම්',
                                            ta: 'வாராந்த வருமானம்',
                                          ),
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.78,
                                      ),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 420),
                                    switchInCurve: kGlobalAnimationCurve,
                                    switchOutCurve: Curves.easeInCubic,
                                    transitionBuilder: (child, animation) {
                                      final offset = Tween<Offset>(
                                        begin: const Offset(0.0, 0.2),
                                        end: Offset.zero,
                                      ).animate(animation);
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: offset,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Rs. $earningsValue',
                                      key: ValueKey<String>(_earningsWindow),
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SegmentedButton<String>(
                              segments: [
                                ButtonSegment<String>(
                                  value: 'today',
                                  label: Text(
                                    _localized(
                                      en: 'Today',
                                      si: 'අද',
                                      ta: 'இன்று',
                                    ),
                                  ),
                                ),
                                ButtonSegment<String>(
                                  value: 'week',
                                  label: Text(
                                    _localized(
                                      en: 'This Week',
                                      si: 'මෙම සතිය',
                                      ta: 'இந்த வாரம்',
                                    ),
                                  ),
                                ),
                              ],
                              selected: {_earningsWindow},
                              onSelectionChanged: (selection) {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _earningsWindow = selection.first;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _earningsChip(
                                    title: _localized(
                                      en: 'Pending',
                                      si: 'අපේක්ෂිත',
                                      ta: 'நிலுவை',
                                    ),
                                    value: 'Rs. ${_earnings.pending}',
                                    icon: Icons.schedule,
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _earningsChip(
                                    title: _localized(
                                      en: 'Completed',
                                      si: 'සම්පූර්ණයි',
                                      ta: 'முடிந்தது',
                                    ),
                                    value: '${_earnings.completedJobs}',
                                    icon: Icons.task_alt,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _earningsChip(
                                    title: _localized(
                                      en: 'Monthly',
                                      si: 'මාසික',
                                      ta: 'மாதாந்திர',
                                    ),
                                    value: 'Rs. ${_earnings.month}',
                                    icon: Icons.calendar_month,
                                    color: const Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _openProfilePortfolio,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF7C3AED),
                          side: const BorderSide(
                            color: Color(0xFF7C3AED),
                            width: 1.6,
                          ),
                          backgroundColor: const Color(0xFFF7F3FF),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.verified_user_outlined),
                        label: Text(
                          _localized(
                            en: 'Open Profile & Portfolio',
                            si: 'පැතිකඩ සහ පෝර්ට්ෆෝලියෝ විවෘත කරන්න',
                            ta: 'சுயவிவரம் & தொகுப்பைத் திறக்கவும்',
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _openBidStatus,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0B1533),
                          side: const BorderSide(
                            color: Color(0xFF0B1533),
                            width: 1.6,
                          ),
                          backgroundColor: const Color(0xFFF5F7FF),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.assignment_turned_in_outlined),
                        label: Text(
                          _localized(
                            en: 'Bid Status',
                            si: 'ලංසු තත්ත්වය',
                            ta: 'போலி நிலை',
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _glassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'New Leads Feed (1-50 km)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (matchingLeads.isEmpty)
                          Text(
                            _localized(
                              en: 'No nearby leads match your current skills right now.',
                              si: 'දැනට ඔබගේ කුසලතා සමඟ ගැළපෙන අසල ලීඩ් නැත.',
                              ta: 'தற்போது உங்கள் திறமைகளுக்கு பொருந்தும் அருகிலுள்ள வாய்ப்புகள் இல்லை.',
                            ),
                          ),
                        ...matchingLeads
                            .take(3)
                            .map(
                              (lead) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFE2E8F0),
                                  child: Icon(Icons.campaign_outlined),
                                ),
                                title: Text(
                                  '${lead.category} - ${lead.customerName}',
                                ),
                                subtitle: Text(
                                  '${lead.location} • ${lead.distanceKm.toStringAsFixed(1)} km',
                                ),
                                trailing: Text(
                                  'Rs. ${lead.budgetLkr}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _openJobFeed,
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(
                              _localized(
                                en: 'View All Leads',
                                si: 'සියලු ලීඩ් බලන්න',
                                ta: 'அனைத்து வாய்ப்புகளையும் பார்க்கவும்',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _glassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _localized(
                            en: 'Quick Stats',
                            si: 'ඉක්මන් සංඛ්‍යාලේඛන',
                            ta: 'விரைவு புள்ளிவிவரங்கள்',
                          ),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _statTile(
                                title: _localized(
                                  en: 'Pending Jobs',
                                  si: 'අපේක්ෂිත රැකියා',
                                  ta: 'நிலுவை வேலைகள்',
                                ),
                                value: '${_jobRequests.length}',
                                icon: Icons.pending_actions,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _statTile(
                                title: _localized(
                                  en: 'Today Earnings',
                                  si: 'අද උපයීම්',
                                  ta: 'இன்றைய வருமானம்',
                                ),
                                value: 'Rs. ${_earnings.today}',
                                icon: Icons.payments_outlined,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _statTile(
                                title: _localized(
                                  en: 'Rating',
                                  si: 'ශ්‍රේණිගත කිරීම',
                                  ta: 'மதிப்பீடு',
                                ),
                                value: _rating.toStringAsFixed(1),
                                icon: Icons.star,
                                color: const Color(0xFF0B1533),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _localized(
                        en: 'Shortcuts',
                        si: 'කෙටි මාර්ග',
                        ta: 'குறுக்கு வழிகள்',
                      ),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _shortcutCard(
                            title: _localized(
                              en: 'New Jobs',
                              si: 'නව රැකියා',
                              ta: 'புதிய வேலைகள்',
                            ),
                            subtitle:
                                '${_jobRequests.length} ${_localized(en: 'open', si: 'විවෘතයි', ta: 'திறந்த')}',
                            icon: Icons.campaign_outlined,
                            color: const Color(0xFF0B1533),
                            onTap: () {
                              _openJobFeed();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _shortcutCard(
                            title: _localized(
                              en: 'Active Jobs',
                              si: 'සක්‍රීය රැකියා',
                              ta: 'செயலில் உள்ள வேலைகள்',
                            ),
                            subtitle:
                                '$_activeJobsCount ${_localized(en: 'running', si: 'ධාවනය වෙමින්', ta: 'இயங்குகிறது')}',
                            icon: Icons.work_history_outlined,
                            color: const Color(0xFF10B981),
                            onTap: () {
                              _openActiveJobExecution();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _shortcutCard(
                            title: _localized(
                              en: 'Profile',
                              si: 'පැතිකඩ',
                              ta: 'சுயவிவரம்',
                            ),
                            subtitle: _localized(
                              en: 'Skills & gallery',
                              si: 'කුසලතා සහ ගැලරිය',
                              ta: 'திறன்கள் & கேலரி',
                            ),
                            icon: Icons.verified_user_outlined,
                            color: const Color(0xFF7C3AED),
                            onTap: () {
                              _openProfilePortfolio();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _shortcutCard(
                            title: _localized(
                              en: 'Wallet',
                              si: 'පසුම්බිය',
                              ta: 'பணப்பை',
                            ),
                            subtitle: _localized(
                              en: 'Balance',
                              si: 'ශේෂය',
                              ta: 'இருப்பு',
                            ),
                            icon: Icons.account_balance_wallet_outlined,
                            color: const Color(0xFFF59E0B),
                            onTap: _openWallet,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _shortcutCard(
                            title: _localized(
                              en: 'Payments',
                              si: 'ගෙවීම්',
                              ta: 'கொடுப்பனவுகள்',
                            ),
                            subtitle: _localized(
                              en: 'Escrow status',
                              si: 'එස්ක්‍රෝ තත්ත්වය',
                              ta: 'எஸ்க்ரோ நிலை',
                            ),
                            icon: Icons.payments_outlined,
                            color: const Color(0xFF0EA5E9),
                            onTap: _openPaymentHistory,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _shortcutCard(
                            title: _localized(
                              en: 'Analytics',
                              si: 'විශ්ලේෂණ',
                              ta: 'பகுப்பாய்வு',
                            ),
                            subtitle: _localized(
                              en: 'Earnings & ratings',
                              si: 'උපයීම් සහ ශ්‍රේණි',
                              ta: 'வருமானம் & மதிப்பீடுகள்',
                            ),
                            icon: Icons.insights_outlined,
                            color: const Color(0xFF1D4ED8),
                            onTap: _openAnalyticsDashboard,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _shortcutCard(
                            title: _localized(
                              en: 'Schedule',
                              si: 'කාලසටහන',
                              ta: 'அட்டவணை',
                            ),
                            subtitle: _localized(
                              en: 'Calendar view',
                              si: 'දින දර්ශන දර්ශනය',
                              ta: 'நாட்காட்டி பார்வை',
                            ),
                            icon: Icons.calendar_month_outlined,
                            color: const Color(0xFF16A34A),
                            onTap: _openScheduleCalendar,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _shortcutCard(
                            title: _localized(
                              en: 'Portfolio',
                              si: 'පෝර්ට්ෆෝලියෝ',
                              ta: 'போர்ட்ஃபோலியோ',
                            ),
                            subtitle: _localized(
                              en: 'Project photos',
                              si: 'ව්‍යාපෘති ඡායාරූප',
                              ta: 'திட்ட புகைப்படங்கள்',
                            ),
                            icon: Icons.photo_library_outlined,
                            color: const Color(0xFF9333EA),
                            onTap: _openPortfolioManager,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _shortcutCard(
                            title: _localized(
                              en: 'Plans',
                              si: 'සැලසුම්',
                              ta: 'திட்டங்கள்',
                            ),
                            subtitle: _localized(
                              en: 'Subscription tiers',
                              si: 'දායකත්ව මට්ටම්',
                              ta: 'சந்தா நிலைகள்',
                            ),
                            icon: Icons.workspace_premium_outlined,
                            color: const Color(0xFFF59E0B),
                            onTap: _openSubscriptionPlans,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _shortcutCard(
                            title: _localized(
                              en: 'Boost',
                              si: 'ප්‍රවර්ධනය',
                              ta: 'மேம்படுத்து',
                            ),
                            subtitle: _localized(
                              en: 'Featured listing',
                              si: 'විශේෂ ලැයිස්තුව',
                              ta: 'சிறப்புப் பட்டியல்',
                            ),
                            icon: Icons.campaign_outlined,
                            color: const Color(0xFF0EA5E9),
                            onTap: _openFeaturedListing,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _shortcutCard(
                            title: _localized(
                              en: 'Trust',
                              si: 'විශ්වාසය',
                              ta: 'நம்பிக்கை',
                            ),
                            subtitle: _localized(
                              en: 'Score details',
                              si: 'ලකුණු විස්තර',
                              ta: 'மதிப்பெண் விவரங்கள்',
                            ),
                            icon: Icons.verified_user,
                            color: const Color(0xFF2563EB),
                            onTap: _openTrustScoreDetails,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        break;
      case _TabType.bookings:
        body = WorkHistoryScreen(
          ongoingJobs: _jobRequests
              .map(
                (job) => WorkHistoryJob(
                  jobTitle: '${job.serviceType} Job',
                  customerName: job.customerName,
                  date: DateTime.now().subtract(const Duration(days: 1)),
                  earnings: job.payment,
                  status: 'Ongoing',
                ),
              )
              .toList(),
          completedJobs: const <WorkHistoryJob>[],
          selectedLanguage: _language ?? 'en',
        );
        break;
      case _TabType.chat:
        body = ChatListScreen(selectedLanguage: _language ?? 'en');
        break;
      case _TabType.settings:
        body = SettingsScreen(
          onBack: () {
            setState(() {
              _activeTab = _TabType.home;
            });
          },
          selectedLanguage: _language ?? 'en',
          onLanguageChange: (code) {
            setState(() {
              _language = code;
            });
          },
          isDarkMode: widget.isDarkMode,
          onThemeToggle: widget.onThemeToggle,
          onLogout: () {
            setState(() {
              _authScreen = _AuthScreen.login;
              _activeTab = _TabType.home;
            });
          },
          onDeleteAccount: () {
            setState(() {
              _authScreen = _AuthScreen.login;
              _activeTab = _TabType.home;
            });
          },
          profileData: _profileData,
          onProfileUpdated: (profile) {
            setState(() {
              _profileData = profile;
              if (profile.fullName.isNotEmpty) {
                _userName = profile.fullName;
              }
              if (profile.workerTypes.isNotEmpty) {
                _workerType = _workerTypeFromId(profile.workerTypes.first);
              }
            });
          },
        );
        break;
    }

    return Scaffold(
      backgroundColor: pageBackground,
      body: Stack(
        children: [
          if (isDarkMode)
            Positioned(
              top: -120,
              right: -90,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF3B82F6).withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          if (isDarkMode)
            Positioned(
              bottom: -140,
              left: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF14B8A6).withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          SafeArea(child: body),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDarkMode ? const Color(0xFF0F1118) : Colors.white,
        selectedItemColor: isDarkMode
            ? const Color(0xFF93C5FD)
            : const Color(0xFF0B1533),
        unselectedItemColor: isDarkMode
            ? const Color(0xFF94A3B8)
            : const Color(0xFF64748B),
        currentIndex: _activeTab.index,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          HapticFeedback.lightImpact();
          setState(() {
            _activeTab = _TabType.values[index];
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: _localized(en: 'Home', si: 'මුල් පිටුව', ta: 'முகப்பு'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.work_outline),
            activeIcon: const Icon(Icons.work),
            label: _localized(
              en: 'Work History',
              si: 'වැඩ ඉතිහාසය',
              ta: 'வேலை வரலாறு',
            ),
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.chat_bubble_outline),
                if (_unreadMessages > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _unreadMessages > 9 ? '9+' : '$_unreadMessages',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.chat_bubble),
                if (_unreadMessages > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _unreadMessages > 9 ? '9+' : '$_unreadMessages',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: _localized(en: 'Chat', si: 'කතාබහ', ta: 'அரட்டை'),
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _statTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return _glassCard(
      radius: 12,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: widget.isDarkMode ? 0.16 : 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 24,
              color: widget.isDarkMode ? Colors.white : color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: widget.isDarkMode ? Colors.white : color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: widget.isDarkMode
                    ? const Color(0xFF94A3B8)
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shortcutCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: _glassCard(
        radius: 12,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: color.withValues(
                  alpha: widget.isDarkMode ? 0.18 : 0.12,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: widget.isDarkMode ? Colors.white : color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: widget.isDarkMode
                      ? Colors.white
                      : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: widget.isDarkMode
                      ? const Color(0xFF94A3B8)
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _earningsChip({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: widget.isDarkMode ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: widget.isDarkMode ? 0.35 : 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: widget.isDarkMode
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: widget.isDarkMode ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatusToggle() {
    return SizedBox(
      width: 86,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          if (_isOnline)
            RepaintBoundary(
              child: IgnorePointer(
                child: SizedBox(
                  width: 74,
                  height: 44,
                  child: AnimatedBuilder(
                    animation: _livePulseController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _LivePulsePainter(
                          progress: _livePulseController.value,
                          color: const Color(0xFF10B981),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          Switch(
            value: _isOnline,
            onChanged: (value) {
              HapticFeedback.mediumImpact();
              setState(() {
                _isOnline = value;
                if (value && !_livePulseController.isAnimating) {
                  _livePulseController.repeat();
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _glassCard({required Widget child, double radius = 16}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: widget.isDarkMode
                ? const Color(0xFF181B25).withValues(alpha: 0.96)
                : Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: widget.isDarkMode
                  ? const Color(0xFF2C3144)
                  : Colors.white.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isDarkMode
                    ? Colors.black.withValues(alpha: 0.35)
                    : const Color(0xFF93C5FD).withValues(alpha: 0.17),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _headerChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: widget.isDarkMode
              ? Colors.white.withOpacity(0.12)
              : Colors.white.withOpacity(0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LivePulsePainter extends CustomPainter {
  final double progress;
  final Color color;

  const _LivePulsePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const maxRadius = 18.0;

    for (var i = 0; i < 3; i++) {
      final shifted = (progress + (i * 0.33)) % 1.0;
      final radius = 6 + (maxRadius * shifted);
      final alpha = (1.0 - shifted).clamp(0.0, 1.0) * 0.26;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = color.withValues(alpha: alpha);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LivePulsePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _LocationMapPickerDialog extends StatefulWidget {
  final LatLng initialPosition;

  const _LocationMapPickerDialog({required this.initialPosition});

  @override
  State<_LocationMapPickerDialog> createState() =>
      _LocationMapPickerDialogState();
}

class _LocationMapPickerDialogState extends State<_LocationMapPickerDialog> {
  late LatLng _selectedPosition;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return AlertDialog(
      title: const Text('Pick Location on Map'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenSize.width * 0.9,
          maxHeight: screenSize.height * 0.7,
        ),
        child: SizedBox(
          width: screenSize.width * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: widget.initialPosition,
                      zoom: 13,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('selected-location'),
                        position: _selectedPosition,
                      ),
                    },
                    onTap: (latLng) {
                      setState(() {
                        _selectedPosition = latLng;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${_selectedPosition.latitude.toStringAsFixed(5)}, ${_selectedPosition.longitude.toStringAsFixed(5)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                'Tap the map to move the marker.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selectedPosition),
          child: const Text('Use This Location'),
        ),
      ],
    );
  }
}
