import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/analytics_range_selector.dart';
import 'widgets/department_card.dart';
import 'widgets/floor_plan_widget.dart';
import 'widgets/quick_stats_row.dart';
import 'widgets/action_center.dart';
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

          // Main Content Responsive Layout
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 900) {
                  // Mobile/Tablet Vertical Layout
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Stats and Cards on top for mobile
                        const QuickStatsRow(),
                        const SizedBox(height: 24),
                        const ActionCenter(),
                        const SizedBox(height: 24),
                        ...mockZones.map((z) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: DepartmentCard(snapshot: z),
                            )),
                        // AI Floor Plan at the bottom
                        const SizedBox(height: 16),
                        const SizedBox(
                          height: 400, // Fixed height when in column
                          child: FloorPlanWidget(),
                        ),
                      ],
                    ),
                  );
                }

                // Desktop Horizontal Layout
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side: AI Floor Plan
                    const Expanded(
                      flex: 5,
                      child: FloorPlanWidget(),
                    ),
                    const SizedBox(width: 24),
                    // Right side: Stats and Cards
                    Expanded(
                      flex: 4,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const QuickStatsRow(),
                            const SizedBox(height: 24),
                            const ActionCenter(),
                            const SizedBox(height: 24),
                            ...mockZones.map((z) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: DepartmentCard(snapshot: z),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
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
