import 'package:flutter/material.dart';

class LanguageSelectScreen extends StatefulWidget {
  final ValueChanged<String> onLanguageSelect;

  const LanguageSelectScreen({super.key, required this.onLanguageSelect});

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _Language {
  final String code;
  final String name;
  final String nameEn;
  final IconData icon;

  const _Language({
    required this.code,
    required this.name,
    required this.nameEn,
    required this.icon,
  });
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  String? _selectedLanguage;

  static const List<_Language> _languages = [
    _Language(
      code: 'si',
      name: 'සිංහල',
      nameEn: 'Sinhala',
      icon: Icons.language,
    ),
    _Language(
      code: 'en',
      name: 'English',
      nameEn: 'English',
      icon: Icons.public,
    ),
    _Language(
      code: 'ta',
      name: 'தமிழ்',
      nameEn: 'Tamil',
      icon: Icons.translate,
    ),
  ];

  String _getContinueText() {
    switch (_selectedLanguage) {
      case 'si':
        return 'ඉදිරියට යන්න';
      case 'ta':
        return 'தொடரவும்';
      case 'en':
      default:
        return 'Continue to App';
    }
  }

  void _handleLanguageTap(String code) {
    setState(() {
      _selectedLanguage = code;
    });
  }

  void _handleContinue() {
    final code = _selectedLanguage;
    if (code != null) {
      widget.onLanguageSelect(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0B1533),
                  Color(0xFF1a2951),
                  Color(0xFF0d1a3d),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -150,
            right: -100,
            child: _DecorativeCircle(diameter: 300),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: _DecorativeCircle(diameter: 200),
          ),
          Positioned(
            top: 200,
            left: 50,
            child: _DecorativeCircle(diameter: 150),
          ),
          SafeArea(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(opacity: value, child: child);
              },
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _Header(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              const SizedBox(height: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Choose Your Language',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'ඔබගේ භාෂාව තෝරන්න • உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color.fromARGB(204, 255, 255, 255),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Column(
                                children: _languages.map((language) {
                                  final isSelected =
                                      _selectedLanguage == language.code;
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 18.0,
                                    ),
                                    child: _LanguageCard(
                                      language: language,
                                      isSelected: isSelected,
                                      onTap: () =>
                                          _handleLanguageTap(language.code),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              _ContinueButton(
                                enabled: _selectedLanguage != null,
                                label: _selectedLanguage == null
                                    ? 'Select Your Language'
                                    : _getContinueText(),
                                onPressed: _selectedLanguage != null
                                    ? _handleContinue
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                '✨ You can change this anytime in settings',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color.fromARGB(179, 255, 255, 255),
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: size.height * 0.02),
                            ],
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
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 3,
                  ),
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(64, 255, 255, 255),
                      Color.fromARGB(26, 255, 255, 255),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.language, color: Colors.white, size: 44),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sevix Worker',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: Color.fromARGB(77, 0, 0, 0),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Begin Your Journey',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(217, 255, 255, 255),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double diameter;

  const _DecorativeCircle({required this.diameter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final _Language language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.0 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: const Color.fromARGB(242, 225, 238, 252),
            border: Border.all(
              color: Colors.white.withOpacity(isSelected ? 1.0 : 0.9),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isSelected ? 0.25 : 0.12),
                offset: const Offset(0, 4),
                blurRadius: isSelected ? 16 : 10,
              ),
            ],
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFFE7F4FF), Color(0xFFCFE2FB)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
              color: !isSelected
                  ? const Color.fromARGB(250, 233, 244, 255)
                  : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: Colors.white.withOpacity(isSelected ? 0.35 : 0.25),
                border: Border.all(
                  color: Colors.white.withOpacity(isSelected ? 0.9 : 0.6),
                  width: 0.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: LinearGradient(
                              colors: isSelected
                                  ? const [
                                      Color.fromARGB(230, 255, 255, 255),
                                      Color.fromARGB(242, 231, 244, 255),
                                    ]
                                  : const [
                                      Color.fromARGB(230, 233, 244, 255),
                                      Color.fromARGB(242, 255, 255, 255),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  language.icon,
                                  size: 24,
                                  color: isSelected
                                      ? const Color(0xFF20324A)
                                      : const Color(0xFF355C8A),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  language.code.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: Color(0xFF4a5b73),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            language.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0B1533),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            language.nameEn,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                              color: isSelected
                                  ? const Color(0xFF4a5b73)
                                  : const Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(230, 255, 255, 255),
                            Color.fromARGB(230, 230, 244, 255),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF355C8A),
                        size: 28,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final bool enabled;
  final String label;
  final VoidCallback? onPressed;

  const _ContinueButton({
    required this.enabled,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: enabled
            ? const Color.fromARGB(242, 225, 238, 252)
            : const Color.fromARGB(230, 233, 244, 255),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(enabled ? 0.18 : 0.15),
            offset: const Offset(0, 6),
            blurRadius: enabled ? 14 : 8,
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: enabled
              ? const LinearGradient(
                  colors: [Color(0xFFE7F4FF), Color(0xFFCFE2FB)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          color: !enabled ? const Color.fromARGB(230, 233, 244, 255) : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: enabled
                ? Colors.white.withOpacity(0.45)
                : Colors.transparent,
            border: Border.all(
              color: Colors.white.withOpacity(enabled ? 0.8 : 0.0),
              width: enabled ? 0.5 : 0.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!enabled)
                const Icon(
                  Icons.language,
                  size: 24,
                  color: Color.fromARGB(128, 255, 255, 255),
                ),
              if (!enabled) const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: enabled ? 19 : 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: enabled
                      ? const Color(0xFF20324A)
                      : const Color.fromARGB(153, 32, 50, 74),
                ),
              ),
              if (enabled) const SizedBox(width: 14),
              if (enabled)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: const Color.fromARGB(204, 255, 255, 255),
                    border: Border.all(
                      color: const Color(0xFFC9DAEE),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    size: 22,
                    color: Color(0xFF355C8A),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (!enabled) {
      return buttonChild;
    }

    return GestureDetector(onTap: onPressed, child: buttonChild);
  }
}
