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

  Future<void> _changeProfilePhotoFromCamera() async {
    final result = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (result == null) {
      return;
    }

    widget.onProfileUpdated(
      widget.profileData.copyWith(profilePhotoPath: result.path),
    );

    if (!mounted) return;
    _showSnack(
      _language == 'en'
          ? 'Profile photo updated'
          : _language == 'si'
          ? 'පැතිකඩ ඡායාරූපය යාවත්කාලීන කරන ලදී'
          : 'சுயவிவர புகைப்படம் புதுப்பிக்கப்பட்டது',
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        CircleAvatar(
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
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Material(
                            color: const Color(0xFF0B1533),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _changeProfilePhotoFromCamera,
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
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
              child: ListTile(
                onTap: _openLanguageSheet,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.language, color: Color(0xFF1E88E5)),
                ),
                title: Text(_languageLabel()),
                subtitle: Text(
                  _language == 'en'
                      ? 'English / Sinhala / Tamil'
                      : _language == 'si'
                      ? 'ඉංග්‍රීසි / සිංහල / தமிழ்'
                      : 'English / සිංහල / தமிழ்',
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile.adaptive(
                value: widget.isDarkMode,
                onChanged: widget.onThemeToggle,
                secondary: const CircleAvatar(
                  backgroundColor: Color(0xFFEDE7F6),
                  child: Icon(
                    Icons.dark_mode_outlined,
                    color: Color(0xFF5E35B1),
                  ),
                ),
                title: Text(
                  _language == 'en'
                      ? 'Theme'
                      : _language == 'si'
                      ? 'තේමාව'
                      : 'தீம்',
                ),
                subtitle: Text(
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
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
                      ? 'Update personal and professional details'
                      : _language == 'si'
                      ? 'පුද්ගලික සහ වෘත්තීය තොරතුරු යාවත්කාලීන කරන්න'
                      : 'தனிப்பட்ட மற்றும் தொழில்முறை தகவல்களைப் புதுப்பிக்கவும்',
                ),
                trailing: const Icon(Icons.chevron_right),
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
