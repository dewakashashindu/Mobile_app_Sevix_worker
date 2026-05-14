import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';

import 'package:sevix_worker/features/profile/edit_profile_screen.dart';
import 'package:sevix_worker/features/profile/worker_profile_data.dart';
import 'package:sevix_worker/features/professional/analytics_screen.dart';
import 'package:sevix_worker/features/professional/featured_listing_screen.dart';
import 'package:sevix_worker/features/professional/notification_preferences_screen.dart';
import 'package:sevix_worker/features/professional/portfolio_management_screen.dart';
import 'package:sevix_worker/features/professional/schedule_calendar_screen.dart';
import 'package:sevix_worker/features/professional/subscription_plan_screen.dart';
import 'package:sevix_worker/features/professional/trust_score_detail_screen.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final String selectedLanguage;
  final ValueChanged<String> onLanguageChange;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeToggle;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;
  final WorkerProfileData profileData;
  final ValueChanged<WorkerProfileData> onProfileUpdated;

  const SettingsScreen({
    super.key,
    required this.onBack,
    required this.selectedLanguage,
    required this.onLanguageChange,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onLogout,
    required this.onDeleteAccount,
    required this.profileData,
    required this.onProfileUpdated,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ImagePicker _picker = ImagePicker();

  bool _isPhotoUploading = false;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  String _biometricStatus = 'Disabled';

  String get _language => widget.selectedLanguage;

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _runActionWithHaptic(Future<void> Function() action) async {
    await HapticFeedback.lightImpact();
    if (!mounted) return;
    await action();
  }

  String _settingsTitle() {
    switch (_language) {
      case 'si':
        return 'සැකසීම්';
      case 'ta':
        return 'அமைப்புகள்';
      default:
        return 'Settings';
    }
  }

  String _languageLabel() {
    switch (_language) {
      case 'si':
        return 'භාෂාව';
      case 'ta':
        return 'மொழி';
      default:
        return 'Language';
    }
  }

  String _logoutLabel() {
    switch (_language) {
      case 'si':
        return 'පිටවීම';
      case 'ta':
        return 'வெளியேறு';
      default:
        return 'Logout';
    }
  }

  String _deleteAccountLabel() {
    switch (_language) {
      case 'si':
        return 'ගිණුම අක්‍රීය කරන්න';
      case 'ta':
        return 'கணக்கை முடக்கு';
      default:
        return 'Deactivate Account';
    }
  }

  String _cancelLabel() {
    switch (_language) {
      case 'si':
        return 'අවලංගු කරන්න';
      case 'ta':
        return 'ரத்து செய்';
      default:
        return 'Cancel';
    }
  }

  String _sectionGeneralLabel() {
    switch (_language) {
      case 'si':
        return 'සාමාන්‍ය';
      case 'ta':
        return 'பொது';
      default:
        return 'General';
    }
  }

  String _sectionAccountLabel() {
    switch (_language) {
      case 'si':
        return 'ගිණුම';
      case 'ta':
        return 'கணக்கு';
      default:
        return 'Account';
    }
  }

  String _sectionSupportLabel() {
    switch (_language) {
      case 'si':
        return 'සහාය';
      case 'ta':
        return 'ஆதரவு';
      default:
        return 'Support';
    }
  }

  String _languagePreviewText() {
    switch (_language) {
      case 'si':
        return 'සිංහල • ආයුබෝවන්';
      case 'ta':
        return 'தமிழ் • வணக்கம்';
      default:
        return 'English • Hello';
    }
  }

  Map<String, bool> _completionChecks() {
    final p = widget.profileData;
    return {
      'profilePhoto': p.profilePhotoPath.trim().isNotEmpty,
      'fullName': p.fullName.trim().isNotEmpty,
      'email': p.email.trim().isNotEmpty,
      'telephone': p.telephone.trim().isNotEmpty,
      'dateOfBirth': p.dateOfBirth.trim().isNotEmpty,
      'address': p.address.trim().isNotEmpty,
      'city': p.city.trim().isNotEmpty,
      'nationalId': p.nationalId.trim().isNotEmpty,
      'experience': p.experienceYears.trim().isNotEmpty,
      'skills': p.workerTypes.isNotEmpty,
      'bio': p.bio.trim().isNotEmpty,
    };
  }

  String _fieldLabel(String key) {
    switch (key) {
      case 'profilePhoto':
        return _language == 'si'
            ? 'පැතිකඩ ඡායාරූපය'
            : _language == 'ta'
            ? 'சுயவிவர புகைப்படம்'
            : 'Profile Photo';
      case 'fullName':
        return _language == 'si'
            ? 'සම්පූර්ණ නම'
            : _language == 'ta'
            ? 'முழுப் பெயர்'
            : 'Full Name';
      case 'email':
        return _language == 'si'
            ? 'ඊමේල්'
            : _language == 'ta'
            ? 'மின்னஞ்சல்'
            : 'Email';
      case 'telephone':
        return _language == 'si'
            ? 'දුරකථන අංකය'
            : _language == 'ta'
            ? 'தொலைபேசி எண்'
            : 'Telephone';
      case 'dateOfBirth':
        return _language == 'si'
            ? 'උපන් දිනය'
            : _language == 'ta'
            ? 'பிறந்த தேதி'
            : 'Date of Birth';
      case 'address':
        return _language == 'si'
            ? 'ලිපිනය'
            : _language == 'ta'
            ? 'முகவரி'
            : 'Address';
      case 'city':
        return _language == 'si'
            ? 'නගරය'
            : _language == 'ta'
            ? 'நகரம்'
            : 'City';
      case 'nationalId':
        return _language == 'si'
            ? 'ජාතික හැඳුනුම්පත'
            : _language == 'ta'
            ? 'தேசிய அடையாள அட்டை'
            : 'National ID';
      case 'experience':
        return _language == 'si'
            ? 'අත්දැකීම්'
            : _language == 'ta'
            ? 'அனுபவம்'
            : 'Experience';
      case 'skills':
        return _language == 'si'
            ? 'කුසලතා'
            : _language == 'ta'
            ? 'திறன்கள்'
            : 'Skills';
      case 'bio':
        return _language == 'si'
            ? 'හැඳින්වීම'
            : _language == 'ta'
            ? 'சுய அறிமுகம்'
            : 'Bio';
      default:
        return key;
    }
  }

  int _completionPercent() {
    final checks = _completionChecks();
    final completed = checks.values.where((ok) => ok).length;
    return ((completed / checks.length) * 100).round();
  }

  List<String> _missingFields() {
    final checks = _completionChecks();
    return checks.entries
        .where((entry) => !entry.value)
        .map((entry) => _fieldLabel(entry.key))
        .toList();
  }

  Future<void> _toggleBiometric(bool enabled) async {
    if (!enabled) {
      setState(() {
        _biometricEnabled = false;
        _biometricStatus = 'Disabled';
      });
      return;
    }

    try {
      final auth = LocalAuthentication();
      final canCheck = await auth.canCheckBiometrics;
      final supported = await auth.isDeviceSupported();

      if (!canCheck || !supported) {
        setState(() {
          _biometricEnabled = false;
          _biometricStatus = 'Not available (mock mode)';
        });
        _showSnack('Biometric unavailable on this device.');
        return;
      }

      final success = await auth.authenticate(
        localizedReason: 'Enable biometric auth for SEVIX Worker',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: false,
        ),
      );

      if (!mounted) return;
      setState(() {
        _biometricEnabled = success;
        _biometricStatus = success ? 'Enabled' : 'Authentication canceled';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _biometricEnabled = false;
        _biometricStatus = 'Failed (mock fallback)';
      });
      _showSnack('Biometric auth failed.');
    }
  }

  Future<void> _pickProfilePhoto(ImageSource source) async {
    final result = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (result == null || !mounted) return;
    await _previewAndSaveProfilePhoto(result.path);
  }

  Future<void> _previewAndSaveProfilePhoto(String imagePath) async {
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 280,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(_cancelLabel()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          _language == 'si'
                              ? 'සුරකින්න'
                              : _language == 'ta'
                              ? 'சேமிக்கவும்'
                              : 'Save',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldSave != true || !mounted) return;

    setState(() {
      _isPhotoUploading = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 850));

    widget.onProfileUpdated(
      widget.profileData.copyWith(profilePhotoPath: imagePath),
    );

    if (!mounted) return;
    setState(() {
      _isPhotoUploading = false;
    });

    _showSnack(
      _language == 'si'
          ? 'පැතිකඩ ඡායාරූපය යාවත්කාලීන කරන ලදී'
          : _language == 'ta'
          ? 'சுயவிவர புகைப்படம் புதுப்பிக்கப்பட்டது'
          : 'Profile photo updated',
    );
  }

  void _viewProfilePhoto() {
    if (widget.profileData.profilePhotoPath.isEmpty) {
      _showSnack(
        _language == 'si'
            ? 'පෙන්වීමට පැතිකඩ ඡායාරූපයක් නොමැත'
            : _language == 'ta'
            ? 'பார்க்க சுயவிவர புகைப்படம் இல்லை'
            : 'No profile picture to view',
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              InteractiveViewer(
                child: Image.file(
                  File(widget.profileData.profilePhotoPath),
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openProfilePhotoActions() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.visibility_outlined),
                  title: Text(
                    _language == 'si'
                        ? 'ඡායාරූපය බලන්න'
                        : _language == 'ta'
                        ? 'படத்தைப் பார்க்கவும்'
                        : 'View Image',
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _viewProfilePhoto();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: Text(
                    _language == 'si'
                        ? 'ඡායාරූපයක් ගන්න'
                        : _language == 'ta'
                        ? 'புகைப்படம் எடுக்கவும்'
                        : 'Take Photo',
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickProfilePhoto(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(
                    _language == 'si'
                        ? 'ගැලරියෙන් තෝරන්න'
                        : _language == 'ta'
                        ? 'கேலரியிலிருந்து தேர்வு செய்'
                        : 'Choose from Gallery',
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickProfilePhoto(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openEditProfileScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          selectedLanguage: _language,
          initialData: widget.profileData,
          onSave: (updatedData) {
            widget.onProfileUpdated(updatedData);
            _showSnack(
              _language == 'si'
                  ? 'පැතිකඩ සාර්ථකව යාවත්කාලීන කරන ලදී!'
                  : _language == 'ta'
                  ? 'சுயவிவரம் வெற்றிகரமாக புதுப்பிக்கப்பட்டது!'
                  : 'Profile updated successfully!',
            );
          },
        ),
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            _language == 'si'
                ? 'ගිණුම අක්‍රීය කරන්නද?'
                : _language == 'ta'
                ? 'கணக்கை முடக்கவா?'
                : 'Deactivate Account?',
          ),
          content: Text(
            _language == 'si'
                ? 'ඔබගේ ගිණුම අක්‍රීය කර සැඟවෙනු ඇත. නැවත සක්‍රීය කිරීමට සහාය අවශ්‍ය වේ.'
                : _language == 'ta'
                ? 'உங்கள் கணக்கு முடக்கப்படும். மீண்டும் செயல்படுத்த ஆதரவை தொடர்புகொள்ள வேண்டும்.'
                : 'Your account will be deactivated and hidden until support reactivates it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_cancelLabel()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDeleteAccount();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE74C3C),
              ),
              child: Text(
                _language == 'si'
                    ? 'ඔව්, මගේ ගිණුම අක්‍රීය කරන්න'
                    : _language == 'ta'
                    ? 'ஆம், என் கணக்கை முடக்கு'
                    : 'Yes, Deactivate My Account',
              ),
            ),
          ],
        );
      },
    );
  }

  void _openNotificationPreferences() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationPreferencesScreen()),
    );
  }

  void _openAnalytics() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
  }

  void _openSchedule() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ScheduleCalendarScreen()));
  }

  void _openPortfolio() {
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

  void _openTrustScore() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TrustScoreDetailScreen()));
  }

  Color _tileColor() {
    return widget.isDarkMode ? const Color(0xFF1B1B1D) : Colors.white;
  }

  Color _tileBorderColor() {
    return widget.isDarkMode
        ? const Color(0xFF2C2D32)
        : const Color(0xFFE7EDF5);
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: widget.isDarkMode
              ? const Color(0xFFA3A8B5)
              : const Color(0xFF5D6B82),
          fontWeight: FontWeight.w800,
          fontSize: 13,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildAvatarStack() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: const Color(0xFFE8EEF7),
          backgroundImage: widget.profileData.profilePhotoPath.isEmpty
              ? null
              : FileImage(File(widget.profileData.profilePhotoPath)),
          child: widget.profileData.profilePhotoPath.isEmpty
              ? const Icon(Icons.person, size: 34, color: Color(0xFF0B1533))
              : null,
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Material(
            color: const Color(0xFF0B1533),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _isPhotoUploading
                  ? null
                  : () => _runActionWithHaptic(() async {
                      _openProfilePhotoActions();
                    }),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _isPhotoUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(int percent, List<String> missing) {
    final trustColor = percent >= 85
        ? const Color(0xFF10B981)
        : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _tileColor(),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _tileBorderColor()),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: widget.isDarkMode ? 0.18 : 0.07,
            ),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildAvatarStack(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.profileData.fullName.isEmpty
                          ? (_language == 'si'
                                ? 'නව සේවකයා'
                                : _language == 'ta'
                                ? 'புதிய தொழிலாளர்'
                                : 'New Worker')
                          : widget.profileData.fullName,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: widget.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.profileData.email.isEmpty
                          ? (_language == 'si'
                                ? 'හොඳ රැකියා ගැලපීමට පැතිකඩ සම්පූර්ණ කරන්න'
                                : _language == 'ta'
                                ? 'சிறந்த தரவரிசைக்காக சுயவிவரத்தை நிறைவு செய்யவும்'
                                : 'Complete profile for better ranking')
                          : widget.profileData.email,
                      style: TextStyle(
                        color: widget.isDarkMode
                            ? const Color(0xFFA3A8B5)
                            : const Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _runActionWithHaptic(() async {
                  _openEditProfileScreen();
                }),
                icon: const Icon(Icons.edit_note_rounded),
                color: const Color(0xFF3B82F6),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: _tileBorderColor(), height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _language == 'si'
                    ? 'විශ්වාස ලකුණ: 98%'
                    : _language == 'ta'
                    ? 'நம்பிக்கை மதிப்பெண்: 98%'
                    : 'Trust Score: 98%',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: trustColor,
                ),
              ),
              Text(
                '$percent% Complete',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent / 100,
            borderRadius: BorderRadius.circular(10),
            minHeight: 8,
            backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
          ),
          if (missing.isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: missing.take(3).map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.isDarkMode
                            ? const Color(0xFFFACC15)
                            : const Color(0xFF92400E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bentoItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: () => _runActionWithHaptic(() async {
        onTap();
      }),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: widget.isDarkMode ? 0.19 : 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.24), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _bentoItem(
          icon: Icons.analytics_outlined,
          label: 'Analytics',
          onTap: _openAnalytics,
          color: const Color(0xFFF59E0B),
        ),
        _bentoItem(
          icon: Icons.calendar_month_outlined,
          label: 'Schedule',
          onTap: _openSchedule,
          color: const Color(0xFF8B5CF6),
        ),
        _bentoItem(
          icon: Icons.collections_bookmark_outlined,
          label: 'Portfolio',
          onTap: _openPortfolio,
          color: const Color(0xFF2563EB),
        ),
        _bentoItem(
          icon: Icons.workspace_premium_outlined,
          label: 'Subscription',
          onTap: _openSubscriptionPlans,
          color: const Color(0xFF0EA5A4),
        ),
        _bentoItem(
          icon: Icons.campaign_outlined,
          label: 'Featured',
          onTap: _openFeaturedListing,
          color: const Color(0xFFE11D48),
        ),
        _bentoItem(
          icon: Icons.verified_user_outlined,
          label: 'Trust Score',
          onTap: _openTrustScore,
          color: const Color(0xFF16A34A),
        ),
      ],
    );
  }

  Widget _settingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF3B82F6),
    Widget? trailing,
  }) {
    return ListTile(
      onTap: () => _runActionWithHaptic(() async {
        onTap();
      }),
      leading: CircleAvatar(
        backgroundColor: iconColor.withValues(alpha: 0.16),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildAppSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: _tileColor(),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _tileBorderColor()),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: widget.isDarkMode ? 0.14 : 0.06,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _languageLabel(),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'en', label: Text('EN')),
              ButtonSegment(value: 'si', label: Text('සි')),
              ButtonSegment(value: 'ta', label: Text('த')),
            ],
            selected: {_language},
            onSelectionChanged: (selection) {
              _runActionWithHaptic(() async {
                widget.onLanguageChange(selection.first);
              });
            },
          ),
          const SizedBox(height: 10),
          Divider(color: _tileBorderColor(), height: 1),
          SwitchListTile.adaptive(
            value: widget.isDarkMode,
            onChanged: (value) {
              _runActionWithHaptic(() async {
                widget.onThemeToggle(value);
              });
            },
            title: Text(
              _language == 'si'
                  ? 'අඳුරු ආකාරය'
                  : _language == 'ta'
                  ? 'இருண்ட முறை'
                  : 'Dark Mode',
            ),
            subtitle: Text(_languagePreviewText()),
            secondary: CircleAvatar(
              backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.16),
              child: Icon(
                widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: const Color(0xFF6366F1),
              ),
            ),
          ),
          SwitchListTile.adaptive(
            value: _notificationsEnabled,
            onChanged: (value) {
              _runActionWithHaptic(() async {
                setState(() {
                  _notificationsEnabled = value;
                });
              });
            },
            title: Text(
              _language == 'si'
                  ? 'දැනුම්දීම්'
                  : _language == 'ta'
                  ? 'அறிவிப்புகள்'
                  : 'Notifications',
            ),
            subtitle: Text(
              _notificationsEnabled
                  ? (_language == 'si'
                        ? 'සක්‍රීයයි'
                        : _language == 'ta'
                        ? 'இயக்கப்பட்டது'
                        : 'Enabled')
                  : (_language == 'si'
                        ? 'අක්‍රීයයි'
                        : _language == 'ta'
                        ? 'முடக்கப்பட்டது'
                        : 'Disabled'),
            ),
            secondary: CircleAvatar(
              backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.16),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: Color(0xFFF59E0B),
              ),
            ),
          ),
          SwitchListTile.adaptive(
            value: _biometricEnabled,
            onChanged: (value) {
              _runActionWithHaptic(() async {
                await _toggleBiometric(value);
              });
            },
            title: Text(
              _language == 'si'
                  ? 'ජෛවමිතිය අත්සන් වරය'
                  : _language == 'ta'
                  ? 'உயிர்முறை அங்கீகாரம்'
                  : 'Biometric Auth',
            ),
            subtitle: Text(_biometricStatus),
            secondary: CircleAvatar(
              backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.16),
              child: const Icon(Icons.fingerprint, color: Color(0xFF10B981)),
            ),
          ),
          _settingRow(
            icon: Icons.tune_outlined,
            iconColor: const Color(0xFF10B981),
            title: _language == 'si'
                ? 'දැනුම්දීම් මනාප'
                : _language == 'ta'
                ? 'அறிவிப்பு விருப்பங்கள்'
                : 'Notification Preferences',
            subtitle: _language == 'si'
                ? 'නව වැඩ, ගෙවීම්, චැට් සහ ලංසු යාවත්කාලීන'
                : _language == 'ta'
                ? 'புதிய வேலை, கட்டணம், அரட்டை, ஏலம் புதுப்பிப்புகள்'
                : 'New jobs, payments, chat, and bid updates',
            onTap: _openNotificationPreferences,
          ),
          _settingRow(
            icon: Icons.help_outline,
            iconColor: const Color(0xFF0EA5E9),
            title: _language == 'si'
                ? 'උදව් මධ්‍යස්ථානය'
                : _language == 'ta'
                ? 'உதவி மையம்'
                : 'Help Center',
            subtitle: _language == 'si'
                ? 'මාර්ගෝපදේශ, ප්‍රශ්නෝත්තර සහ සහාය'
                : _language == 'ta'
                ? 'வழிகாட்டிகள், கேள்விகள் மற்றும் ஆதரவு'
                : 'Guides, FAQs, and account support',
            onTap: () {
              _showSnack(
                _language == 'si'
                    ? 'උදව් මධ්‍යස්ථානය විවෘත කරන ලදී'
                    : _language == 'ta'
                    ? 'உதவி மையம் திறக்கப்பட்டது'
                    : 'Help Center opened',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Column(
      children: [
        ListTile(
          onTap: () => _runActionWithHaptic(() async {
            widget.onLogout();
          }),
          leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          title: Text(
            _logoutLabel(),
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          tileColor: Colors.redAccent.withValues(alpha: 0.08),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _runActionWithHaptic(() async {
            _confirmDeleteAccount();
          }),
          child: Text(
            _deleteAccountLabel(),
            style: TextStyle(
              color: widget.isDarkMode
                  ? const Color(0xFFA3A8B5)
                  : const Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final percent = _completionPercent();
    final missing = _missingFields();

    return Scaffold(
      backgroundColor: widget.isDarkMode
          ? const Color(0xFF111215)
          : const Color(0xFFF3F6FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: widget.onBack,
        ),
        title: Text(
          _settingsTitle(),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
      ),
      body: Stack(
        children: [
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
                    const Color(
                      0xFF3B82F6,
                    ).withValues(alpha: widget.isDarkMode ? 0.22 : 0.17),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
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
                    const Color(
                      0xFF14B8A6,
                    ).withValues(alpha: widget.isDarkMode ? 0.18 : 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              _buildProfileCard(percent, missing),
              const SizedBox(height: 20),
              _buildSectionHeader(_sectionGeneralLabel()),
              const SizedBox(height: 10),
              _buildProfessionalGrid(),
              const SizedBox(height: 20),
              _buildSectionHeader(_sectionAccountLabel()),
              const SizedBox(height: 10),
              _buildAppSettingsCard(),
              const SizedBox(height: 20),
              _buildSectionHeader(_sectionSupportLabel()),
              const SizedBox(height: 10),
              _buildDangerZone(),
              const SizedBox(height: 30),
              Text(
                'SEVIX Worker v2.0.4 • 2026',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: (widget.isDarkMode ? Colors.white : Colors.black)
                      .withValues(alpha: 0.45),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
