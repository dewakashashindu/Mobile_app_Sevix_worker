import 'dart:async';

import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  final String selectedLanguage; // 'en', 'si', 'ta'
  final String phoneNumber;
  final VoidCallback onVerifySuccess;
  final VoidCallback onBack;

  const OtpScreen({
    super.key,
    required this.selectedLanguage,
    required this.phoneNumber,
    required this.onVerifySuccess,
    required this.onBack,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late List<String> _otp;
  int _timer = 60;
  Timer? _countdownTimer;

  Map<String, Map<String, String>> get _translations => {
    'verifyPhone': {
      'en': 'Verify Phone Number',
      'si': 'දුරකථන අංකය තහවුරු කරන්න',
      'ta': 'தொலைபேசி எண்ணை சரிபார்க்கவும்',
    },
    'otpSent': {
      'en': 'Enter the 6-digit code sent to',
      'si': 'යවන ලද ඉලක්කම් 6 කේතය ඇතුළත් කරන්න',
      'ta': 'அனுப்பிய 6 இலக்க குறியீட்டை உள்ளிடவும்',
    },
    'verify': {'en': 'Verify', 'si': 'තහවුරු කරන්න', 'ta': 'சரிபார்க்கவும்'},
    'resendCode': {
      'en': 'Resend Code',
      'si': 'කේතය නැවත යවන්න',
      'ta': 'குறியீட்டை மீண்டும் அனுப்பவும்',
    },
    'resendIn': {
      'en': 'Resend in',
      'si': 'නැවත යැවීමට',
      'ta': 'மீண்டும் அனுப்ப',
    },
    'seconds': {'en': 'seconds', 'si': 'තත්පර', 'ta': 'விநாடிகள்'},
    'error': {'en': 'Error', 'si': 'දෝෂයකි', 'ta': 'பிழை'},
    'enterAllDigits': {
      'en': 'Please enter all 6 digits',
      'si': 'කරුණාකර ඉලක්කම් 6ම ඇතුළත් කරන්න',
      'ta': 'அனைத்து 6 இலக்கங்களையும் உள்ளிடவும்',
    },
    'back': {'en': 'Back', 'si': 'ආපසු', 'ta': 'திரும்ப'},
  };

  String _t(String key) {
    final m = _translations[key];
    if (m == null) return key;
    final lang = widget.selectedLanguage;
    return m[lang] ?? m['en'] ?? key;
  }

  @override
  void initState() {
    super.initState();
    _otp = List.filled(6, '');
    _startTimer();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _timer = 60;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timer <= 1) {
        timer.cancel();
        setState(() {
          _timer = 0;
        });
      } else {
        setState(() {
          _timer -= 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length > 1) {
      value = value.substring(value.length - 1);
    }
    _otp[index] = value;
    _controllers[index].text = value;
    _controllers[index].selection = TextSelection.fromPosition(
      TextPosition(offset: value.length),
    );

    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _handleVerify() {
    final otpString = _otp.join();
    if (otpString.length != 6 || otpString.contains(RegExp(r'[^0-9]'))) {
      _showMessage(_t('error'), _t('enterAllDigits'));
      return;
    }

    _showMessage('Success', 'Phone number verified!');
    widget.onVerifySuccess();
  }

  void _handleResend() {
    if (_timer == 0) {
      _startTimer();
      _showMessage('Success', 'OTP resent successfully!');
    }
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
                top: 32,
                bottom: mediaQuery.viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: textPrimary, size: 24),
                    onPressed: widget.onBack,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _t('verifyPhone'),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _t('otpSent'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.phoneNumber,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 48,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: cardBackground,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: borderColor,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (v) => _onOtpChanged(v, index),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _handleVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: primaryColor.withOpacity(0.6),
                      ),
                      child: Text(
                        _t('verify'),
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
                    child: Column(
                      children: [
                        Text(
                          _t('otpSent'),
                          style: TextStyle(color: textSecondary, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        if (_timer > 0)
                          Text(
                            '${_t('resendIn')} $_timer ${_t('seconds')}',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                            ),
                          )
                        else
                          TextButton(
                            onPressed: _handleResend,
                            child: Text(
                              _t('resendCode'),
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
}
