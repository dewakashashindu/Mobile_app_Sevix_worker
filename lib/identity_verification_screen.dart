import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class IdentityVerificationScreen extends StatefulWidget {
  final String selectedLanguage;

  const IdentityVerificationScreen({super.key, this.selectedLanguage = 'en'});

  @override
  State<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState
    extends State<IdentityVerificationScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _idController = TextEditingController();

  String? _idPhotoPath;
  String? _verificationMessage;
  bool _isVerifying = false;
  bool _isVerified = false;

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

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1800,
    );
    if (!mounted || file == null) return;

    setState(() {
      _idPhotoPath = file.path;
      _verificationMessage = null;
      _isVerified = false;
    });
  }

  Future<void> _pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1800,
    );
    if (!mounted || file == null) return;

    setState(() {
      _idPhotoPath = file.path;
      _verificationMessage = null;
      _isVerified = false;
    });
  }

  Future<void> _verifyWithMlKit() async {
    if (_idPhotoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'Please upload an ID image first.',
              'කරුණාකර පළමුව හැඳුනුම්පත් රූපයක් උඩුගත කරන්න.',
              'முதலில் அடையாள அட்டை படத்தை பதிவேற்றவும்.',
            ),
          ),
        ),
      );
      return;
    }

    final idNumber = _idController.text.trim().toUpperCase();
    if (idNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'Enter ID number to verify against OCR result.',
              'OCR ප්‍රතිඵලයට සසඳා බැලීමට හැඳුනුම් අංකය ඇතුළත් කරන්න.',
              'OCR முடிவுடன் சரிபார்க்க அடையாள எண்ணை உள்ளிடவும்.',
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _verificationMessage = null;
      _isVerified = false;
    });

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFilePath(_idPhotoPath!);
      final recognizedText = await recognizer.processImage(inputImage);
      final normalized = recognizedText.text.toUpperCase().replaceAll(
        RegExp(r'\s+'),
        '',
      );
      final expected = idNumber.replaceAll(RegExp(r'\s+'), '');

      final matched = normalized.contains(expected);

      if (!mounted) return;
      setState(() {
        _isVerified = matched;
        _verificationMessage = matched
            ? _t(
                'Verified: ID number was detected by ML Kit OCR.',
                'තහවුරු කරන ලදී: ML Kit OCR මඟින් හැඳුනුම් අංකය හඳුනාගන්නා ලදී.',
                'சரிபார்க்கப்பட்டது: ML Kit OCR மூலம் அடையாள எண் கண்டறியப்பட்டது.',
              )
            : _t(
                'Unable to match ID number from OCR text. Please retake a clearer image.',
                'OCR පෙළෙන් හැඳුනුම් අංකය ගැළපීමට නොහැකි විය. පැහැදිලි රූපයක් නැවත ගන්න.',
                'OCR உரையில் அடையாள எண்ணை பொருத்த முடியவில்லை. தெளிவான படத்தை மீண்டும் எடுக்கவும்.',
              );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _verificationMessage = _t(
          'Verification failed. Please try again.',
          'තහවුරු කිරීම අසාර්ථකයි. නැවත උත්සාහ කරන්න.',
          'சரிபார்ப்பு தோல்வி. மீண்டும் முயற்சிக்கவும்.',
        );
      });
    } finally {
      await recognizer.close();
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _t(
            'Identity Verification',
            'හඳුනාගැනීම තහවුරු කිරීම',
            'அடையாள சரிபார்ப்பு',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _t(
              'Upload your government ID and verify it with ML Kit OCR.',
              'රජයේ හැඳුනුම්පත උඩුගත කර ML Kit OCR සමඟ තහවුරු කරන්න.',
              'அரசு அடையாள அட்டையை பதிவேற்றி ML Kit OCR மூலம் சரிபார்க்கவும்.',
            ),
            style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _idController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: _t(
                'Government ID Number',
                'රජයේ හැඳුනුම් අංකය',
                'அரசு அடையாள எண்',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 210,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFCBD5E1)),
              color: const Color(0xFFF8FAFC),
            ),
            child: _idPhotoPath == null
                ? Center(
                    child: Text(
                      _t(
                        'No ID image selected',
                        'ID රූපයක් තෝරා නොමැත',
                        'ID படம் தேர்ந்தெடுக்கப்படவில்லை',
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      File(_idPhotoPath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(
                    _t(
                      'Take Photo',
                      'ඡායාරූපයක් ගන්න',
                      'புகைப்படம் எடுக்கவும்',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_outlined),
                  label: Text(
                    _t(
                      'Choose Image',
                      'රූපයක් තෝරන්න',
                      'படத்தைத் தேர்ந்தெடுக்கவும்',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isVerifying ? null : _verifyWithMlKit,
            icon: _isVerifying
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.verified_outlined),
            label: Text(
              _isVerifying
                  ? _t(
                      'Verifying...',
                      'තහවුරු කරමින්...',
                      'சரிபார்க்கப்படுகிறது...',
                    )
                  : _t(
                      'Verify With ML Kit',
                      'ML Kit සමඟ තහවුරු කරන්න',
                      'ML Kit மூலம் சரிபார்க்கவும்',
                    ),
            ),
          ),
          if (_verificationMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isVerified
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _isVerified ? Icons.check_circle : Icons.error_outline,
                    color: _isVerified
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB91C1C),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _verificationMessage!,
                      style: TextStyle(
                        color: _isVerified
                            ? const Color(0xFF14532D)
                            : const Color(0xFF7F1D1D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
