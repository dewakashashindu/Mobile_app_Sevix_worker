import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PayoutSettingsScreen extends StatefulWidget {
  final String selectedLanguage;

  const PayoutSettingsScreen({super.key, this.selectedLanguage = 'en'});

  @override
  State<PayoutSettingsScreen> createState() => _PayoutSettingsScreenState();
}

class _PayoutSettingsScreenState extends State<PayoutSettingsScreen> {
  bool _loading = false;

  // Replace this with a backend-generated Stripe Connect account onboarding URL.
  final String _stripeAccountId = 'acct_worker_demo_1234';
  final String _onboardingUrl =
      'https://connect.stripe.com/setup/s/demo_account_link';

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

  Future<void> _openStripeOnboarding() async {
    setState(() {
      _loading = true;
    });

    try {
      final uri = Uri.parse(_onboardingUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t(
                'Could not open Stripe onboarding URL.',
                'Stripe onboarding URL විවෘත කළ නොහැක.',
                'Stripe onboarding URL திறக்க முடியவில்லை.',
              ),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t(
                'Failed to launch Stripe onboarding.',
                'Stripe onboarding ආරම්භ කිරීම අසාර්ථකයි.',
                'Stripe onboarding துவக்கத் தோல்வி.',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      appBar: AppBar(
        title: Text(
          _t('Payout Settings', 'ගෙවීම් සැකසුම්', 'பேஅவுட் அமைப்புகள்'),
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
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t(
                      'Stripe Transfer Account',
                      'Stripe මාරු ගිණුම',
                      'Stripe பரிமாற்ற கணக்கு',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t('Account ID', 'ගිණුම් ID', 'கணக்கு ID'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _stripeAccountId,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _statusChip(
                              label: _t(
                                'Bank details: Not completed',
                                'බැංකු විස්තර: සම්පූර්ණ නැත',
                                'வங்கி விவரம்: நிறைவு பெறவில்லை',
                              ),
                              color: const Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _t(
                      'Use Stripe Connect onboarding to add/update your bank account for payout transfers.',
                      'ගෙවීම් මාරු සඳහා ඔබගේ බැංකු ගිණුම එකතු/යාවත්කාලීන කිරීමට Stripe Connect onboarding භාවිතා කරන්න.',
                      'பேஅவுட் பரிமாற்றங்களுக்கு உங்கள் வங்கி கணக்கை சேர்க்க/புதுப்பிக்க Stripe Connect onboarding பயன்படுத்தவும்.',
                    ),
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _openStripeOnboarding,
                      icon: _loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.open_in_new),
                      label: Text(
                        _loading
                            ? _t(
                                'Opening...',
                                'විවෘත කරමින්...',
                                'திறக்கப்படுகிறது...',
                              )
                            : _t(
                                'Manage Bank Details in Stripe',
                                'Stripe තුළ බැංකු විස්තර කළමනාකරණය කරන්න',
                                'Stripe-ல் வங்கி விவரங்களை நிர்வகிக்கவும்',
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t(
                      'Backend Integration Note',
                      'Backend ඒකාබද්ධ කිරීමේ සටහන',
                      'Backend ஒருங்கிணைப்பு குறிப்பு',
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _t(
                      'For production, generate a fresh account onboarding link from your server using Stripe API and return it to this app.',
                      'නිෂ්පාදන භාවිතයට, Stripe API භාවිතයෙන් ඔබගේ සර්වරයෙන් නව account onboarding link එකක් සෑදිය යුතුයි.',
                      'ப்ரொடக்ஷனில், Stripe API மூலம் உங்கள் சேவையகத்தில் புதிய account onboarding link உருவாக்கி இப்பிற்கு அனுப்ப வேண்டும்.',
                    ),
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      height: 1.35,
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

  Widget _statusChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
