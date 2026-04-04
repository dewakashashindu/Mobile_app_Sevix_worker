import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'edit_profile_screen.dart';
import 'worker_profile_data.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final String selectedLanguage; // 'en', 'si', 'ta'
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

  String get _language => widget.selectedLanguage;

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _settingsTitle() {
    switch (_language) {
      case 'si':
        return 'සැකසීම්';
      case 'ta':
        return 'அமைப்புகள்';
      case 'en':
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
        return 'වලංගු නොවෙයි';
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

  void _openLanguageSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _language == 'en'
                          ? 'Select Language'
                          : _language == 'si'
                          ? 'භාෂාව තෝරන්න'
                          : 'மொழியைத் தேர்ந்தெடுக்கவும்',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _languageTile('en', 'English', 'English', '🇬🇧'),
                _languageTile('si', 'Sinhala', 'සිංහල', '🇱🇰'),
                _languageTile('ta', 'Tamil', 'தமிழ்', '🇱🇰'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _languageTile(
    String code,
    String name,
    String nativeName,
    String flag,
  ) {
    final isActive = _language == code;
    return InkWell(
      onTap: () {
        widget.onLanguageChange(code);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE8EEF7) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    name,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (isActive)
              const Icon(Icons.check_circle, color: Color(0xFF0B1533)),
          ],
        ),
      ),
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
              _language == 'en'
                  ? 'Profile updated successfully!'
                  : _language == 'si'
                  ? 'පැතිකඩ සාර්ථකව යාවත්කාලීන කරන ලදී!'
                  : 'சுயவிவரம் வெற்றிகரமாக புதுப்பிக்கப்பட்டது!',
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
            _language == 'en'
                ? 'Deactivate Account?'
                : _language == 'si'
                ? 'ගිණුම අක්‍රීය කරන්නද?'
                : 'கணக்கை முடக்கவா?',
          ),
          content: Text(
            _language == 'en'
                ? 'Your account will be deactivated and hidden until support reactivates it.'
                : _language == 'si'
                ? 'ඔබගේ ගිණුම අක්‍රීය කර සැඟවෙනු ඇත. නැවත සක්‍රීය කිරීමට සහාය අවශ්‍ය වේ.'
                : 'உங்கள் கணக்கு முடக்கப்படும். மீண்டும் செயல்படுத்த ஆதரவை தொடர்புகொள்ள வேண்டும்.',
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
                _language == 'en'
                    ? 'Yes, Deactivate My Account'
                    : _language == 'si'
                    ? 'ඔව්, මගේ ගිණුම අක්‍රීය කරන්න'
                    : 'ஆம், என் கணக்கை முடக்கு',
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFeatureMessage(String featureName) {
    _showSnack(
      _language == 'en'
          ? '$featureName opened'
          : _language == 'si'
          ? '$featureName විවෘත කරන ලදී'
          : '$featureName திறக்கப்பட்டது',
    );
  }

  Future<void> _pickProfilePhoto(ImageSource source) async {
    final result = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (result == null) {
      return;
    }

    if (!mounted) return;
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
                        child: Text(
                          _language == 'en'
                              ? 'Cancel'
                              : _language == 'si'
                              ? 'අවලංගු කරන්න'
                              : 'ரத்து செய்',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          _language == 'en'
                              ? 'Save'
                              : _language == 'si'
                              ? 'සුරකින්න'
                              : 'சேமிக்கவும்',
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

    if (shouldSave != true) {
      return;
    }

    setState(() {
      _isPhotoUploading = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));

    widget.onProfileUpdated(
      widget.profileData.copyWith(profilePhotoPath: imagePath),
    );

    if (!mounted) return;
    setState(() {
      _isPhotoUploading = false;
    });

    _showSnack(
      _language == 'en'
          ? 'Profile photo updated'
          : _language == 'si'
          ? 'පැතිකඩ ඡායාරූපය යාවත්කාලීන කරන ලදී'
          : 'சுயவிவர புகைப்படம் புதுப்பிக்கப்பட்டது',
    );
  }

  void _viewProfilePhoto() {
    if (widget.profileData.profilePhotoPath.isEmpty) {
      _showSnack(
        _language == 'en'
            ? 'No profile picture to view'
            : _language == 'si'
            ? 'පෙන්වීමට පැතිකඩ ඡායාරූපයක් නොමැත'
            : 'பார்க்க சுயவிவர புகைப்படம் இல்லை',
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
                    _language == 'en'
                        ? 'View Image'
                        : _language == 'si'
                        ? 'ඡායාරූපය බලන්න'
                        : 'படத்தைப் பார்க்கவும்',
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _viewProfilePhoto();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: Text(
                    _language == 'en'
                        ? 'Take Photo'
                        : _language == 'si'
                        ? 'ඡායාරූපයක් ගන්න'
                        : 'புகைப்படம் எடுக்கவும்',
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickProfilePhoto(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(
                    _language == 'en'
                        ? 'Choose from Gallery'
                        : _language == 'si'
                        ? 'ගැලරියෙන් තෝරන්න'
                        : 'கேலரியிலிருந்து தேர்ந்தெடுக்கவும்',
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

  @override
  Widget build(BuildContext context) {
    final percent = _completionPercent();
    final missing = _missingFields();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(_settingsTitle()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 14,
                ),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(
                                  begin: 0.92,
                                  end: 1.0,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: CircleAvatar(
                            key: ValueKey<String>(
                              widget.profileData.profilePhotoPath.isEmpty
                                  ? 'empty-avatar'
                                  : widget.profileData.profilePhotoPath,
                            ),
                            radius: 34,
                            backgroundColor: const Color(0xFFE8EEF7),
                            backgroundImage:
                                widget.profileData.profilePhotoPath.isEmpty
                                ? null
                                : FileImage(
                                    File(widget.profileData.profilePhotoPath),
                                  ),
                            child: widget.profileData.profilePhotoPath.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 34,
                                    color: Color(0xFF0B1533),
                                  )
                                : null,
                          ),
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
                                  : _openProfilePhotoActions,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: _isPhotoUploading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
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
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.profileData.fullName.isEmpty
                                ? (_language == 'en'
                                      ? 'Worker'
                                      : _language == 'si'
                                      ? 'සේවකයා'
                                      : 'தொழிலாளர்')
                                : widget.profileData.fullName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.profileData.email.isEmpty
                                ? (_language == 'en'
                                      ? 'Tap camera to update profile photo'
                                      : _language == 'si'
                                      ? 'පැතිකඩ ඡායාරූපය වෙනස් කිරීමට කැමරා බොත්තම තට්ටු කරන්න'
                                      : 'புகைப்படத்தை மாற்ற கேமரா பொத்தானை தட்டவும்')
                                : widget.profileData.email,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
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
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          color: Color(0xFF0B1533),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _language == 'en'
                              ? 'Profile Completion'
                              : _language == 'si'
                              ? 'පැතිකඩ සම්පූර්ණතාව'
                              : 'சுயவிவர நிறைவு',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0B1533),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: percent / 100,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percent >= 100
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _language == 'en'
                          ? 'Complete your profile to get more jobs'
                          : _language == 'si'
                          ? 'තවත් වැඩ ලබා ගැනීමට පැතිකඩ සම්පූර්ණ කරන්න'
                          : 'மேலும் வேலை பெற உங்கள் சுயவிவரத்தை நிறைவு செய்யவும்',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (missing.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        _language == 'en'
                            ? 'Missing fields'
                            : _language == 'si'
                            ? 'අඩු තොරතුරු'
                            : 'இல்லாத புலங்கள்',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: missing
                            .map(
                              (item) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF1F2),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: const Color(0xFFFFCCD5),
                                  ),
                                ),
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFB42318),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  _sectionGeneralLabel(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: _notificationsEnabled
                      ? const Color(0xFFECFDF3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile.adaptive(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  secondary: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: CircleAvatar(
                      key: ValueKey<bool>(_notificationsEnabled),
                      backgroundColor: _notificationsEnabled
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFE2E8F0),
                      child: Icon(
                        _notificationsEnabled
                            ? Icons.notifications_active_outlined
                            : Icons.notifications_off_outlined,
                        color: _notificationsEnabled
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  title: Text(
                    _language == 'en'
                        ? 'Notifications'
                        : _language == 'si'
                        ? 'දැනුම්දීම්'
                        : 'அறிவிப்புகள்',
                  ),
                  subtitle: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _notificationsEnabled
                          ? (_language == 'en'
                                ? 'On'
                                : _language == 'si'
                                ? 'ක්‍රියාත්මකයි'
                                : 'இயக்கப்பட்டது')
                          : (_language == 'en'
                                ? 'Off'
                                : _language == 'si'
                                ? 'අක්‍රියයි'
                                : 'முடக்கப்பட்டது'),
                      key: ValueKey<bool>(_notificationsEnabled),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: missing.isNotEmpty
                      ? const Color(0xFFFDB022)
                      : Colors.transparent,
                ),
              ),
              child: ListTile(
                onTap: _openLanguageSheet,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.language, color: Color(0xFF1E88E5)),
                ),
                title: Text(_languageLabel()),
                subtitle: Text(
                  _language == 'en'
                      ? 'Preview: ${_languagePreviewText()}'
                      : _language == 'si'
                      ? 'පෙරදසුන: ${_languagePreviewText()}'
                      : 'முன்னோட்டம்: ${_languagePreviewText()}',
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: widget.isDarkMode
                      ? const Color(0xFFEEF2FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile.adaptive(
                  value: widget.isDarkMode,
                  onChanged: widget.onThemeToggle,
                  secondary: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: CircleAvatar(
                      key: ValueKey<bool>(widget.isDarkMode),
                      backgroundColor: widget.isDarkMode
                          ? const Color(0xFFEDE7F6)
                          : const Color(0xFFFFF3E0),
                      child: Icon(
                        widget.isDarkMode
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        color: widget.isDarkMode
                            ? const Color(0xFF5E35B1)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                  title: Text(
                    _language == 'en'
                        ? 'Theme'
                        : _language == 'si'
                        ? 'තේමාව'
                        : 'தீம்',
                  ),
                  subtitle: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Text(
                      widget.isDarkMode
                          ? (_language == 'en'
                                ? 'Dark mode'
                                : _language == 'si'
                                ? 'අඳුරු ආකාරය'
                                : 'இருண்ட முறை')
                          : (_language == 'en'
                                ? 'Light mode'
                                : _language == 'si'
                                ? 'ආලෝක ආකාරය'
                                : 'ஒளி முறை'),
                      key: ValueKey<bool>(widget.isDarkMode),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  _sectionAccountLabel(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: missing.isNotEmpty
                      ? const Color(0xFFFDB022)
                      : Colors.transparent,
                ),
              ),
              child: ListTile(
                onTap: _openEditProfileScreen,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8EEF7),
                  child: Icon(Icons.edit_outlined, color: Color(0xFF0B1533)),
                ),
                title: Text(
                  _language == 'en'
                      ? 'Edit Profile'
                      : _language == 'si'
                      ? 'පැතිකඩ සංස්කරණය'
                      : 'சுயவிவரத்தைத் திருத்து',
                ),
                subtitle: Text(
                  _language == 'en'
                      ? (missing.isEmpty
                            ? 'Update personal and professional details'
                            : 'Incomplete sections need your attention')
                      : _language == 'si'
                      ? (missing.isEmpty
                            ? 'පුද්ගලික සහ වෘත්තීය තොරතුරු යාවත්කාලීන කරන්න'
                            : 'අසම්පූර්ණ කොටස් යාවත්කාලීන කරන්න')
                      : (missing.isEmpty
                            ? 'தனிப்பட்ட மற்றும் தொழில்முறை தகவல்களைப் புதுப்பிக்கவும்'
                            : 'முழுமையற்ற பகுதிகளைப் புதுப்பிக்கவும்'),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  _sectionSupportLabel(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: () => _showFeatureMessage(
                      _language == 'en'
                          ? 'Help Center'
                          : _language == 'si'
                          ? 'උදව් මධ්‍යස්ථානය'
                          : 'உதவி மையம்',
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE8F5E9),
                      child: Icon(Icons.help_outline, color: Color(0xFF2E7D32)),
                    ),
                    title: Text(
                      _language == 'en'
                          ? 'Help Center'
                          : _language == 'si'
                          ? 'උදව් මධ්‍යස්ථානය'
                          : 'உதவி மையம்',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    onTap: () => _showFeatureMessage(
                      _language == 'en'
                          ? 'Report Issue'
                          : _language == 'si'
                          ? 'දෝෂයක් වාර්තා කරන්න'
                          : 'சிக்கலை அறிவிக்கவும்',
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFEBEE),
                      child: Icon(
                        Icons.bug_report_outlined,
                        color: Color(0xFFE53935),
                      ),
                    ),
                    title: Text(
                      _language == 'en'
                          ? 'Report Issue'
                          : _language == 'si'
                          ? 'දෝෂයක් වාර්තා කරන්න'
                          : 'சிக்கலை அறிவிக்கவும்',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: widget.onLogout,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFF3E0),
                      child: Icon(Icons.logout, color: Color(0xFFFF9800)),
                    ),
                    title: Text(_logoutLabel()),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    onTap: _confirmDeleteAccount,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFEBEE),
                      child: Icon(
                        Icons.person_off_outlined,
                        color: Color(0xFFE74C3C),
                      ),
                    ),
                    title: Text(
                      _deleteAccountLabel(),
                      style: const TextStyle(color: Color(0xFFE74C3C)),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
