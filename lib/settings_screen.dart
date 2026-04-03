import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final String selectedLanguage; // 'en', 'si', 'ta'
  final ValueChanged<String> onLanguageChange;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;
  final VoidCallback onOpenProfile;
  final VoidCallback onEditProfile;

  const SettingsScreen({
    super.key,
    required this.onBack,
    required this.selectedLanguage,
    required this.onLanguageChange,
    required this.onLogout,
    required this.onDeleteAccount,
    required this.onOpenProfile,
    required this.onEditProfile,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Edit info state
  String _userName = 'Worker';
  String _userEmail = 'worker@example.com';
  String _userPhone = '+94 77 123 4567';

  // Password state
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Edit info controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Notification settings
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

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

  String _accountLabel() {
    switch (_language) {
      case 'si':
        return 'ගිණුම';
      case 'ta':
        return 'கணக்கு';
      default:
        return 'Account';
    }
  }

  String _preferencesLabel() {
    switch (_language) {
      case 'si':
        return 'මනාපයන්';
      case 'ta':
        return 'விருப்பத்தேர்வுகள்';
      default:
        return 'Preferences';
    }
  }

  String _aboutLabel() {
    switch (_language) {
      case 'si':
        return 'පිළිබඳව';
      case 'ta':
        return 'பற்றி';
      default:
        return 'About';
    }
  }

  String _accountActionsLabel() {
    switch (_language) {
      case 'si':
        return 'ගිණුම් ක්‍රියා';
      case 'ta':
        return 'கணக்கு செயல்கள்';
      default:
        return 'Account Actions';
    }
  }

  String _notificationsLabel() {
    switch (_language) {
      case 'si':
        return 'දැනුම්දීම්';
      case 'ta':
        return 'அறிவிப்புகள்';
      default:
        return 'Notifications';
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
        return 'ගිණුම මකන්න';
      case 'ta':
        return 'கணக்கை நீக்கு';
      default:
        return 'Delete Account';
    }
  }

  String _saveLabel() {
    switch (_language) {
      case 'si':
        return 'සුරකින්න';
      case 'ta':
        return 'சேமிக்கவும்';
      default:
        return 'Save';
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

  void _openEditInfoSheet() {
    _nameController.text = _userName;
    _emailController.text = _userEmail;
    _phoneController.text = _userPhone;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _language == 'en'
                            ? 'Edit Information'
                            : _language == 'si'
                            ? 'තොරතුරු සංස්කරණය'
                            : 'தகவலைத் திருத்து',
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
                  const SizedBox(height: 16),
                  _inputGroup(
                    label: _language == 'en'
                        ? 'Name'
                        : _language == 'si'
                        ? 'නම'
                        : 'பெயர்',
                    controller: _nameController,
                    hint: _language == 'en'
                        ? 'Enter your name'
                        : _language == 'si'
                        ? 'ඔබගේ නම ඇතුළත් කරන්න'
                        : 'உங்கள் பெயரை உள்ளிடவும்',
                  ),
                  _inputGroup(
                    label: _language == 'en'
                        ? 'Email'
                        : _language == 'si'
                        ? 'විද්‍යුත් තැපෑල'
                        : 'மின்னஞ்சல்',
                    controller: _emailController,
                    hint: _language == 'en'
                        ? 'Enter your email'
                        : _language == 'si'
                        ? 'ඔබගේ විද්‍යුත් තැපෑල ඇතුළත් කරන්න'
                        : 'உங்கள் மின்னஞ்சலை உள்ளிடவும்',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _inputGroup(
                    label: _language == 'en'
                        ? 'Phone'
                        : _language == 'si'
                        ? 'දුරකථනය'
                        : 'தொலைபேசி',
                    controller: _phoneController,
                    hint: _language == 'en'
                        ? 'Enter your phone'
                        : _language == 'si'
                        ? 'ඔබගේ දුරකථනය ඇතුළත් කරන්න'
                        : 'உங்கள் தொலைபேசியை உள்ளிடவும்',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 8),
                  _primaryButton(
                    label: _saveLabel(),
                    onPressed: () {
                      setState(() {
                        _userName = _nameController.text.trim();
                        _userEmail = _emailController.text.trim();
                        _userPhone = _phoneController.text.trim();
                      });

                      widget.onEditProfile();

                      Navigator.of(context).pop();
                      _showSnack(
                        _language == 'en'
                            ? 'Information updated successfully!'
                            : _language == 'si'
                            ? 'තොරතුරු සාර්ථකව යාවත්කාලීන කරන ලදී!'
                            : 'தகவல் வெற்றிகரமாக புதுப்பிக்கப்பட்டது!',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openResetPasswordSheet() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _language == 'en'
                            ? 'Reset Password'
                            : _language == 'si'
                            ? 'මුරපදය නැවත සකසන්න'
                            : 'கடவுச்சொல்லை மீட்டமை',
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
                  const SizedBox(height: 16),
                  _inputGroup(
                    label: _language == 'en'
                        ? 'Current Password'
                        : _language == 'si'
                        ? 'වත්මන් මුරපදය'
                        : 'தற்போதைய கடவுச்சொல்',
                    controller: _currentPasswordController,
                    hint: _language == 'en'
                        ? 'Enter current password'
                        : _language == 'si'
                        ? 'වත්මන් මුරපදය ඇතුළත් කරන්න'
                        : 'தற்போதைய கடவுச்சொல்லை உள்ளிடவும்',
                    obscureText: true,
                  ),
                  _inputGroup(
                    label: _language == 'en'
                        ? 'New Password'
                        : _language == 'si'
                        ? 'නව මුරපදය'
                        : 'புதிய கடவுச்சொல்',
                    controller: _newPasswordController,
                    hint: _language == 'en'
                        ? 'Enter new password'
                        : _language == 'si'
                        ? 'නව මුරපදය ඇතුළත් කරන්න'
                        : 'புதிய கடவுச்சொல்லை உள்ளிடவும்',
                    obscureText: true,
                  ),
                  _inputGroup(
                    label: _language == 'en'
                        ? 'Confirm Password'
                        : _language == 'si'
                        ? 'මුරපදය තහවුරු කරන්න'
                        : 'கடவுச்சொல்லை உறுதிப்படுத்தவும்',
                    controller: _confirmPasswordController,
                    hint: _language == 'en'
                        ? 'Confirm new password'
                        : _language == 'si'
                        ? 'නව මුරපදය තහවුරු කරන්න'
                        : 'புதிய கடவுச்சொல்லை உறுதிப்படுத்தவும்',
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),
                  _primaryButton(
                    label: _language == 'en'
                        ? 'Reset Password'
                        : _language == 'si'
                        ? 'මුරපදය නැවත සකසන්න'
                        : 'கடவுச்சொல்லை மீட்டமை',
                    onPressed: _handleResetPassword,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleResetPassword() {
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showSnack(
        _language == 'en'
            ? 'Please fill all fields'
            : _language == 'si'
            ? 'කරුණාකර සියලු ක්ෂේත්‍ර පුරවන්න'
            : 'அனைத்து புலங்களையும் நிரப்பவும்',
      );
      return;
    }

    if (newPass != confirm) {
      _showSnack(
        _language == 'en'
            ? 'Passwords do not match'
            : _language == 'si'
            ? 'මුරපද ගැලපෙන්නේ නැත'
            : 'கடவுச்சொற்கள் பொருந்தவில்லை',
      );
      return;
    }

    Navigator.of(context).pop();
    _showSnack(
      _language == 'en'
          ? 'Password reset successfully!'
          : _language == 'si'
          ? 'මුරපදය සාර්ථකව නැවත සකසන ලදී!'
          : 'கடவுச்சொல் வெற்றிகரமாக மீட்டமைக்கப்பட்டது!',
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
                ? 'Delete Account?'
                : _language == 'si'
                ? 'ගිණුම මකන්නද?'
                : 'கணக்கை நீக்கவா?',
          ),
          content: Text(
            _language == 'en'
                ? 'This action cannot be undone. All your data will be permanently deleted.'
                : _language == 'si'
                ? 'මෙම ක්‍රියාව ආපසු හැරවිය නොහැක. ඔබගේ සියලු දත්ත ස්ථිරව මකා දමනු ලැබේ.'
                : 'இந்த செயலை மாற்ற முடியாது. உங்கள் அனைத்து தரவும் நிரந்தரமாக நீக்கப்படும்.',
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
                    ? 'Yes, Delete My Account'
                    : _language == 'si'
                    ? 'ඔව්, මගේ ගිණුම මකන්න'
                    : 'ஆம், என் கணக்கை நீக்கு',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _inputGroup({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E3EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF0B1533)),
              ),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
            ),
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B1533),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 6,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(_settingsTitle()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Account card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: theme.dividerColor.withOpacity(0.3),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 18,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _accountLabel(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      onTap: widget.onOpenProfile,
                      leading: CircleAvatar(
                        backgroundColor: theme.dividerColor.withOpacity(0.3),
                        child: Icon(
                          Icons.person_outline,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      title: Text(
                        _language == 'en'
                            ? 'My Profile'
                            : _language == 'si'
                            ? 'මගේ පැතිකඩ'
                            : 'என் சுயவிவரம்',
                      ),
                      subtitle: Text(
                        _language == 'en'
                            ? 'View your worker profile'
                            : _language == 'si'
                            ? 'ඔබගේ සේවක පැතිකඩ බලන්න'
                            : 'உங்கள் தொழிலாளர் சுயவிவரத்தைப் பார்க்கவும்',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                    const Divider(height: 8),
                    ListTile(
                      onTap: _openEditInfoSheet,
                      leading: CircleAvatar(
                        backgroundColor: theme.dividerColor.withOpacity(0.3),
                        child: Icon(
                          Icons.edit_outlined,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      title: Text(
                        _language == 'en'
                            ? 'Edit Information'
                            : _language == 'si'
                            ? 'තොරතුරු සංස්කරණය'
                            : 'தகவலைத் திருத்து',
                      ),
                      subtitle: Text('$_userName, $_userEmail'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                    const Divider(height: 8),
                    ListTile(
                      onTap: _openResetPasswordSheet,
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFEBEE),
                        child: Icon(
                          Icons.lock_outline,
                          color: Color(0xFFE74C3C),
                        ),
                      ),
                      title: Text(
                        _language == 'en'
                            ? 'Reset Password'
                            : _language == 'si'
                            ? 'මුරපදය නැවත සකසන්න'
                            : 'கடவுச்சொல்லை மீட்டமை',
                      ),
                      subtitle: Text(
                        _language == 'en'
                            ? 'Change your password'
                            : _language == 'si'
                            ? 'ඔබගේ මුරපදය වෙනස් කරන්න'
                            : 'உங்கள் கடவுச்சொல்லை மாற்றவும்',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Preferences
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: theme.dividerColor.withOpacity(0.3),
                          ),
                          child: Icon(
                            Icons.tune,
                            size: 18,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _preferencesLabel(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      onTap: _openLanguageSheet,
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE3F2FD),
                        child: Icon(Icons.language, color: Color(0xFF3498DB)),
                      ),
                      title: Text(_languageLabel()),
                      subtitle: Text(
                        _language == 'en'
                            ? 'English'
                            : _language == 'si'
                            ? 'සිංහල'
                            : 'தமிழ்',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notifications
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: theme.dividerColor.withOpacity(0.3),
                          ),
                          child: Icon(
                            Icons.notifications,
                            size: 18,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _notificationsLabel(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile.adaptive(
                      value: _emailNotifications,
                      onChanged: (v) => setState(() => _emailNotifications = v),
                      secondary: CircleAvatar(
                        backgroundColor: theme.dividerColor.withOpacity(0.3),
                        child: Icon(
                          Icons.mail_outline,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      title: Text(
                        _language == 'en'
                            ? 'Email Notifications'
                            : _language == 'si'
                            ? 'විද්‍යුත් තැපැල් දැනුම්දීම්'
                            : 'மின்னஞ்சல் அறிவிப்புகள்',
                      ),
                    ),
                    const Divider(height: 8),
                    SwitchListTile.adaptive(
                      value: _pushNotifications,
                      onChanged: (v) => setState(() => _pushNotifications = v),
                      secondary: CircleAvatar(
                        backgroundColor: theme.dividerColor.withOpacity(0.3),
                        child: Icon(
                          Icons.phone_iphone,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      title: Text(
                        _language == 'en'
                            ? 'Push Notifications'
                            : _language == 'si'
                            ? 'තල්ලු දැනුම්දීම්'
                            : 'புஷ் அறிவிப்புகள்',
                      ),
                    ),
                    const Divider(height: 8),
                    SwitchListTile.adaptive(
                      value: _smsNotifications,
                      onChanged: (v) => setState(() => _smsNotifications = v),
                      secondary: CircleAvatar(
                        backgroundColor: theme.dividerColor.withOpacity(0.3),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      title: Text(
                        _language == 'en'
                            ? 'SMS Notifications'
                            : _language == 'si'
                            ? 'SMS දැනුම්දීම්'
                            : 'SMS அறிவிப்புகள்',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // About
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: theme.dividerColor.withOpacity(0.3),
                          ),
                          child: Icon(
                            Icons.info_outline,
                            size: 18,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _aboutLabel(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sevix Worker',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _language == 'en'
                          ? 'Version 1.0.0'
                          : _language == 'si'
                          ? 'අනුවාදය 1.0.0'
                          : 'பதிப்பு 1.0.0',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _language == 'en'
                          ? '© 2025 Sevix. All rights reserved.'
                          : _language == 'si'
                          ? '© 2025 Sevix. සියලු හිමිකම් ඇවිරිණි.'
                          : '© 2025 Sevix. அனைத்து உரிமைகளும் பாதுகாக்கப்பட்டவை.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Account actions
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: theme.dividerColor.withOpacity(0.3),
                          ),
                          child: Icon(
                            Icons.shield_outlined,
                            size: 18,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _accountActionsLabel(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      onTap: widget.onLogout,
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFF3E0),
                        child: Icon(Icons.logout, color: Color(0xFFFF9800)),
                      ),
                      title: Text(
                        _logoutLabel(),
                        style: const TextStyle(color: Color(0xFFFF9800)),
                      ),
                      subtitle: Text(
                        _language == 'en'
                            ? 'Sign out of your account'
                            : _language == 'si'
                            ? 'ඔබේ ගිණුමෙන් ඉවත් වන්න'
                            : 'உங்கள் கணக்கிலிருந்து வெளியேறவும்',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                    const Divider(height: 8),
                    ListTile(
                      onTap: _confirmDeleteAccount,
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFEBEE),
                        child: Icon(
                          Icons.delete_outline,
                          color: Color(0xFFE74C3C),
                        ),
                      ),
                      title: Text(
                        _deleteAccountLabel(),
                        style: const TextStyle(color: Color(0xFFE74C3C)),
                      ),
                      subtitle: Text(
                        _language == 'en'
                            ? 'Permanently delete your account'
                            : _language == 'si'
                            ? 'ඔබේ ගිණුම ස්ථිරව මකන්න'
                            : 'உங்கள் கணக்கை நிரந்தரமாக நீக்கவும்',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
