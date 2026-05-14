import 'package:flutter/material.dart';

import 'package:sevix_worker/core/press_scale.dart';

enum LoadErrorType { network, data }

class ErrorStateView extends StatelessWidget {
  final LoadErrorType type;
  final VoidCallback onRetry;
  final String selectedLanguage;

  const ErrorStateView({
    super.key,
    required this.type,
    required this.onRetry,
    this.selectedLanguage = 'en',
  });

  String _t(String en, String si, String ta) {
    switch (selectedLanguage) {
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
  Widget build(BuildContext context) {
    final isNetwork = type == LoadErrorType.network;
    final icon = isNetwork
        ? Icons.wifi_off_rounded
        : Icons.error_outline_rounded;
    final message = isNetwork
        ? _t(
            'Network failed. Please check your connection.',
            'ජාල දෝෂයකි. කරුණාකර සම්බන්ධතාව පරීක්ෂා කරන්න.',
            'வலைப்பின்னல் பிழை. உங்கள் இணைப்பைச் சரிபார்க்கவும்.',
          )
        : _t(
            'Data load failed. Please try again.',
            'දත්ත ලබාගැනීම අසාර්ථකයි. නැවත උත්සාහ කරන්න.',
            'தரவை ஏற்ற முடியவில்லை. மீண்டும் முயற்சிக்கவும்.',
          );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 50, color: const Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            PressScale(
              onTap: onRetry,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(
                  _t('Retry', 'නැවත උත්සාහ කරන්න', 'மீண்டும் முயற்சி'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

