import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:sevix_worker/features/professional/professional_models.dart';
import 'package:sevix_worker/features/professional/professional_providers.dart';

class ScheduleCalendarScreen extends ConsumerWidget {
  const ScheduleCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(scheduleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Calendar')),
      body: scheduleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Failed to load schedule')),
        data: (items) {
          return SfCalendar(
            view: CalendarView.week,
            monthViewSettings: const MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            ),
            allowedViews: const [CalendarView.week, CalendarView.month],
            dataSource: _ScheduleDataSource(items),
            onTap: (details) {
              final appointment = details.appointments?.isNotEmpty == true
                  ? details.appointments!.first as Appointment
                  : null;
              if (appointment == null) {
                return;
              }
              showModalBottomSheet<void>(
                context: context,
                builder: (_) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.subject,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${appointment.startTime} - ${appointment.endTime}',
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.navigation_outlined),
                            label: const Text('Start Navigation'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ScheduleDataSource extends CalendarDataSource {
  _ScheduleDataSource(List<JobScheduleItem> items) {
    appointments = items
        .map(
          (item) => Appointment(
            startTime: item.start,
            endTime: item.end,
            subject: item.customerName,
            color: scheduleColorFor(item.status),
            notes: item.id,
          ),
        )
        .toList();
  }
}
