import 'package:flutter/material.dart';

import '../../../core/domain/entities/zone_snapshot.dart';
import '../../../core/domain/repositories/telemetry_repository.dart';
import '../../shared/presentation/page_frame.dart';

class ZonesPage extends StatelessWidget {
  const ZonesPage({super.key, required this.repository});

  final TelemetryRepository repository;

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'Zones',
      subtitle:
          'Per-zone details. Add controls here for manual overrides and staff actions.',
      child: StreamBuilder<List<ZoneSnapshot>>(
        stream: repository.watchLiveZones(),
        builder: (context, snapshot) {
          final zones = snapshot.data ?? const [];
          return ListView.separated(
            itemCount: zones.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final z = zones[index];
              return Card(
                child: ListTile(
                  title: Text(z.zoneName),
                  subtitle: Text(
                    'Updated ${z.updatedAt.hour}:${z.updatedAt.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: Text(
                    '${z.noiseDb.toStringAsFixed(1)} dB | ${z.temperatureC.toStringAsFixed(1)} C',
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
