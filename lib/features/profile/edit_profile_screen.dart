import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sevix_worker/features/profile/worker_profile_data.dart';

class EditProfileScreen extends StatefulWidget {
  final String selectedLanguage;
  final WorkerProfileData initialData;
  final ValueChanged<WorkerProfileData> onSave;

  const EditProfileScreen({
    super.key,
    required this.selectedLanguage,
    required this.initialData,
    required this.onSave,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _telephoneController;
  late final TextEditingController _dateOfBirthController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _nationalIdController;
  late final TextEditingController _bioController;

  final Set<String> _workerTypes = <String>{};
  String _countryCode = '+94';
  String _experienceYears = '';
  double _serviceRadius = 5;
  bool _isSubmitting = false;
  bool _didEdit = false;

  String get _language => widget.selectedLanguage;

  static const List<String> _countryCodes = [
    '+94',
    '+91',
    '+1',
    '+44',
    '+61',
    '+971',
  ];

  static const List<String> _experienceOptions = [
    '0-1',
    '2-3',
    '4-5',
    '6-10',
    '10+',
  ];

  static const List<String> _workerTypeOptions = [
    'plumber',
    'electrician',
    'carpenter',
    'painter',
    'ac-technician',
    'mechanic',
  ];

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _nameController = TextEditingController(text: data.fullName);
    _emailController = TextEditingController(text: data.email);
    _telephoneController = TextEditingController(text: data.telephone);
    _dateOfBirthController = TextEditingController(text: data.dateOfBirth);
    _addressController = TextEditingController(text: data.address);
    _cityController = TextEditingController(text: data.city);
    _nationalIdController = TextEditingController(text: data.nationalId);
    _bioController = TextEditingController(text: data.bio);

    _countryCode = _countryCodes.contains(data.countryCode)
        ? data.countryCode
        : '+94';
    _workerTypes.addAll(data.workerTypes);
    _experienceYears = data.experienceYears;
    _serviceRadius = double.tryParse(data.serviceRadiusKm) ?? 5;

    for (final controller in _controllers) {
      controller.addListener(_onAnyFieldEdited);
    }
  }

  List<TextEditingController> get _controllers => [
    _nameController,
    _emailController,
    _telephoneController,
    _dateOfBirthController,
    _addressController,
    _cityController,
    _nationalIdController,
    _bioController,
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller
        ..removeListener(_onAnyFieldEdited)
        ..dispose();
    }
    super.dispose();
  }

  void _onAnyFieldEdited() {
    if (!_didEdit) {
      setState(() {
        _didEdit = true;
      });
    }
  }

  String _t(String en, String si, String ta) {
    if (_language == 'si') return si;
    if (_language == 'ta') return ta;
    return en;
  }

  String _workerTypeLabel(String value) {
    switch (value) {
      case 'plumber':
        return _t('Plumber', 'ජල නල ශිල්පි', 'பிளம்பர்');
      case 'electrician':
        return _t('Electrician', 'විදුලි කාර්මික', 'மின்விசை தொழிலாளர்');
      case 'carpenter':
        return _t('Carpenter', 'දර ශිල්පි', 'தச்சர்');
      case 'painter':
        return _t('Painter', 'සායම් ශිල්පි', 'ஓவியர்');
      case 'ac-technician':
        return _t('AC Technician', 'AC කාර්මික', 'ஏசி தொழில்நுட்ப நிபுணர்');
      case 'mechanic':
        return _t('Mechanic', 'යාන්ත්‍රික', 'இயந்திர நிபுணர்');
      default:
        return value;
    }
  }

  int _completionPercent() {
    var filled = 0;
    const total = 11;

    if (_nameController.text.trim().isNotEmpty) filled++;
    if (_emailController.text.trim().isNotEmpty) filled++;
    if (_telephoneController.text.trim().isNotEmpty) filled++;
    if (_dateOfBirthController.text.trim().isNotEmpty) filled++;
    if (_addressController.text.trim().isNotEmpty) filled++;
    if (_cityController.text.trim().isNotEmpty) filled++;
    if (_nationalIdController.text.trim().isNotEmpty) filled++;
    if (_workerTypes.isNotEmpty) filled++;
    if (_experienceYears.trim().isNotEmpty) filled++;
    if (_bioController.text.trim().isNotEmpty) filled++;
    if (_serviceRadius >= 2) filled++;

    return ((filled / total) * 100).round();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      initialDate: DateTime(now.year - 25, now.month, now.day),
    );
    if (picked == null) return;

    final day = picked.day.toString().padLeft(2, '0');
    final month = picked.month.toString().padLeft(2, '0');
    final formatted = '${picked.year}-$month-$day';

    setState(() {
      _didEdit = true;
      _dateOfBirthController.text = formatted;
    });
  }

  String? _validateName(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return _t(
        'Full name is required',
        'සම්පූර්ණ නම අවශ්‍යයි',
        'முழு பெயர் அவசியம்',
      );
    }
    if (text.length < 3) {
      return _t(
        'Name must be at least 3 characters',
        'නම අකුරු 3කට වැඩි විය යුතුයි',
        'பெயர் குறைந்தது 3 எழுத்துகள் வேண்டும்',
      );
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return _t('Email is required', 'ඊමේල් අවශ්‍යයි', 'மின்னஞ்சல் அவசியம்');
    }
    const pattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
    if (!RegExp(pattern).hasMatch(text)) {
      return _t(
        'Enter a valid email',
        'වලංගු ඊමේල් ලිපිනයක් ඇතුල් කරන්න',
        'சரியான மின்னஞ்சலை உள்ளிடவும்',
      );
    }
    return null;
  }

  String? _validateTelephone(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return _t(
        'Phone number is required',
        'දුරකථන අංකය අවශ්‍යයි',
        'தொலைபேசி எண் அவசியம்',
      );
    }
    if (!RegExp(r'^\d{7,15}$').hasMatch(text)) {
      return _t(
        'Enter 7-15 digits',
        'අංක 7-15ක් ඇතුල් කරන්න',
        '7-15 இலக்கங்கள் உள்ளிடவும்',
      );
    }
    return null;
  }

  String? _validateDateOfBirth(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return _t(
        'Date of birth is required',
        'උපන් දිනය අවශ්‍යයි',
        'பிறந்த தேதி அவசியம்',
      );
    }

    final parsed = DateTime.tryParse(text);
    if (parsed == null) {
      return _t(
        'Use YYYY-MM-DD format',
        'YYYY-MM-DD ආකාරය භාවිතා කරන්න',
        'YYYY-MM-DD வடிவத்தை பயன்படுத்தவும்',
      );
    }

    final today = DateTime.now();
    final adultCutoff = DateTime(today.year - 18, today.month, today.day);
    if (parsed.isAfter(adultCutoff)) {
      return _t(
        'You must be at least 18 years old',
        'ඔබ වයස අවුරුදු 18 කට වැඩි විය යුතුයි',
        'குறைந்தது 18 வயது இருக்க வேண்டும்',
      );
    }

    return null;
  }

  String? _validateAddress(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return _t('Address is required', 'ලිපිනය අවශ්‍යයි', 'முகவரி அவசியம்');
    }
    if (text.length < 8) {
      return _t(
        'Address is too short',
        'ලිපිනය කෙටි වැඩියි',
        'முகவரி மிகக் குறுகியது',
      );
    }
    return null;
  }

  String? _validateCity(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return _t('City is required', 'නගරය අවශ්‍යයි', 'நகரம் அவசியம்');
    }
    return null;
  }

  String? _validateNationalId(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return _t(
        'National ID is required',
        'ජාතික හැඳුනුම්පත අවශ්‍යයි',
        'தேசிய அடையாள எண் அவசியம்',
      );
    }
    if (!RegExp(r'^[A-Za-z0-9]{8,20}$').hasMatch(text)) {
      return _t(
        'Use 8-20 letters/numbers',
        'අකුරු/අංක 8-20 භාවිතා කරන්න',
        '8-20 எழுத்து/எண்களை பயன்படுத்தவும்',
      );
    }
    return null;
  }

  String? _validateBio(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return _t(
        'Professional bio is required',
        'වෘත්තීය හැඳින්වීම අවශ්‍යයි',
        'தொழில்முறை விளக்கம் அவசியம்',
      );
    }
    if (text.length < 30) {
      return _t(
        'Write at least 30 characters',
        'අවම වශයෙන් අක්ෂර 30ක් ලියන්න',
        'குறைந்தது 30 எழுத்துகள் எழுதவும்',
      );
    }
    return null;
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_didEdit) return true;

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            _t(
              'Discard changes?',
              'වෙනස්කම් ඉවත දමන්නද?',
              'மாற்றங்களை நிராகரிக்கவா?',
            ),
          ),
          content: Text(
            _t(
              'You have unsaved changes. Leave without saving?',
              'ඔබ සුරකි නැති වෙනස්කම් ඇත. සුරැකීමකින් තොරව පිටවන්නද?',
              'சேமிக்காத மாற்றங்கள் உள்ளன. சேமிக்காமல் வெளியேறவா?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_t('Stay', 'රැඳී සිටින්න', 'இங்கேதான் இரு')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(_t('Discard', 'ඉවත දමන්න', 'நிராகரி')),
            ),
          ],
        );
      },
    );

    return shouldDiscard == true;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    final formValid = _formKey.currentState?.validate() ?? false;
    if (_workerTypes.isEmpty) {
      _showSnack(
        _t(
          'Select at least one skill',
          'අවම වශයෙන් එක් කුසලතාවයක් තෝරන්න',
          'குறைந்தது ஒரு திறனை தேர்வு செய்யவும்',
        ),
      );
      return;
    }
    if (_experienceYears.isEmpty) {
      _showSnack(
        _t(
          'Select experience range',
          'අත්දැකීම් පරාසයක් තෝරන්න',
          'அனுபவ வரம்பை தேர்வு செய்யவும்',
        ),
      );
      return;
    }
    if (!formValid) return;

    setState(() {
      _isSubmitting = true;
    });

    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final updated = widget.initialData.copyWith(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      countryCode: _countryCode,
      telephone: _telephoneController.text.trim(),
      dateOfBirth: _dateOfBirthController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      workerTypes: _workerTypes.toList(),
      experienceYears: _experienceYears,
      bio: _bioController.text.trim(),
      serviceRadiusKm: _serviceRadius.round().toString(),
    );

    widget.onSave(updated);

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _didEdit = false;
    });

    _showSnack(
      _t('Profile saved', 'පැතිකඩ සුරකින ලදී', 'சுயவிவரம் சேமிக்கப்பட்டது'),
    );
    Navigator.of(context).pop();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5EAF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: Color(0xFF64748B),
              letterSpacing: 0.35,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final percent = _completionPercent();

    return PopScope(
      canPop: !_didEdit,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await _confirmDiscardChanges();
        if (!context.mounted || !discard) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () async {
              final discard = await _confirmDiscardChanges();
              if (!context.mounted || !discard) return;
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            _t('Edit Profile', 'පැතිකඩ සංස්කරණය', 'சுயவிவரம் திருத்து'),
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _buildSectionCard(
                title: _t(
                  'PROFILE COMPLETION',
                  'පැතිකඩ සම්පූර්ණභාවය',
                  'சுயவிவர நிறைவு',
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _t(
                              'Complete your details to boost trust and ranking',
                              'විශ්වාසය සහ ශ්‍රේණිගත කිරීම වැඩි කිරීමට තොරතුරු සම්පූර්ණ කරන්න',
                              'நம்பிக்கையும் தரவரிசையும் உயர்த்த விவரங்களை நிறைவு செய்யுங்கள்',
                            ),
                            style: const TextStyle(color: Color(0xFF475569)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$percent%',
                          style: const TextStyle(
                            color: Color(0xFF0B1533),
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: percent / 100,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(12),
                      backgroundColor: const Color(0xFFDBE5F4),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF0B1533),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                title: _t('PERSONAL', 'පුද්ගලික', 'தனிப்பட்ட'),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: _t(
                          'Full Name',
                          'සම්පූර්ණ නම',
                          'முழுப் பெயர்',
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: _validateName,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dateOfBirthController,
                      readOnly: true,
                      onTap: _pickDateOfBirth,
                      decoration: InputDecoration(
                        labelText: _t(
                          'Date Of Birth',
                          'උපන් දිනය',
                          'பிறந்த தேதி',
                        ),
                        prefixIcon: const Icon(Icons.cake_outlined),
                        suffixIcon: IconButton(
                          onPressed: _pickDateOfBirth,
                          icon: const Icon(Icons.calendar_month_outlined),
                        ),
                      ),
                      validator: _validateDateOfBirth,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nationalIdController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: _t(
                          'National ID',
                          'ජාතික හැඳුනුම්පත',
                          'தேசிய அடையாள எண்',
                        ),
                        prefixIcon: const Icon(Icons.badge_outlined),
                      ),
                      validator: _validateNationalId,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                title: _t('CONTACT', 'සම්බන්ධතා', 'தொடர்பு'),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: _t('Email', 'ඊමේල්', 'மின்னஞ்சல்'),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          width: 102,
                          child: DropdownButtonFormField<String>(
                            initialValue: _countryCode,
                            items: _countryCodes
                                .map(
                                  (code) => DropdownMenuItem(
                                    value: code,
                                    child: Text(code),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _didEdit = true;
                                _countryCode = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Code',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _telephoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: _t(
                                'Telephone',
                                'දුරකථන අංකය',
                                'தொலைபேசி எண்',
                              ),
                              prefixIcon: const Icon(Icons.phone_outlined),
                            ),
                            validator: _validateTelephone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: _t('Address', 'ලිපිනය', 'முகவரி'),
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      validator: _validateAddress,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cityController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: _t('City', 'නගරය', 'நகரம்'),
                        prefixIcon: const Icon(Icons.location_city_outlined),
                      ),
                      validator: _validateCity,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                title: _t('PROFESSIONAL', 'වෘත්තීය', 'தொழில்முறை'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('Skill Categories', 'කුසලතා වර්ග', 'திறன் வகைகள்'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _workerTypeOptions.map((type) {
                        final selected = _workerTypes.contains(type);
                        return FilterChip(
                          label: Text(_workerTypeLabel(type)),
                          selected: selected,
                          onSelected: (value) {
                            setState(() {
                              _didEdit = true;
                              if (value) {
                                _workerTypes.add(type);
                              } else {
                                _workerTypes.remove(type);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _experienceYears.isEmpty
                          ? null
                          : _experienceYears,
                      decoration: InputDecoration(
                        labelText: _t('Experience', 'අත්දැකීම්', 'அனுபவம்'),
                        prefixIcon: const Icon(Icons.timeline_outlined),
                      ),
                      items: _experienceOptions
                          .map(
                            (year) => DropdownMenuItem(
                              value: year,
                              child: Text(
                                '$year ${_t('Years', 'වසර', 'ஆண்டுகள்')}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _didEdit = true;
                          _experienceYears = value;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          _t('Service Radius', 'සේවා පරාසය', 'சேவை வரம்பு'),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Text(
                          '${_serviceRadius.round()} km',
                          style: const TextStyle(
                            color: Color(0xFF0B1533),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _serviceRadius,
                      min: 2,
                      max: 40,
                      divisions: 38,
                      label: '${_serviceRadius.round()} km',
                      onChanged: (value) {
                        setState(() {
                          _didEdit = true;
                          _serviceRadius = value;
                        });
                      },
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _bioController,
                      minLines: 3,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        labelText: _t(
                          'Professional Bio',
                          'වෘත්තීය හැඳින්වීම',
                          'தொழில்முறை விளக்கம்',
                        ),
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 52),
                          child: Icon(Icons.subject_outlined),
                        ),
                      ),
                      validator: _validateBio,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B1533),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isSubmitting
                        ? _t('Saving...', 'සුරකිනවා...', 'சேமிக்கப்படுகிறது...')
                        : _t(
                            'Save Changes',
                            'වෙනස්කම් සුරකින්න',
                            'மாற்றங்களை சேமி',
                          ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
