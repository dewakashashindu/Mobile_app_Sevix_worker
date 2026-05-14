import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sevix_worker/features/professional/professional_providers.dart';

class SubscriptionPlanScreen extends ConsumerWidget {
  const SubscriptionPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription Plans')),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Unable to load plans')),
        data: (plans) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: plan.current
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFE2E8F0),
                        width: plan.current ? 1.5 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                plan.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              if (plan.current)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDBEAFE),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'Current Plan',
                                    style: TextStyle(
                                      color: Color(0xFF1D4ED8),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            plan.monthlyLkr == 0
                                ? 'Free'
                                : 'LKR ${plan.monthlyLkr} / month',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...plan.features.map(
                            (f) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Color(0xFF16A34A),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(f)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: plan.current ? null : () {},
                              child: Text(
                                plan.current ? 'Current Plan' : 'Upgrade Now',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate(delay: Duration(milliseconds: 80 * index))
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.08, end: 0, duration: 300.ms);
            },
          );
        },
      ),
    );
  }
}
