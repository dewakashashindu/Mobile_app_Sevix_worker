import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sevix_worker/features/professional/professional_providers.dart';

class FeaturedListingScreen extends ConsumerWidget {
  const FeaturedListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(featuredListingProvider);
    final notifier = ref.read(featuredListingProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Featured Listing Boost')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '24h Visibility Boost',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Boost your worker profile to the top of customer search results.',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: state.boostEnabled,
                    onChanged: notifier.toggleBoost,
                    title: const Text('Enable Featured Boost'),
                  ),
                  const SizedBox(height: 10),
                  Text('Duration: ${state.hours} hours'),
                  Slider(
                    value: state.hours.toDouble(),
                    min: 12,
                    max: 72,
                    divisions: 10,
                    label: '${state.hours}h',
                    onChanged: (v) => notifier.setHours(v.round()),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFFEFF6FF),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search Result Preview',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF0B1533),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: const Text('SEVIX Pro Worker - You'),
                      subtitle: Text(
                        state.boostEnabled
                            ? 'Top Position • ${state.hours}h Boost Active'
                            : 'Standard Position',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: state.boostEnabled
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF94A3B8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          state.boostEnabled ? 'Featured' : 'Normal',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: state.boostEnabled ? () {} : null,
                    icon: const Icon(Icons.campaign_outlined),
                    label: const Text('Purchase Boost'),
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
