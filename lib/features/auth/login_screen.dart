import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final String selectedLanguage;
  final VoidCallback onLoginSuccess;
  final VoidCallback? onNavigateToSignup;

  const LoginScreen({
    super.key,
    required this.selectedLanguage,
    required this.onLoginSuccess,
    this.onNavigateToSignup,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;

  Map<String, Map<String, String>> get _translations => {
    'login': {'en': 'Login', 'si': 'ඇතුල් වන්න', 'ta': 'உள்நுழைய'},
    'email': {'en': 'Email', 'si': 'ඊමේල්', 'ta': 'மின்னஞ்சல்'},
    'password': {'en': 'Password', 'si': 'මුරපදය', 'ta': 'கடவுச்சொல்'},
    'forgotPassword': {
      'en': 'Forgot Password?',
      'si': 'මුරපදය අමතකද?',
      'ta': 'கடவுச்சொல் மறந்துவிட்டதா?',
    },
    'orContinueWith': {
      'en': 'Or continue with',
      'si': 'නැතිනම් මෙයින් ඉදිරියට',
      'ta': 'அல்லது இதனுடன் தொடரவும்',
    },
    'welcome': {
      'en': 'Welcome Back!',
      'si': 'නැවත සාදරයෙන් පිළිගනිමු!',
      'ta': 'மீண்டும் வருக!',
    },
    'loginDescription': {
      'en': 'Sign in to continue',
      'si': 'ඉදිරියට යාමට පිවිසෙන්න',
      'ta': 'தொடர உள்நுழையவும்',
    },
    'dontHaveAccount': {
      'en': "Don't have an account?",
      'si': 'ගිණුමක් නැද්ද?',
      'ta': 'கணக்கு இல்லையா?',
    },
    'signUp': {'en': 'Sign Up', 'si': 'ලියාපදිංචි වන්න', 'ta': 'பதிவுசெய்க'},
  };

  String _t(String key) {
    final lang = widget.selectedLanguage;
    final valueForKey = _translations[key];
    if (valueForKey == null) return key;
    return valueForKey[lang] ?? valueForKey['en'] ?? key;
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Error', 'Please fill in all fields');
      return;
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      _showMessage('Error', 'Please enter a valid email address');
      return;
    }

    _showMessage('Success', 'Login successful!');
    widget.onLoginSuccess();
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final backgroundColor = theme.colorScheme.surface;
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
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 64,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('welcome'),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _t('loginDescription'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              color: textSecondary,
                            ),
                          ),
                          const SizedBox(height: 40),
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
                                    textInputAction: TextInputAction.next,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      isCollapsed: true,
                                      hintText: _t('email'),
                                      hintStyle: TextStyle(
                                        color: textSecondary,
                                        fontSize: 16,
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _InputLabel(
                            label: _t('password'),
                            color: textPrimary,
                          ),
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
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 16,
                                    ),
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
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 4.0,
                                bottom: 24.0,
                              ),
                              child: GestureDetector(
                                onTap: () {},
                                child: Text(
                                  _t('forgotPassword'),
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                shadowColor: primaryColor.withOpacity(0.6),
                              ),
                              child: Text(
                                _t('login'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: Container(height: 1, color: borderColor),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Text(
                                  _t('orContinueWith'),
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(height: 1, color: borderColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _SocialButton(
                                icon: Icons.g_mobiledata,
                                background: cardBackground,
                                borderColor: borderColor,
                                iconColor: textPrimary,
                              ),
                              const SizedBox(width: 16),
                              _SocialButton(
                                icon: Icons.apple,
                                background: cardBackground,
                                borderColor: borderColor,
                                iconColor: textPrimary,
                              ),
                              const SizedBox(width: 16),
                              _SocialButton(
                                icon: Icons.facebook,
                                background: cardBackground,
                                borderColor: borderColor,
                                iconColor: textPrimary,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _t('dontHaveAccount'),
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: widget.onNavigateToSignup,
                                child: Text(
                                  _t('signUp'),
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
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
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

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color borderColor;
  final Color iconColor;

  const _SocialButton({
    required this.icon,
    required this.background,
    required this.borderColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Icon(icon, size: 28, color: iconColor),
    );
  }
}

