import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sevix_worker/features/profile/identity_verification_screen.dart';

class ProfessionalProfileScreen extends StatefulWidget {
  final String selectedLanguage;

  const ProfessionalProfileScreen({super.key, this.selectedLanguage = 'en'});

  @override
  State<ProfessionalProfileScreen> createState() =>
      _ProfessionalProfileScreenState();
}

class _ProfessionalProfileScreenState extends State<ProfessionalProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  final Set<String> _skills = {'Plumber'};
  final List<String> _galleryPaths = [];

  String _t(String en, String si, String ta) {
    switch (widget.selectedLanguage) {
      case 'si':
        return si;
      case 'ta':
        return ta;
      case 'en':
      default:
        return en;
    }
  }

  List<String> get _availableSkills => [
    'Electrician',
    'Plumber',
    'Carpenter',
    'Painter',
    'AC Technician',
    'Mechanic',
  ];

  Future<void> _addGalleryImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1400,
    );
    if (file == null || !mounted) return;

    setState(() {
      _galleryPaths.add(file.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    const ratings = {
      'Punctuality': 4.6,
      'Quality': 4.9,
      'Communication': 4.7,
      'Professionalism': 4.8,
      'Value': 4.5,
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      appBar: AppBar(
        title: Text(
          _t('Professional Profile', 'වෘත්තීය පැතිකඩ', 'தொழில்முறை சுயவிவரம்'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t(
                      'Identity Verification',
                      'හඳුනාගැනීම තහවුරු කිරීම',
                      'அடையாள சரிபார்ப்பு',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _t(
                      'Upload your government ID and verify with ML Kit.',
                      'රජයේ හැඳුනුම්පත උඩුගත කර ML Kit සමඟ තහවුරු කරන්න.',
                      'அரசு அடையாள அட்டையை பதிவேற்றி ML Kit மூலம் சரிபார்க்கவும்.',
                    ),
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => IdentityVerificationScreen(
                            selectedLanguage: widget.selectedLanguage,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.badge_outlined),
                    label: Text(
                      _t(
                        'Open Verification',
                        'තහවුරු කිරීම විවෘත කරන්න',
                        'சரிபார்ப்பைத் திறக்கவும்',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('Skill Categories', 'කුසලතා ප්‍රවර්ග', 'திறன் வகைகள்'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableSkills
                        .map(
                          (skill) => FilterChip(
                            label: Text(skill),
                            selected: _skills.contains(skill),
                            onSelected: (_) {
                              setState(() {
                                if (_skills.contains(skill)) {
                                  _skills.remove(skill);
                                } else {
                                  _skills.add(skill);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _t('Work Gallery', 'වැඩ ඡායාරූප', 'வேலை படத் தொகுப்பு'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _addGalleryImage,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: Text(_t('Add', 'එක් කරන්න', 'சேர்')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _galleryPaths.isEmpty ? 4 : _galleryPaths.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.25,
                        ),
                    itemBuilder: (context, index) {
                      if (_galleryPaths.isEmpty) {
                        return _galleryPlaceholder(
                          _t('Before / After', 'පෙර / පසු', 'முன் / பின்'),
                        );
                      }

                      final path = _galleryPaths[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(path), fit: BoxFit.cover),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t(
                      'Rating Details',
                      'ශ්‍රේණිගත කිරීම් විස්තර',
                      'மதிப்பீட்டு விவரங்கள்',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...ratings.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(entry.key),
                              const Spacer(),
                              Text(
                                entry.value.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: entry.value / 5,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(999),
                            backgroundColor: const Color(0xFFE2E8F0),
                            color: const Color(0xFF0B1533),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _galleryPlaceholder(String label) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_outlined, color: Color(0xFF475569)),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

