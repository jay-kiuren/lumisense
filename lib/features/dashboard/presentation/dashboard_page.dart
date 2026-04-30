import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/analytics_range_selector.dart';
import 'widgets/department_card.dart';
import 'widgets/floor_plan_widget.dart';
import 'widgets/action_center.dart';
import 'widgets/summary_panel.dart';
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

    return ColoredBox(
      color: AppColors.workspaceBg,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 64,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formattedDate(now),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const AnalyticsRangeSelector(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(
                    flex: 4,
                    child: FloorPlanWidget(),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 380,
                    child: _LiveZonesPanel(zones: mockZones),
                  ),
                  const SizedBox(width: 16),
                  const SizedBox(
                    width: 340,
                    child: Column(
                      children: [
                        ActionCenter(),
                        SizedBox(height: 16),
                        Expanded(child: SummaryPanel()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveZones(List<ZoneSnapshot> zones) {
    if (zones.length <= 3) {
      return Column(
        children: [
          for (int i = 0; i < zones.length; i++) ...[
            Expanded(child: DepartmentCard(snapshot: zones[i])),
            if (i != zones.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: zones.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => DepartmentCard(snapshot: zones[index]),
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

class _LiveZonesPanel extends StatelessWidget {
  const _LiveZonesPanel({required this.zones});

  final List<ZoneSnapshot> zones;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.shadowMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Zones',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 14),
          Expanded(child: _buildZones(context)),
        ],
      ),
    );
  }

  Widget _buildZones(BuildContext context) {
    if (zones.length <= 3) {
      return Column(
        children: [
          for (int i = 0; i < zones.length; i++) ...[
            Expanded(child: DepartmentCard(snapshot: zones[i])),
            if (i != zones.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: zones.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => DepartmentCard(snapshot: zones[index]),
    );
  }
}
