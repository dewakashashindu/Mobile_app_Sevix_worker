import 'package:flutter/material.dart';

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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _bioController = TextEditingController();

  final Set<String> _workerTypes = <String>{};
  String _countryCode = '+94';
  String _experienceYears = '';
  double _serviceRadius = 5;
  bool _submitted = false;

  String? _nameError;
  String? _emailError;
  String? _telephoneError;
  String? _dateOfBirthError;
  String? _addressError;
  String? _cityError;
  String? _nationalIdError;
  String? _experienceError;
  String? _workerTypesError;
  String? _bioError;

  final List<Map<String, String>> _countryCodes = const [
    {'code': '+94', 'label': '🇱🇰 +94'},
    {'code': '+91', 'label': '🇮🇳 +91'},
    {'code': '+1', 'label': '🇺🇸 +1'},
    {'code': '+44', 'label': '🇬🇧 +44'},
    {'code': '+61', 'label': '🇦🇺 +61'},
  ];

  final List<String> _availableWorkerTypes = const [
    'plumber',
    'electrician',
    'carpenter',
    'painter',
    'ac-technician',
    'mechanic',
  ];

  final List<String> _experienceOptions = const [
    '0-1',
    '2-3',
    '4-5',
    '6-10',
    '10+',
  ];

  String get _language => widget.selectedLanguage;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _nameController.text = data.fullName;
    _emailController.text = data.email;
    _telephoneController.text = data.telephone;
    _dateOfBirthController.text = data.dateOfBirth;
    _addressController.text = data.address;
    _cityController.text = data.city;
    _nationalIdController.text = data.nationalId;
    _experienceYears = _experienceOptions.contains(data.experienceYears)
        ? data.experienceYears
        : '';
    _bioController.text = data.bio;
    _countryCode = data.countryCode;
    _workerTypes.addAll(data.workerTypes);
    _serviceRadius = double.tryParse(data.serviceRadiusKm) ?? 5;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _nationalIdController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  String _workerTypeLabel(String id) {
    const labels = {
      'plumber': {'en': 'Plumber', 'si': 'නළකරුවා', 'ta': 'குழாய் தொழிலாளர்'},
      'electrician': {
        'en': 'Electrician',
        'si': 'විදුලි කාර්මිකයා',
        'ta': 'மின்சார தொழிலாளர்',
      },
      'carpenter': {'en': 'Carpenter', 'si': 'දර වැඩකරු', 'ta': 'தச்சர்'},
      'painter': {'en': 'Painter', 'si': 'පින්තාරුකරු', 'ta': 'ஓவியர்'},
      'ac-technician': {
        'en': 'AC Technician',
        'si': 'AC තාක්ෂණවේදියා',
        'ta': 'ஏசி நிபுணர்',
      },
      'mechanic': {'en': 'Mechanic', 'si': 'මෙකැනික්', 'ta': 'மேக்கானிக்'},
    };

    final labelMap = labels[id];
    return labelMap?[_language] ?? labelMap?['en'] ?? id;
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

  Future<void> _pickDateOfBirth() async {
    DateTime initialDate = DateTime(1995, 1, 1);
    final parsed = DateTime.tryParse(_dateOfBirthController.text.trim());
    if (parsed != null) {
      initialDate = parsed;
    }

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950, 1, 1),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      final month = selected.month.toString().padLeft(2, '0');
      final day = selected.day.toString().padLeft(2, '0');
      _dateOfBirthController.text = '${selected.year}-$month-$day';
      setState(() {});
    }
  }

  void _save() {
    setState(() {
      _submitted = true;
    });
    if (!_validateForm()) {
      return;
    }

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
    Navigator.of(context).pop();
  }

  bool _validateForm() {
    final email = _emailController.text.trim();
    final phone = _telephoneController.text.trim();
    final dob = _dateOfBirthController.text.trim();

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    final phoneRegex = RegExp(r'^\d{7,15}$');
    final dobRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

    _nameError = _nameController.text.trim().isEmpty
        ? 'Full name is required'
        : null;
    _emailError = email.isEmpty
        ? 'Email is required'
        : (!emailRegex.hasMatch(email) ? 'Enter a valid email address' : null);
    _telephoneError = phone.isEmpty
        ? 'Telephone number is required'
        : (!phoneRegex.hasMatch(phone) ? 'Enter a valid phone number' : null);
    _dateOfBirthError = dob.isEmpty
        ? 'Date of birth is required'
        : (!dobRegex.hasMatch(dob) ? 'Use format YYYY-MM-DD' : null);
    _addressError = _addressController.text.trim().isEmpty
        ? 'Address is required'
        : null;
    _cityError = _cityController.text.trim().isEmpty
        ? 'City is required'
        : null;
    _nationalIdError = _nationalIdController.text.trim().isEmpty
        ? 'National ID/License is required'
        : null;
    _experienceError = _experienceYears.trim().isEmpty
        ? 'Select years of experience'
        : null;
    _workerTypesError = _workerTypes.isEmpty
        ? 'Select at least one service type'
        : null;
    _bioError = _bioController.text.trim().isEmpty
        ? 'Brief description is required'
        : null;

    setState(() {});

    return [
      _nameError,
      _emailError,
      _telephoneError,
      _dateOfBirthError,
      _addressError,
      _cityError,
      _nationalIdError,
      _experienceError,
      _workerTypesError,
      _bioError,
    ].every((e) => e == null);
  }

  Widget _input(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: (_) {
              if (_submitted) {
                _validateForm();
              } else {
                setState(() {});
              }
            },
            decoration: InputDecoration(
              labelText: label,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: suffixIcon,
            ),
          ),
          if (errorText != null) ...[
            const SizedBox(height: 6),
            Text(
              errorText,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFB42318),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool get _isPersonalIncomplete {
    return _nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _telephoneController.text.trim().isEmpty ||
        _dateOfBirthController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty;
  }

  bool get _isProfessionalIncomplete {
    return _nationalIdController.text.trim().isEmpty ||
        _experienceYears.trim().isEmpty ||
        _workerTypes.isEmpty ||
        _bioController.text.trim().isEmpty;
  }

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
    bool highlightIncomplete = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: highlightIncomplete
              ? const Color(0xFFFDB022)
              : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: highlightIncomplete
                    ? const Color(0xFFB54708)
                    : const Color(0xFF0F172A),
              ),
            ),
            if (highlightIncomplete)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Incomplete section',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB54708),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      appBar: AppBar(
        title: Text(
          _language == 'en'
              ? 'Edit Profile'
              : _language == 'si'
              ? 'පැතිකඩ සංස්කරණය'
              : 'சுயவிவரத்தைத் திருத்து',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(
              title: _language == 'en'
                  ? 'Personal Info'
                  : _language == 'si'
                  ? 'පුද්ගලික තොරතුරු'
                  : 'தனிப்பட்ட தகவல்',
              highlightIncomplete: _isPersonalIncomplete,
              children: [
                _input('Full Name', _nameController, errorText: _nameError),
                _input(
                  'Email',
                  _emailController,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: DropdownButtonFormField<String>(
                        initialValue: _countryCode,
                        decoration: InputDecoration(
                          labelText: 'Code',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: _countryCodes
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item['code'],
                                child: Text(item['label']!),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _countryCode = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _input(
                        'Telephone Number',
                        _telephoneController,
                        keyboardType: TextInputType.phone,
                        errorText: _telephoneError,
                      ),
                    ),
                  ],
                ),
                _input(
                  'Date of Birth',
                  _dateOfBirthController,
                  readOnly: true,
                  onTap: _pickDateOfBirth,
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                  errorText: _dateOfBirthError,
                ),
                _input('Address', _addressController, errorText: _addressError),
                _input('City/Location', _cityController, errorText: _cityError),
              ],
            ),
            _sectionCard(
              title: _language == 'en'
                  ? 'Professional Details'
                  : _language == 'si'
                  ? 'වෘත්තීය තොරතුරු'
                  : 'தொழில்முறை விவரங்கள்',
              highlightIncomplete: _isProfessionalIncomplete,
              children: [
                _input(
                  'National ID/License',
                  _nationalIdController,
                  errorText: _nationalIdError,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DropdownButtonFormField<String>(
                    initialValue: _experienceYears.isEmpty
                        ? null
                        : _experienceYears,
                    decoration: InputDecoration(
                      labelText: 'Years of Experience',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _experienceOptions
                        .map(
                          (value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text('$value years'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _experienceYears = value ?? '';
                        if (_submitted) {
                          _validateForm();
                        }
                      });
                    },
                  ),
                ),
                if (_experienceError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _experienceError!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFB42318),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                _input(
                  'Brief Description',
                  _bioController,
                  maxLines: 3,
                  errorText: _bioError,
                ),
                const SizedBox(height: 4),
                Text(
                  'Service Types',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableWorkerTypes.map((id) {
                    final isSelected = _workerTypes.contains(id);
                    return FilterChip(
                      selected: isSelected,
                      showCheckmark: isSelected,
                      checkmarkColor: Colors.white,
                      selectedColor: const Color(0xFF0B1533),
                      backgroundColor: const Color(0xFFEFF2F8),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF0B1533),
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF0B1533)
                            : const Color(0xFFD9E0EC),
                      ),
                      label: Text(_workerTypeLabel(id)),
                      onSelected: (_) {
                        _toggleWorkerType(id);
                        if (_submitted) {
                          _validateForm();
                        }
                      },
                    );
                  }).toList(),
                ),
                if (_workerTypesError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _workerTypesError!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFB42318),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Service Radius',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EEF7),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${_serviceRadius.round()} km',
                        style: const TextStyle(
                          color: Color(0xFF0B1533),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _serviceRadius,
                  min: 2,
                  max: 40,
                  divisions: 19,
                  label: '${_serviceRadius.round()} km',
                  onChanged: (value) => setState(() => _serviceRadius = value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(
                  _language == 'en'
                      ? 'Save Changes'
                      : _language == 'si'
                      ? 'වෙනස්කම් සුරකින්න'
                      : 'மாற்றங்களைச் சேமிக்கவும்',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

