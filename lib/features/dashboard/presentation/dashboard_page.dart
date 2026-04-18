import 'package:flutter/material.dart';

import '../../../core/domain/entities/zone_snapshot.dart';
import '../../../core/domain/repositories/telemetry_repository.dart';
import '../../shared/presentation/page_frame.dart';
import '../../shared/widgets/zone_status_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.repository});

  final TelemetryRepository repository;

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'LumiSense Monitor',
      subtitle:
          'Desktop skeleton for real-time zones, alerts, analytics, and ML integration.',
      child: StreamBuilder<List<ZoneSnapshot>>(
        stream: repository.watchLiveZones(),
        builder: (context, snapshot) {
          final zones = snapshot.data ?? const [];
          if (zones.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: zones.length,
            itemBuilder: (_, index) => ZoneStatusCard(snapshot: zones[index]),
          );
        },
      ),
    );
  }
}
