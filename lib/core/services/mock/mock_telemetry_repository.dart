import 'dart:math';

import '../../domain/entities/zone_snapshot.dart';
import '../../domain/repositories/telemetry_repository.dart';
import '../../domain/value_objects/noise_level.dart';

class MockTelemetryRepository implements TelemetryRepository {
  final Random _random = Random();

  @override
  Stream<List<ZoneSnapshot>> watchLiveZones() async* {
    yield _buildSnapshots();

    while (true) {
      await Future<void>.delayed(const Duration(seconds: 2));
      yield _buildSnapshots();
    }
  }

  List<ZoneSnapshot> _buildSnapshots() {
    final now = DateTime.now();
    final zones = [
      (id: 'it', name: 'IT Zone'),
      (id: 'cs', name: 'CS Zone'),
      (id: 'eng', name: 'Engineering Zone'),
    ];

    return zones.map((zone) {
      final temp = 21 + _random.nextDouble() * 8;
      final noise = 35 + _random.nextDouble() * 45;
      final level = _resolveNoiseLevel(noise);
      return ZoneSnapshot(
        zoneId: zone.id,
        zoneName: zone.name,
        temperatureC: temp,
        noiseDb: noise,
        noiseLevel: level,
        soundClass: _soundClassFor(level),
        alertRaised:
            level == NoiseLevel.warning || level == NoiseLevel.critical,
        updatedAt: now,
      );
    }).toList();
  }

  NoiseLevel _resolveNoiseLevel(double db) {
    if (db >= 72) return NoiseLevel.critical;
    if (db >= 60) return NoiseLevel.warning;
    if (db >= 45) return NoiseLevel.normal;
    return NoiseLevel.quiet;
  }

  String _soundClassFor(NoiseLevel level) {
    switch (level) {
      case NoiseLevel.quiet:
        return 'ambient';
      case NoiseLevel.normal:
        return 'conversation';
      case NoiseLevel.warning:
        return 'chair_dragging';
      case NoiseLevel.critical:
        return 'loud_talking';
    }
  }
}
