import 'package:flutter/material.dart';

import '../../../core/domain/entities/zone_snapshot.dart';
import '../../../core/domain/repositories/telemetry_repository.dart';
import '../../shared/presentation/page_frame.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key, required this.repository});

  final TelemetryRepository repository;

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'Alerts',
      subtitle:
          'Rule engine placeholder for threshold violations and escalation workflows.',
      child: StreamBuilder<List<ZoneSnapshot>>(
        stream: repository.watchLiveZones(),
        builder: (context, snapshot) {
          final alerts = (snapshot.data ?? const [])
              .where((z) => z.alertRaised)
              .toList();
          if (alerts.isEmpty) {
            return const Center(child: Text('No active alerts.'));
          }
          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (_, index) {
              final z = alerts[index];
              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orangeAccent,
                  ),
                  title: Text('${z.zoneName} needs attention'),
                  subtitle: Text(
                    'Noise ${z.noiseDb.toStringAsFixed(1)} dB | Sound class: ${z.soundClass}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
