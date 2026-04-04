import 'package:flutter/material.dart';

import 'worker_profile_data.dart';

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

  Widget _input(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
              children: [
                _input('Full Name', _nameController),
                _input(
                  'Email',
                  _emailController,
                  keyboardType: TextInputType.emailAddress,
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
                ),
                _input('Address', _addressController),
                _input('City/Location', _cityController),
              ],
            ),
            _sectionCard(
              title: _language == 'en'
                  ? 'Professional Details'
                  : _language == 'si'
                  ? 'වෘත්තීය තොරතුරු'
                  : 'தொழில்முறை விவரங்கள்',
              children: [
                _input('National ID/License', _nationalIdController),
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
                      });
                    },
                  ),
                ),
                _input('Brief Description', _bioController, maxLines: 3),
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
                      onSelected: (_) => _toggleWorkerType(id),
                    );
                  }).toList(),
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
