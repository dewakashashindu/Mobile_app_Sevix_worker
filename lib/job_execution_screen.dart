import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'worker_job.dart';

class JobExecutionScreen extends StatefulWidget {
  final WorkerJob job;
  final String selectedLanguage;

  const JobExecutionScreen({
    super.key,
    required this.job,
    this.selectedLanguage = 'en',
  });

  @override
  State<JobExecutionScreen> createState() => _JobExecutionScreenState();
}

class _JobExecutionScreenState extends State<JobExecutionScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<Offset?> _signaturePoints = [];

  String _status = 'started';
  String? _completionProofPath;

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

  Future<void> _openRouteInGoogleMaps() async {
    final lat = widget.job.latitude;
    final lng = widget.job.longitude;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'Unable to launch Google Maps.',
              'Google Maps විවෘත කළ නොහැක.',
              'Google Maps திறக்க முடியவில்லை.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _pickCompletionProof() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1800,
    );
    if (!mounted || file == null) return;

    setState(() {
      _completionProofPath = file.path;
    });
  }

  void _submitCompletion() {
    if (_completionProofPath == null || _signaturePoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'Please add completion photo and customer signature.',
              'කරුණාකර සම්පූර්ණත්ව ඡායාරූපය සහ පාරිභෝගික අත්සන එක් කරන්න.',
              'பணி முடிவு படம் மற்றும் வாடிக்கையாளர் கையொப்பத்தை சேர்க்கவும்.',
            ),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _t(
            'Completion proof submitted successfully.',
            'සම්පූර්ණත්ව සාක්ෂිය සාර්ථකව යොමු කරන ලදී.',
            'பணி முடிவு ஆதாரம் வெற்றிகரமாக சமர்ப்பிக்கப்பட்டது.',
          ),
        ),
      ),
    );
  }

  double get _progress {
    switch (_status) {
      case 'started':
        return 0.35;
      case 'paused':
        return 0.55;
      case 'completed':
        return 1.0;
      default:
        return 0.2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      appBar: AppBar(
        title: Text(
          _t('Job Execution', 'වැඩ ක්‍රියාත්මක කිරීම', 'வேலை செயல்பாடு'),
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
                    '${widget.job.category} - ${widget.job.customerName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(widget.job.location),
                  const SizedBox(height: 10),
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFDDE8FF), Color(0xFFF6FAFF)],
                      ),
                      border: Border.all(color: const Color(0xFFCFD8EA)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.map_outlined,
                          size: 42,
                          color: Color(0xFF0B1533),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _t(
                            'Fastest route via Google Maps',
                            'Google Maps හරහා වේගවත්ම මාර්ගය',
                            'Google Maps மூலம் விரைவான பாதை',
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _openRouteInGoogleMaps,
                          icon: const Icon(Icons.navigation_outlined),
                          label: Text(
                            _t(
                              'Open Route Map',
                              'මාර්ග සිතියම විවෘත කරන්න',
                              'பாதை வரைபடத்தை திறக்கவும்',
                            ),
                          ),
                        ),
                      ],
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
                    _t(
                      'Status Progress',
                      'තත්ත්ව ප්‍රගතිය',
                      'நிலை முன்னேற்றம்',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: _progress,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _statusButton(
                        'started',
                        Icons.play_arrow,
                        _t('Started Work', 'වැඩ ආරම්භය', 'வேலை தொடங்கு'),
                      ),
                      _statusButton(
                        'paused',
                        Icons.pause,
                        _t('Paused', 'නවතා ඇත', 'இடைநிறுத்தம்'),
                      ),
                      _statusButton(
                        'completed',
                        Icons.task_alt,
                        _t('Completed', 'සම්පූර්ණයි', 'முடிந்தது'),
                      ),
                    ],
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
                      'Completion Proof',
                      'සම්පූර්ණත්ව සාක්ෂිය',
                      'பணி முடிவு ஆதாரம்',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _t(
                      'Take finished work photo and collect customer signature.',
                      'අවසන් වැඩ ඡායාරූපය ගෙන පාරිභෝගික අත්සන ලබාගන්න.',
                      'முடிந்த வேலை படத்தை எடுத்து வாடிக்கையாளர் கையொப்பம் பெறவும்.',
                    ),
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 170,
                    width: double.infinity,
                    child: _completionProofPath == null
                        ? OutlinedButton.icon(
                            onPressed: _pickCompletionProof,
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: Text(
                              _t(
                                'Take Completion Photo',
                                'සම්පූර්ණත්ව ඡායාරූපයක් ගන්න',
                                'பணி முடிவு புகைப்படம் எடுக்கவும்',
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_completionProofPath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _t(
                      'Customer Signature',
                      'පාරිභෝගික අත්සන',
                      'வாடிக்கையாளர் கையொப்பம்',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _signaturePoints.add(details.localPosition);
                        });
                      },
                      onPanEnd: (_) {
                        setState(() {
                          _signaturePoints.add(null);
                        });
                      },
                      child: CustomPaint(
                        painter: _SignaturePainter(_signaturePoints),
                        child: Container(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _signaturePoints.clear();
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: Text(
                          _t(
                            'Clear Signature',
                            'අත්සන මකන්න',
                            'கையொப்பம் நீக்கு',
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _submitCompletion,
                        icon: const Icon(Icons.cloud_upload_outlined),
                        label: Text(
                          _t(
                            'Submit Proof',
                            'සාක්ෂිය යොමු කරන්න',
                            'ஆதாரத்தை சமர்ப்பிக்கவும்',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusButton(String key, IconData icon, String label) {
    final isSelected = _status == key;
    return ChoiceChip(
      avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : null),
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF0B1533),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF0F172A),
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) {
        setState(() {
          _status = key;
        });
      },
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  _SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      if (p1 != null && p2 != null) {
        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
