import 'package:flutter/material.dart';

import '../../../core/domain/entities/zone_snapshot.dart';
import '../../../core/domain/repositories/telemetry_repository.dart';
import '../../shared/presentation/page_frame.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key, required this.repository});

  final TelemetryRepository repository;

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'Analytics',
      subtitle:
          'Trend widgets placeholder. Plug in historical data and charts later.',
      child: StreamBuilder<List<ZoneSnapshot>>(
        stream: repository.watchLiveZones(),
        builder: (context, snapshot) {
          final zones = snapshot.data ?? const [];
          final avgNoise = zones.isEmpty
              ? 0
              : zones.map((z) => z.noiseDb).reduce((a, b) => a + b) /
                    zones.length;
          final avgTemp = zones.isEmpty
              ? 0
              : zones.map((z) => z.temperatureC).reduce((a, b) => a + b) /
                    zones.length;

          return Row(
            children: [
              Expanded(
                child: Card(
                  child: Center(
                    child: Text(
                      'Avg Noise\n${avgNoise.toStringAsFixed(1)} dB',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Center(
                    child: Text(
                      'Avg Temp\n${avgTemp.toStringAsFixed(1)} C',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Card(
                  child: Center(
                    child: Text(
                      'ML Insights\n(coming soon)',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
