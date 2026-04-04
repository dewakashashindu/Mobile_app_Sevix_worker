import 'package:flutter/material.dart';

import 'language_select_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'otp_screen.dart';
import 'settings_screen.dart';
import 'job_feed_screen.dart';
import 'worker_job.dart';
import 'bid_status_screen.dart';
import 'wallet_screen.dart';
import 'notifications_screen.dart';
import 'worker_profile_data.dart';

void main() {
  runApp(const MyApp());
}

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

class _RootScreenState extends State<_RootScreen> {
  String? _language; // 'en', 'si', 'ta'
  _AuthScreen _authScreen = _AuthScreen.language;
  String _pendingPhoneNumber = '';
  WorkerProfileData _profileData = WorkerProfileData.empty();

  _TabType _activeTab = _TabType.home;
  bool _isOnline = true;

  String _userName = 'Worker';
  String _workerType = 'Plumber';
  String _currentLocation = 'Colombo, Sri Lanka';
  int _unreadMessages = 3;
  int _serviceRadius = 5;
  double _rating = 4.8;
  int _activeJobsCount = 2;

  late List<JobRequest> _jobRequests;
  late EarningsData _earnings;

  @override
  void initState() {
    super.initState();
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

  void _openJobFeed() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => JobFeedScreen(jobs: _toWorkerJobs())),
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
    final textSecondary =
        theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.black54;

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
                  gradient: const LinearGradient(
                    colors: [
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
                                  'Welcome to Sevix Worker',
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
                          'Jobs are matched based on your profile and service area',
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
                              label: '${_jobRequests.length} new jobs',
                            ),
                            _headerChip(
                              icon: Icons.history_toggle_off,
                              label: '$_activeJobsCount active',
                            ),
                            _headerChip(
                              icon: Icons.location_on_outlined,
                              label: '$_serviceRadius km radius',
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
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: theme.dividerColor,
                      child: Icon(
                        Icons.person,
                        size: 46,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _userName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _workerType,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(
                            value: true,
                            icon: Icon(Icons.wifi_tethering_rounded),
                            label: Text('Online'),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            icon: Icon(Icons.pause_circle_outline),
                            label: Text('Offline'),
                          ),
                        ],
                        selected: {_isOnline},
                        showSelectedIcon: false,
                        style: ButtonStyle(
                          side: WidgetStateProperty.resolveWith((states) {
                            final selected = states.contains(
                              WidgetState.selected,
                            );
                            return BorderSide(
                              color: selected
                                  ? const Color(0xFF0B1533)
                                  : theme.dividerColor,
                              width: selected ? 1.6 : 1.0,
                            );
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
                            return states.contains(WidgetState.selected)
                                ? const Color(0xFF0B1533)
                                : textSecondary;
                          }),
                          backgroundColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
                            return states.contains(WidgetState.selected)
                                ? const Color(0xFFEAF0FF)
                                : Colors.white;
                          }),
                          textStyle: const WidgetStatePropertyAll(
                            TextStyle(fontWeight: FontWeight.w700),
                          ),
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        onSelectionChanged: (selection) {
                          setState(() {
                            _isOnline = selection.first;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openJobFeed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B1533),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.gavel_rounded),
                        label: const Text(
                          'Start Bidding',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
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
                        label: const Text(
                          'Bid Status',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Stats',
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
                                title: 'Pending Jobs',
                                value: '${_jobRequests.length}',
                                icon: Icons.pending_actions,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _statTile(
                                title: 'Today Earnings',
                                value: 'Rs. ${_earnings.today}',
                                icon: Icons.payments_outlined,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _statTile(
                                title: 'Rating',
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
                      'Shortcuts',
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
                            title: 'New Jobs',
                            subtitle: '${_jobRequests.length} open',
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
                            title: 'Active Jobs',
                            subtitle: '$_activeJobsCount running',
                            icon: Icons.work_history_outlined,
                            color: const Color(0xFF10B981),
                            onTap: () {
                              setState(() {
                                _activeTab = _TabType.bookings;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _shortcutCard(
                            title: 'Wallet',
                            subtitle: 'Balance',
                            icon: Icons.account_balance_wallet_outlined,
                            color: const Color(0xFFF59E0B),
                            onTap: () {
                              _openWallet();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Location',
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentLocation,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.radio_button_on,
                              color: Color(0xFF10B981),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Service radius: $_serviceRadius km',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case _TabType.bookings:
        body = const Center(child: Text('Work History (placeholder)'));
        break;
      case _TabType.chat:
        body = const Center(child: Text('Chat list (placeholder)'));
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
      body: SafeArea(child: body),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _activeTab.index,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _activeTab = _TabType.values[index];
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.work_outline),
            activeIcon: const Icon(Icons.work),
            label: 'Work History',
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
            label: 'Chat',
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
        ],
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
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
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
