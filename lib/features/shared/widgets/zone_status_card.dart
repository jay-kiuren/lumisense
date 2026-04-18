import 'package:flutter/material.dart';

import '../../../core/domain/entities/zone_snapshot.dart';
import '../../../core/domain/value_objects/noise_level.dart';

class ZoneStatusCard extends StatelessWidget {
  const ZoneStatusCard({super.key, required this.snapshot});

  final ZoneSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              snapshot.zoneName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text('Temp: ${snapshot.temperatureC.toStringAsFixed(1)} C'),
            Text('Noise: ${snapshot.noiseDb.toStringAsFixed(1)} dB'),
            Text('Sound: ${snapshot.soundClass}'),
            const Spacer(),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 12,
                  color: _color(snapshot.noiseLevel),
                ),
                const SizedBox(width: 8),
                Text(_label(snapshot.noiseLevel)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _color(NoiseLevel level) {
    switch (level) {
      case NoiseLevel.quiet:
        return Colors.greenAccent;
      case NoiseLevel.normal:
        return Colors.lightGreen;
      case NoiseLevel.warning:
        return Colors.orangeAccent;
      case NoiseLevel.critical:
        return Colors.redAccent;
    }
  }

  String _label(NoiseLevel level) {
    switch (level) {
      case NoiseLevel.quiet:
        return 'Quiet';
      case NoiseLevel.normal:
        return 'Normal';
      case NoiseLevel.warning:
        return 'Warning';
      case NoiseLevel.critical:
        return 'Critical';
    }
  }
}
