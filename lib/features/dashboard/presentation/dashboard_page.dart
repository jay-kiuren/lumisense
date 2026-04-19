import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/analytics_range_selector.dart';
import 'widgets/department_card.dart';
import 'widgets/floor_plan_widget.dart';
import 'widgets/quick_stats_row.dart';
import '../../../core/domain/entities/zone_snapshot.dart';
import '../../../core/domain/value_objects/noise_level.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final mockZones = [
      ZoneSnapshot(
        zoneId: 'it',
        zoneName: 'IT Department',
        temperatureC: 24.5,
        noiseDb: 42.3,
        noiseLevel: NoiseLevel.quiet,
        soundClass: 'ambient',
        alertRaised: false,
        updatedAt: now,
      ),
      ZoneSnapshot(
        zoneId: 'cs',
        zoneName: 'CS Department',
        temperatureC: 26.1,
        noiseDb: 58.7,
        noiseLevel: NoiseLevel.normal,
        soundClass: 'conversation',
        alertRaised: false,
        updatedAt: now.subtract(const Duration(seconds: 15)),
      ),
      ZoneSnapshot(
        zoneId: 'eng',
        zoneName: 'Engineering Department',
        temperatureC: 28.9,
        noiseDb: 73.2,
        noiseLevel: NoiseLevel.critical,
        soundClass: 'loud_talking',
        alertRaised: true,
        updatedAt: now.subtract(const Duration(seconds: 5)),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page header
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formattedDate(now),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ),
              const Spacer(),
              const AnalyticsRangeSelector(),
            ],
          ),

          const SizedBox(height: 28),

          // Quick stats
          const QuickStatsRow(),

          const SizedBox(height: 24),

          // Department cards
          Row(
            children: mockZones
                .map(
                  (z) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: z != mockZones.last ? 16.0 : 0,
                      ),
                      child: DepartmentCard(snapshot: z),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 24),

          // Bottom section: AI Floor Plan
          const Expanded(
            child: FloorPlanWidget(),
          ),
        ],
      ),
    );
  }

  String _formattedDate(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
