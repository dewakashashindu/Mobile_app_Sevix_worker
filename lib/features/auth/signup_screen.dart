import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:sevix_worker/features/profile/worker_profile_data.dart';

class RegistrationState {
  final int step;
  final String fullName;
  final String telephone;
  final String nationalId;
  final String primaryTrade;
  final String yearsOfExperience;
  final String? idFrontPath;
  final String? idBackPath;
  final String? selfiePath;

  const RegistrationState({
    this.step = 0,
    this.fullName = '',
    this.telephone = '',
    this.nationalId = '',
    this.primaryTrade = '',
    this.yearsOfExperience = '',
    this.idFrontPath,
    this.idBackPath,
    this.selfiePath,
  });

  RegistrationState copyWith({
    int? step,
    String? fullName,
    String? telephone,
    String? nationalId,
    String? primaryTrade,
    String? yearsOfExperience,
    String? idFrontPath,
    String? idBackPath,
    String? selfiePath,
    bool clearFront = false,
    bool clearBack = false,
    bool clearSelfie = false,
  }) {
    return RegistrationState(
      step: step ?? this.step,
      fullName: fullName ?? this.fullName,
      telephone: telephone ?? this.telephone,
      nationalId: nationalId ?? this.nationalId,
      primaryTrade: primaryTrade ?? this.primaryTrade,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      idFrontPath: clearFront ? null : (idFrontPath ?? this.idFrontPath),
      idBackPath: clearBack ? null : (idBackPath ?? this.idBackPath),
      selfiePath: clearSelfie ? null : (selfiePath ?? this.selfiePath),
    );
  }
}

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  RegistrationNotifier() : super(const RegistrationState());

  void setStep(int step) => state = state.copyWith(step: step);
  void setFullName(String value) => state = state.copyWith(fullName: value);
  void setTelephone(String value) => state = state.copyWith(telephone: value);
  void setNationalId(String value) => state = state.copyWith(nationalId: value);
  void setPrimaryTrade(String value) =>
      state = state.copyWith(primaryTrade: value);
  void setYearsOfExperience(String value) =>
      state = state.copyWith(yearsOfExperience: value);
  void setFrontImage(String path) => state = state.copyWith(idFrontPath: path);
  void setBackImage(String path) => state = state.copyWith(idBackPath: path);
  void setSelfieImage(String path) => state = state.copyWith(selfiePath: path);

  void clearFrontImage() => state = state.copyWith(clearFront: true);
  void clearBackImage() => state = state.copyWith(clearBack: true);
  void clearSelfieImage() => state = state.copyWith(clearSelfie: true);

  void nextStep() {
    if (state.step < 3) {
      state = state.copyWith(step: state.step + 1);
    }
  }

  void previousStep() {
    if (state.step > 0) {
      state = state.copyWith(step: state.step - 1);
    }
  }
}

final registrationProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationState>(
      (ref) => RegistrationNotifier(),
    );

class SignupScreen extends ConsumerStatefulWidget {
  final String selectedLanguage;
  final ValueChanged<WorkerProfileData> onSignUpSuccess;
  final VoidCallback? onNavigateToLogin;

  const SignupScreen({
    super.key,
    required this.selectedLanguage,
    required this.onSignUpSuccess,
    this.onNavigateToLogin,
  });

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _experienceController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _showStep1Errors = false;
  bool _showStep2Errors = false;
  bool _showStep3Errors = false;

  final List<String> _tradeOptions = const [
    'Plumber',
    'Electrician',
    'Carpenter',
    'Painter',
    'AC Technician',
    'Mechanic',
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(registrationProvider);
    _fullNameController.text = state.fullName;
    _telephoneController.text = state.telephone;
    _nationalIdController.text = state.nationalId;
    _experienceController.text = state.yearsOfExperience;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _telephoneController.dispose();
    _nationalIdController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  bool _validateStep1(RegistrationState state) {
    final exp = int.tryParse(state.yearsOfExperience);
    final phoneRegex = RegExp(r'^\d{7,15}$');
    return state.fullName.trim().isNotEmpty &&
        phoneRegex.hasMatch(state.telephone.trim()) &&
        state.nationalId.trim().isNotEmpty &&
        state.primaryTrade.isNotEmpty &&
        exp != null &&
        exp >= 0;
  }

  bool _validateStep2(RegistrationState state) {
    return state.idFrontPath != null && state.idBackPath != null;
  }

  bool _validateStep3(RegistrationState state) {
    return state.selfiePath != null;
  }

  Future<void> _pickImage({
    required bool fromCamera,
    required void Function(String path) onSelected,
  }) async {
    final image = await _imagePicker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1800,
    );
    if (image == null) return;
    onSelected(image.path);
  }

  Future<void> _showImageSourcePicker({
    required String title,
    required void Function(String path) onSelected,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(title),
                  subtitle: const Text('Choose source'),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Camera'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _pickImage(fromCamera: true, onSelected: onSelected);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Gallery'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _pickImage(fromCamera: false, onSelected: onSelected);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleNext() {
    final notifier = ref.read(registrationProvider.notifier);
    final state = ref.read(registrationProvider);

    if (state.step == 0) {
      setState(() => _showStep1Errors = true);
      if (!_validateStep1(state)) return;
    }

    if (state.step == 1) {
      setState(() => _showStep2Errors = true);
      if (!_validateStep2(state)) return;
    }

    if (state.step == 2) {
      setState(() => _showStep3Errors = true);
      if (!_validateStep3(state)) return;
    }

    notifier.nextStep();
  }

  void _handleSubmit(RegistrationState state) {
    setState(() {
      _showStep1Errors = true;
      _showStep2Errors = true;
      _showStep3Errors = true;
    });

    if (!_validateStep1(state) ||
        !_validateStep2(state) ||
        !_validateStep3(state)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required steps.')),
      );
      return;
    }

    widget.onSignUpSuccess(
      WorkerProfileData(
        fullName: state.fullName,
        profilePhotoPath: state.selfiePath ?? '',
        email: '',
        countryCode: '+94',
        telephone: state.telephone.trim(),
        dateOfBirth: '',
        address: '',
        city: '',
        nationalId: state.nationalId,
        workerTypes: [state.primaryTrade.toLowerCase().replaceAll(' ', '-')],
        experienceYears: state.yearsOfExperience,
        bio: '',
        serviceRadiusKm: '5',
        nicPhotoPath: state.idFrontPath ?? '',
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registration submitted successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationProvider);
    final notifier = ref.read(registrationProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Worker Registration & KYC')),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an account?'),
              TextButton(
                onPressed: widget.onNavigateToLogin,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: state.step,
        onStepTapped: notifier.setStep,
        onStepContinue: state.step == 3 ? null : _handleNext,
        onStepCancel: notifier.previousStep,
        controlsBuilder: (context, details) {
          final isLast = state.step == 3;
          return Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: isLast
                      ? () => _handleSubmit(state)
                      : details.onStepContinue,
                  child: Text(isLast ? 'Submit' : 'Next'),
                ),
                const SizedBox(width: 10),
                if (state.step > 0)
                  OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
              ],
            ),
          );
        },
        steps: [
          Step(
            isActive: state.step >= 0,
            title: const Text('Step 1: Personal & Professional Details'),
            content: Column(
              children: [
                TextField(
                  controller: _fullNameController,
                  onChanged: notifier.setFullName,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    errorText: _showStep1Errors && state.fullName.trim().isEmpty
                        ? 'Full name is required'
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: notifier.setTelephone,
                  decoration: InputDecoration(
                    labelText: 'Telephone Number',
                    errorText:
                        _showStep1Errors &&
                            !RegExp(
                              r'^\d{7,15}$',
                            ).hasMatch(state.telephone.trim())
                        ? 'Enter a valid telephone number'
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nationalIdController,
                  onChanged: notifier.setNationalId,
                  decoration: InputDecoration(
                    labelText: 'National ID Number',
                    errorText:
                        _showStep1Errors && state.nationalId.trim().isEmpty
                        ? 'National ID is required'
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: state.primaryTrade.isEmpty
                      ? null
                      : state.primaryTrade,
                  items: _tradeOptions
                      .map(
                        (trade) =>
                            DropdownMenuItem(value: trade, child: Text(trade)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      notifier.setPrimaryTrade(value);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Primary Trade',
                    errorText: _showStep1Errors && state.primaryTrade.isEmpty
                        ? 'Primary trade is required'
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _experienceController,
                  keyboardType: TextInputType.number,
                  onChanged: notifier.setYearsOfExperience,
                  decoration: InputDecoration(
                    labelText: 'Years of Experience',
                    errorText:
                        _showStep1Errors &&
                            (state.yearsOfExperience.trim().isEmpty ||
                                int.tryParse(state.yearsOfExperience) == null)
                        ? 'Enter valid years of experience'
                        : null,
                  ),
                ),
              ],
            ),
          ),
          Step(
            isActive: state.step >= 1,
            title: const Text('Step 2: Document Upload (Manual KYC)'),
            content: Column(
              children: [
                _UploadCard(
                  title: 'Front of ID',
                  imagePath: state.idFrontPath,
                  onPick: () => _showImageSourcePicker(
                    title: 'Upload Front of ID',
                    onSelected: notifier.setFrontImage,
                  ),
                  onRemove: notifier.clearFrontImage,
                ),
                if (_showStep2Errors && state.idFrontPath == null)
                  const _ErrorText('Front of ID is required'),
                const SizedBox(height: 12),
                _UploadCard(
                  title: 'Back of ID',
                  imagePath: state.idBackPath,
                  onPick: () => _showImageSourcePicker(
                    title: 'Upload Back of ID',
                    onSelected: notifier.setBackImage,
                  ),
                  onRemove: notifier.clearBackImage,
                ),
                if (_showStep2Errors && state.idBackPath == null)
                  const _ErrorText('Back of ID is required'),
              ],
            ),
          ),
          Step(
            isActive: state.step >= 2,
            title: const Text('Step 3: Identity Confirmation (Selfie)'),
            content: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Live Selfie',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0B1533),
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: state.selfiePath == null
                        ? Container(
                            color: const Color(0xFFE2E8F0),
                            child: const Center(
                              child: Icon(Icons.person, size: 70),
                            ),
                          )
                        : Image.file(
                            File(state.selfiePath!),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _showImageSourcePicker(
                    title: 'Capture Live Selfie',
                    onSelected: notifier.setSelfieImage,
                  ),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(
                    state.selfiePath == null
                        ? 'Capture Selfie'
                        : 'Retake Selfie',
                  ),
                ),
                if (state.selfiePath != null)
                  TextButton.icon(
                    onPressed: notifier.clearSelfieImage,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove'),
                  ),
                if (_showStep3Errors && state.selfiePath == null)
                  const _ErrorText(
                    'Selfie is required for identity confirmation',
                  ),
              ],
            ),
          ),
          Step(
            isActive: state.step >= 3,
            title: const Text('Step 4: Submission'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Review your details and submit registration.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 10),
                _SummaryTile(label: 'Full Name', value: state.fullName),
                _SummaryTile(label: 'Telephone', value: state.telephone),
                _SummaryTile(label: 'National ID', value: state.nationalId),
                _SummaryTile(label: 'Primary Trade', value: state.primaryTrade),
                _SummaryTile(
                  label: 'Experience',
                  value: '${state.yearsOfExperience} years',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap Submit to finish worker registration and KYC.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  final String title;
  final String? imagePath;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _UploadCard({
    required this.title,
    required this.imagePath,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (imagePath == null)
            SizedBox(
              width: double.infinity,
              height: 160,
              child: OutlinedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.upload_outlined),
                label: const Text('Upload via Camera or Gallery'),
              ),
            )
          else
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(imagePath!),
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onPick,
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Retake'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onRemove,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Remove'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String text;

  const _ErrorText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFB42318),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF475569)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
