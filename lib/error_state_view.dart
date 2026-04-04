import 'package:flutter/material.dart';

import 'press_scale.dart';

enum LoadErrorType { network, data }

class ErrorStateView extends StatelessWidget {
  final LoadErrorType type;
  final VoidCallback onRetry;

  const ErrorStateView({super.key, required this.type, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isNetwork = type == LoadErrorType.network;
    final icon = isNetwork
        ? Icons.wifi_off_rounded
        : Icons.error_outline_rounded;
    final message = isNetwork
        ? 'Network failed. Please check your connection.'
        : 'Data load failed. Please try again.';

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
                label: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
