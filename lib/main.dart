import 'package:flutter/material.dart';

import 'language_select_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'otp_screen.dart';
import 'settings_screen.dart';
import 'job_feed_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sevix Worker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B1533)),
        useMaterial3: true,
      ),
      home: const _RootScreen(),
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
  const _RootScreen();

  @override
  State<_RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<_RootScreen> {
  String? _language; // 'en', 'si', 'ta'
  _AuthScreen _authScreen = _AuthScreen.language;
  String _pendingPhoneNumber = '';

  _TabType _activeTab = _TabType.home;
  bool _isOnline = false;

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

  IconData _serviceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'plumbing':
        return Icons.water_damage_outlined;
      case 'electrical':
        return Icons.bolt_outlined;
      case 'carpentry':
        return Icons.handyman_outlined;
      default:
        return Icons.work_outline;
    }
  }

  Color _urgencyColor(String urgency) {
    switch (urgency) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _handleAcceptJob(String id) {
    setState(() {
      _jobRequests.removeWhere((j) => j.id == id);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Job accepted!')));
  }

  void _handleRejectJob(String id) {
    setState(() {
      _jobRequests.removeWhere((j) => j.id == id);
    });
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

  void _openJobFeed() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => JobFeedScreen(jobs: _toWorkerJobs())),
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
        onSignUpSuccess: () {
          setState(() {
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 24,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF0B1533),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
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
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Welcome to Sevix Worker',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Go online to find a job',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isOnline ? "You're online" : "You're offline",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        Switch(
                          value: _isOnline,
                          activeColor: Colors.greenAccent,
                          onChanged: (v) {
                            setState(() {
                              _isOnline = v;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: theme.dividerColor,
                      child: Icon(
                        Icons.person,
                        size: 36,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _workerType,
                          style: TextStyle(fontSize: 13, color: textSecondary),
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Wallet screen coming soon'),
                                ),
                              );
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
                          'Earnings Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _earningTile(
                              'Today',
                              _earnings.today,
                              theme.colorScheme.primary,
                            ),
                            _earningTile(
                              'This Week',
                              _earnings.week,
                              textPrimary,
                            ),
                            _earningTile(
                              'This Month',
                              _earnings.month,
                              textPrimary,
                            ),
                            _earningTile(
                              'Pending',
                              _earnings.pending,
                              const Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_earnings.completedJobs} jobs completed',
                              style: const TextStyle(
                                fontSize: 14,
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
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Available Jobs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (!_isOnline)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Icon(
                        Icons.nightlight_round,
                        size: 48,
                        color: textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "You're offline",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Go online to start receiving job requests',
                        style: TextStyle(color: textSecondary),
                      ),
                    ],
                  ),
                )
              else if (_jobRequests.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Icon(Icons.access_time, size: 48, color: textSecondary),
                      const SizedBox(height: 8),
                      Text(
                        'Waiting for job requests...',
                        style: TextStyle(color: textSecondary),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: _jobRequests
                      .map(
                        (job) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: _openJobFeed,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            color: theme
                                                .colorScheme
                                                .primaryContainer,
                                          ),
                                          child: Icon(
                                            _serviceIcon(job.serviceType),
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                job.serviceType,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                job.customerName,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _urgencyColor(
                                              job.urgency,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            job.urgency.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: _urgencyColor(job.urgency),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            job.location,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: textSecondary,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '(${job.distance})',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          job.estimatedTime,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.attach_money,
                                          size: 16,
                                          color: Color(0xFF10B981),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          job.payment,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () =>
                                                _handleRejectJob(job.id),
                                            icon: const Icon(
                                              Icons.close,
                                              color: Color(0xFFEF4444),
                                            ),
                                            label: const Text(
                                              'Reject',
                                              style: TextStyle(
                                                color: Color(0xFFEF4444),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () =>
                                                _handleAcceptJob(job.id),
                                            icon: const Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                            ),
                                            label: const Text('Accept Job'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
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
          onLogout: () {
            setState(() {
              _authScreen = _AuthScreen.login;
              _activeTab = _TabType.home;
              _isOnline = false;
            });
          },
          onDeleteAccount: () {
            setState(() {
              _authScreen = _AuthScreen.login;
              _activeTab = _TabType.home;
              _isOnline = false;
            });
          },
          onOpenProfile: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile screen not implemented yet'),
              ),
            );
          },
          onEditProfile: () {
            // Can hook into a dedicated profile edit screen later
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

  Widget _earningTile(String label, int amount, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            'Rs. ${amount.toString()}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
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
          Icon(icon, size: 18, color: color),
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
}
