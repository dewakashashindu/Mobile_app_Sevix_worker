import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'worker_profile_data.dart';

class SignupScreen extends StatefulWidget {
  final String selectedLanguage; // 'en', 'si', 'ta'
  final ValueChanged<WorkerProfileData> onSignUpSuccess;
  final VoidCallback? onNavigateToLogin;

  const SignupScreen({
    super.key,
    required this.selectedLanguage,
    required this.onSignUpSuccess,
    this.onNavigateToLogin,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  String _countryCode = '+94';
  String _serviceRadius = '5';
  bool _showPassword = false;
  bool _agreedToTerms = false;
  String? _nicPhotoPath;
  final Set<String> _workerTypes = <String>{};

  Map<String, Map<String, String>> get _translations => {
    'signUp': {'en': 'Sign Up', 'si': 'ලියාපදිංචි වන්න', 'ta': 'பதிவுசெய்க'},
    'name': {'en': 'Full Name', 'si': 'සම්පූර්ණ නම', 'ta': 'முழுப்பெயர்'},
    'email': {'en': 'Email', 'si': 'ඊමේල්', 'ta': 'மின்னஞ்சல்'},
    'telephone': {
      'en': 'Telephone Number',
      'si': 'දුරකථන අංකය',
      'ta': 'தொலைபேசி எண்',
    },
    'password': {'en': 'Password', 'si': 'මුරපදය', 'ta': 'கடவுச்சொல்'},
    'confirmPassword': {
      'en': 'Confirm Password',
      'si': 'මුරපදය තහවුරු කරන්න',
      'ta': 'கடவுச்சொல்லை உறுதிப்படுத்தவும்',
    },
    'alreadyHaveAccount': {
      'en': 'Already have an account?',
      'si': 'දැනටමත් ගිණුමක් තිබේද?',
      'ta': 'ஏற்கனவே ஒரு கணக்கு உள்ளதா?',
    },
    'login': {'en': 'Login', 'si': 'ඇතුල් වන්න', 'ta': 'உள்நுழைய'},
    'createAccount': {
      'en': 'Create Account',
      'si': 'ගිණුමක් සාදන්න',
      'ta': 'கணக்கை உருவாக்கவும்',
    },
    'signUpDescription': {
      'en': 'Join as a service worker',
      'si': 'සේවා සේවකයෙකු ලෙස එක්වන්න',
      'ta': 'சேவைப் பணியாளராக இணையுங்கள்',
    },
    'error': {'en': 'Error', 'si': 'දෝෂයකි', 'ta': 'பிழை'},
    'fillAllFields': {
      'en': 'Please fill in all required fields',
      'si': 'කරුණාකර සියලුම අවශ්‍ය ක්ෂේත්‍ර පුරවන්න',
      'ta': 'தேவையான அனைத்து புலங்களையும் நிரப்பவும்',
    },
    'invalidEmail': {
      'en': 'Please enter a valid email address',
      'si': 'වලංගු ඊමේල් ලිපිනයක් ඇතුළත් කරන්න',
      'ta': 'சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும்',
    },
    'invalidPhone': {
      'en': 'Please enter a valid telephone number',
      'si': 'වලංගු දුරකථන අංකයක් ඇතුළත් කරන්න',
      'ta': 'சரியான தொலைபேசி எண்ணை உள்ளிடவும்',
    },
    'passwordLength': {
      'en': 'Password must be at least 6 characters',
      'si': 'මුරපදය අවම වශයෙන් අක්ෂර 6ක් විය යුතුය',
      'ta': 'கடவுச்சொல் குறைந்தது 6 எழுத்துக்களாக இருக்க வேண்டும்',
    },
    'passwordMismatch': {
      'en': 'Passwords do not match',
      'si': 'මුරපද ගැලපෙන්නේ නැත',
      'ta': 'கடவுச்சொற்கள் பொருந்தவில்லை',
    },
    'dateOfBirth': {
      'en': 'Date of Birth (YYYY-MM-DD)',
      'si': 'උපන් දිනය',
      'ta': 'பிறந்த தேதி',
    },
    'address': {'en': 'Address', 'si': 'ලිපිනය', 'ta': 'முகவரி'},
    'city': {'en': 'City/Location', 'si': 'නගරය/ස්ථානය', 'ta': 'நகரம்/இடம்'},
    'nationalId': {
      'en': 'National ID/License',
      'si': 'ජාතික හැඳුනුම්පත',
      'ta': 'தேசிய அடையாள அட்டை',
    },
    'workerTypes': {
      'en': 'Service Types (Select at least one)',
      'si': 'සේවා වර්ග',
      'ta': 'சேவை வகைகள்',
    },
    'experience': {
      'en': 'Years of Experience',
      'si': 'අත්දැකීම් වසර',
      'ta': 'அனுபவ ஆண்டுகள்',
    },
    'bio': {
      'en': 'Brief Description',
      'si': 'කෙටි විස්තරය',
      'ta': 'சுருக்கமான விளக்கம்',
    },
    'serviceRadius': {
      'en': 'Service Radius (km)',
      'si': 'සේවා රේඩියස (කි.මී)',
      'ta': 'சேவை ஆரம் (கி.மீ)',
    },
    'agreeToTerms': {
      'en': 'I agree to Terms & Conditions',
      'si': 'නියම හා කොන්දේසි වලට එකඟ වෙමි',
      'ta': 'விதிமுறைகளுக்கு நான் ஒப்புக்கொள்கிறேன்',
    },
    'mustAgreeTerms': {
      'en': 'You must agree to terms and conditions',
      'si': 'ඔබ නියම සහ කොන්දේසි වලට එකඟ විය යුතුය',
      'ta': 'நீங்கள் விதிமுறைகளுக்கு ஒப்புக்கொள்ள வேண்டும்',
    },
    'selectWorkerType': {
      'en': 'Please select at least one service type',
      'si': 'කරුණාකර අවම වශයෙන් එක් සේවා වර්ගයක් තෝරන්න',
      'ta': 'குறைந்தது ஒரு சேவை வகையைத் தேர்ந்தெடுக்கவும்',
    },
    'personalInfo': {
      'en': 'Personal Information',
      'si': 'පුද්ගලික තොරතුරු',
      'ta': 'தனிப்பட்ட தகவல்',
    },
    'professionalInfo': {
      'en': 'Professional Information',
      'si': 'වෘත්තීය තොරතුරු',
      'ta': 'தொழில்முறை தகவல்',
    },
    'serviceArea': {
      'en': 'Service Area',
      'si': 'සේවා ප්‍රදේශය',
      'ta': 'சேவை பகுதி',
    },
  };

  String _t(String key) {
    final valueForKey = _translations[key];
    if (valueForKey == null) return key;
    final lang = widget.selectedLanguage;
    return valueForKey[lang] ?? valueForKey['en'] ?? key;
  }

  String _workerTypeLabel(String id) {
    const labels = {
      'plumber': {'en': 'Plumber', 'si': 'නළකරුවා', 'ta': 'குழாய் தொழிலாளர்'},
      'electrician': {
        'en': 'Electrician',
        'si': 'විදුලි කාර්මිකයා',
        'ta': 'மின்சார தொழிலாளர்',
      },
      'carpenter': {'en': 'Carpenter', 'si': 'කඩදාසි කම්කරුවා', 'ta': 'தச்சர்'},
      'painter': {'en': 'Painter', 'si': 'චිත්ර ශිල්පියා', 'ta': 'ஓவியர்'},
      'ac-technician': {
        'en': 'AC Technician',
        'si': 'AC තාක්ෂණවේදියා',
        'ta': 'ஏசி நிபுணர்',
      },
      'mechanic': {'en': 'Mechanic', 'si': 'මෙෂිනිකිය', 'ta': 'மேக்கானிக்'},
    };

    final map = labels[id];
    if (map == null) return id;
    final lang = widget.selectedLanguage;
    return map[lang] ?? map['en'] ?? id;
  }

  List<Map<String, String>> get _availableWorkerTypes => const [
    {'id': 'plumber', 'icon': 'water'},
    {'id': 'electrician', 'icon': 'bolt'},
    {'id': 'carpenter', 'icon': 'carpenter'},
    {'id': 'painter', 'icon': 'format_paint'},
    {'id': 'ac-technician', 'icon': 'ac_unit'},
    {'id': 'mechanic', 'icon': 'build'},
  ];

  final List<Map<String, String>> _countryCodes = const [
    {'code': '+94', 'label': '🇱🇰 +94'},
    {'code': '+91', 'label': '🇮🇳 +91'},
    {'code': '+1', 'label': '🇺🇸 +1'},
    {'code': '+44', 'label': '🇬🇧 +44'},
    {'code': '+61', 'label': '🇦🇺 +61'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _nationalIdController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickNicFromGallery() async {
    final result = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (result != null) {
      setState(() {
        _nicPhotoPath = result.path;
      });
    }
  }

  Future<void> _takeNicPhoto() async {
    final result = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (result != null) {
      setState(() {
        _nicPhotoPath = result.path;
      });
    }
  }

  Future<void> _showNicOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: Text(
                    widget.selectedLanguage == 'si'
                        ? 'ඡායාරූපයක් ගන්න'
                        : widget.selectedLanguage == 'ta'
                        ? 'புகைப்படம் எடுக்கவும்'
                        : 'Take Photo',
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _takeNicPhoto();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_outlined),
                  title: Text(
                    widget.selectedLanguage == 'si'
                        ? 'ගැලරියෙන් තෝරන්න'
                        : widget.selectedLanguage == 'ta'
                        ? 'கேலரியிலிருந்து தேர்ந்தெடுக்கவும்'
                        : 'Choose from Gallery',
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _pickNicFromGallery();
                  },
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleWorkerType(String id) {
    setState(() {
      if (_workerTypes.contains(id)) {
        _workerTypes.remove(id);
      } else {
        _workerTypes.add(id);
      }
    });
  }

  void _showMessage(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleSignUp() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final tel = _telephoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final dob = _dateOfBirthController.text.trim();
    final address = _addressController.text.trim();
    final city = _cityController.text.trim();
    final nid = _nationalIdController.text.trim();
    final experience = _experienceController.text.trim();
    final bio = _bioController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        tel.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        dob.isEmpty ||
        address.isEmpty ||
        city.isEmpty ||
        nid.isEmpty ||
        experience.isEmpty ||
        bio.isEmpty ||
        _nicPhotoPath == null) {
      _showMessage(_t('error'), _t('fillAllFields'));
      return;
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      _showMessage(_t('error'), _t('invalidEmail'));
      return;
    }

    final telRegex = RegExp(r'^\d{7,15}$');
    if (!telRegex.hasMatch(tel)) {
      _showMessage(_t('error'), _t('invalidPhone'));
      return;
    }

    if (password.length < 6) {
      _showMessage(_t('error'), _t('passwordLength'));
      return;
    }

    if (password != confirmPassword) {
      _showMessage(_t('error'), _t('passwordMismatch'));
      return;
    }

    if (_workerTypes.isEmpty) {
      _showMessage(_t('error'), _t('selectWorkerType'));
      return;
    }

    if (!_agreedToTerms) {
      _showMessage(_t('error'), _t('mustAgreeTerms'));
      return;
    }

    _showMessage('Success', 'Signup successful!');
    widget.onSignUpSuccess(
      WorkerProfileData(
        fullName: name,
        profilePhotoPath: '',
        email: email,
        countryCode: _countryCode,
        telephone: tel,
        dateOfBirth: dob,
        address: address,
        city: city,
        nationalId: nid,
        workerTypes: _workerTypes.toList(),
        experienceYears: experience,
        bio: bio,
        serviceRadiusKm: _serviceRadius,
        nicPhotoPath: _nicPhotoPath ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final backgroundColor = theme.colorScheme.background;
    final cardBackground = theme.cardColor;
    final borderColor = theme.dividerColor.withOpacity(0.5);
    final primaryColor = theme.colorScheme.primary;
    final textPrimary = theme.textTheme.bodyLarge?.color ?? Colors.black87;
    final textSecondary =
        theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 40,
                bottom: mediaQuery.viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('createAccount'),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _t('signUpDescription'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Personal Information
                  _SectionHeader(
                    icon: Icons.person_outline,
                    title: _t('personalInfo'),
                    color: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _InputLabel(label: _t('name'), color: textPrimary),
                  const SizedBox(height: 8),
                  _InputWrapper(
                    background: cardBackground,
                    borderColor: borderColor,
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              hintText: _t('name'),
                              hintStyle: TextStyle(
                                color: textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            style: TextStyle(color: textPrimary, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InputLabel(label: _t('dateOfBirth'), color: textPrimary),
                  const SizedBox(height: 8),
                  _InputWrapper(
                    background: cardBackground,
                    borderColor: borderColor,
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _dateOfBirthController,
                            keyboardType: TextInputType.datetime,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              hintText: 'YYYY-MM-DD',
                              hintStyle: TextStyle(
                                color: textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            style: TextStyle(color: textPrimary, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InputLabel(label: _t('nationalId'), color: textPrimary),
                  const SizedBox(height: 8),
                  _InputWrapper(
                    background: cardBackground,
                    borderColor: borderColor,
                    child: Row(
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          color: textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _nationalIdController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              hintText: _t('nationalId'),
                              hintStyle: TextStyle(
                                color: textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            style: TextStyle(color: textPrimary, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InputLabel(
                    label: '${_t('nationalId')} Photo',
                    color: textPrimary,
                  ),
                  const SizedBox(height: 8),
                  if (_nicPhotoPath != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_nicPhotoPath!),
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _showNicOptions,
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            color: primaryColor,
                            size: 18,
                          ),
                          label: Text(
                            widget.selectedLanguage == 'si'
                                ? 'ඡායාරූපය වෙනස් කරන්න'
                                : widget.selectedLanguage == 'ta'
                                ? 'புகைப்படத்தை மாற்று'
                                : 'Change Photo',
                            style: TextStyle(color: primaryColor),
                          ),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    GestureDetector(
                      onTap: _showNicOptions,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: borderColor,
                            width: 1.5,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 32,
                              color: primaryColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.selectedLanguage == 'si'
                                  ? 'හැඳුනුම්පත් ඡායාරූපය උඩුගත කරන්න'
                                  : widget.selectedLanguage == 'ta'
                                  ? 'அடையாள அட்டை புகைப்படத்தைப் பதிவேற்றவும்'
                                  : 'Upload NIC Photo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.selectedLanguage == 'si'
                                  ? 'ඡායාරූපයක් ගන්න හෝ ගැලරියෙන් තෝරන්න'
                                  : widget.selectedLanguage == 'ta'
                                  ? 'புகைப்படம் எடுக்கவும் அல்லது தேர்ந்தெடுக்கவும்'
                                  : 'Take photo or choose from gallery',
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),
                  _InputLabel(label: _t('telephone'), color: textPrimary),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.call_outlined,
                          color: textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _countryCode,
                          underline: const SizedBox.shrink(),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: textSecondary,
                          ),
                          items: _countryCodes
                              .map(
                                (c) => DropdownMenuItem<String>(
                                  value: c['code'],
                                  child: Text(
                                    c['label']!,
                                    style: TextStyle(color: textPrimary),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _countryCode = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _telephoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              hintText: _t('telephone'),
                              hintStyle: TextStyle(
                                color: textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            style: TextStyle(color: textPrimary, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  _InputLabel(label: _t('email'), color: textPrimary),
                  const SizedBox(height: 8),
                  _InputWrapper(
                    background: cardBackground,
                    borderColor: borderColor,
                    child: Row(
                      children: [
                        Icon(
                          Icons.mail_outline,
                          color: textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              hintText: _t('email'),
                              hintStyle: TextStyle(
                                color: textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            style: TextStyle(color: textPrimary, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  _InputLabel(label: _t('address'), color: textPrimary),
                  const SizedBox(height: 8),
                  _InputWrapper(
                    background: cardBackground,
                    borderColor: borderColor,
                    child: Row(
                      children: [
                        Icon(
                          Icons.home_outlined,
                          color: textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              hintText: _t('address'),
                              hintStyle: TextStyle(
                                color: textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            style: TextStyle(color: textPrimary, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  _InputLabel(label: _t('password'), color: textPrimary),
                  const SizedBox(height: 8),
                  _InputWrapper(
                    background: cardBackground,
                    borderColor: borderColor,
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              hintText: _t('password'),
                              hintStyle: TextStyle(
                                color: textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            style: TextStyle(color: textPrimary, fontSize: 16),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              _showPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: textSecondary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  _InputLabel(label: _t('confirmPassword'), color: textPrimary),
                  const SizedBox(height: 8),
                  _InputWrapper(
                    background: cardBackground,
                    borderColor: borderColor,
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _confirmPasswordController,
                            obscureText: !_showPassword,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              hintText: _t('confirmPassword'),
                              hintStyle: TextStyle(
                                color: textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            style: TextStyle(color: textPrimary, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _SectionHeader(
                    icon: Icons.work_outline,
                    title: _t('professionalInfo'),
                    color: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _InputLabel(label: _t('workerTypes'), color: textPrimary),
                  const SizedBox(height: 8),
                  Column(
                    children: _availableWorkerTypes.map((type) {
                      final id = type['id']!;
                      final isSelected = _workerTypes.contains(id);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => _toggleWorkerType(id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: cardBackground,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? primaryColor : borderColor,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: isSelected
                                          ? primaryColor
                                          : borderColor,
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  _iconForWorkerType(id),
                                  size: 18,
                                  color: textSecondary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _workerTypeLabel(id),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),
                  _InputLabel(label: _t('experience'), color: textPrimary),
                  const SizedBox(height: 8),
                  _InputWrapper(
                    background: cardBackground,
                    borderColor: borderColor,
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          color: textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _experienceController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              hintText: 'e.g., 5 years',
                            ),
                            style: TextStyle(color: textPrimary, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  _InputLabel(label: _t('bio'), color: textPrimary),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          color: textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _bioController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              hintText: _t('bio'),
                              hintStyle: TextStyle(
                                color: textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            style: TextStyle(color: textPrimary, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _SectionHeader(
                    icon: Icons.location_on_outlined,
                    title: _t('serviceArea'),
                    color: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _InputLabel(label: _t('city'), color: textPrimary),
                  const SizedBox(height: 8),
                  _InputWrapper(
                    background: cardBackground,
                    borderColor: borderColor,
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_city_outlined,
                          color: textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _cityController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              hintText: _t('city'),
                              hintStyle: TextStyle(
                                color: textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            style: TextStyle(color: textPrimary, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  _InputLabel(label: _t('serviceRadius'), color: textPrimary),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.radio_button_checked_outlined,
                          color: textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _serviceRadius,
                            isExpanded: true,
                            underline: const SizedBox.shrink(),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: textSecondary,
                            ),
                            items: const [
                              DropdownMenuItem(value: '3', child: Text('3 km')),
                              DropdownMenuItem(value: '5', child: Text('5 km')),
                              DropdownMenuItem(
                                value: '10',
                                child: Text('10 km'),
                              ),
                              DropdownMenuItem(
                                value: '15',
                                child: Text('15 km'),
                              ),
                              DropdownMenuItem(
                                value: '20',
                                child: Text('20 km'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _serviceRadius = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Switch(
                        value: _agreedToTerms,
                        onChanged: (v) {
                          setState(() {
                            _agreedToTerms = v;
                          });
                        },
                        activeColor: primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.selectedLanguage == 'si'
                              ? 'මම නියම සහ කොන්දේසි වලට එකඟ වෙමි'
                              : widget.selectedLanguage == 'ta'
                              ? 'விதிமுறைகள் மற்றும் நிபந்தனைகளுக்கு நான் ஒப்புக்கொள்கிறேன்'
                              : 'I agree to Terms & Conditions',
                          style: TextStyle(fontSize: 14, color: textPrimary),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: primaryColor.withOpacity(0.6),
                      ),
                      child: Text(
                        _t('signUp'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _t('alreadyHaveAccount'),
                          style: TextStyle(color: textSecondary, fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onNavigateToLogin,
                          child: Text(
                            _t('login'),
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: mediaQuery.padding.bottom + 8),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _iconForWorkerType(String id) {
    switch (id) {
      case 'plumber':
        return Icons.water_damage_outlined;
      case 'electrician':
        return Icons.bolt_outlined;
      case 'carpenter':
        return Icons.chair_alt_outlined;
      case 'painter':
        return Icons.format_paint_outlined;
      case 'ac-technician':
        return Icons.ac_unit;
      case 'mechanic':
        return Icons.build_outlined;
      default:
        return Icons.handyman_outlined;
    }
  }
}

class _InputLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _InputLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
    );
  }
}

class _InputWrapper extends StatelessWidget {
  final Widget child;
  final Color background;
  final Color borderColor;

  const _InputWrapper({
    required this.child,
    required this.background,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
