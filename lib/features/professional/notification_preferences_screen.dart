import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sevix_worker/features/professional/professional_providers.dart';

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);
    final notifier = ref.read(notificationPrefsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: SwitchListTile.adaptive(
              value: prefs.newJobsInRadius,
              onChanged: notifier.setNewJobs,
              title: const Text('New Jobs in Radius'),
              subtitle: const Text('Get alerts for jobs near your location'),
            ),
          ),
          Card(
            child: SwitchListTile.adaptive(
              value: prefs.paymentReceived,
              onChanged: notifier.setPayment,
              title: const Text('Payment Received'),
              subtitle: const Text('Notify when escrow is released to wallet'),
            ),
          ),
          Card(
            child: SwitchListTile.adaptive(
              value: prefs.chatMessages,
              onChanged: notifier.setChat,
              title: const Text('Chat Messages'),
              subtitle: const Text('Notify when customer sends a message'),
            ),
          ),
          Card(
            child: SwitchListTile.adaptive(
              value: prefs.bidUpdates,
              onChanged: notifier.setBidUpdates,
              title: const Text('Bid Updates'),
              subtitle: const Text('Notify for accepted/rejected bids'),
            ),
          ),
        ],
      ),
    );
  }
}
