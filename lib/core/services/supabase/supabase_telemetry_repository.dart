import 'dart:math' show log;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/zone_snapshot.dart';
import '../../domain/repositories/telemetry_repository.dart';
import '../../domain/value_objects/noise_level.dart';
import '../../domain/value_objects/sensor_features.dart';
import '../ml_inference_service.dart';

/// Connects to Supabase and listens for real-time sensor data.
/// Uses the brother's schema: sensors + data tables.
class SupabaseTelemetryRepository implements TelemetryRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final MLInferenceService _mlService = MLInferenceService();

  Future<void> initialize() async {
    await _mlService.initialize();
  }

  @override
  Stream<List<ZoneSnapshot>> watchLiveZones() {
    try {
      return _client.from('data').stream(primaryKey: ['id']).map((rows) {
        // Group by zone_id and take the latest reading per zone
        final Map<int, Map<String, dynamic>> latestPerZone = {};
        for (final row in rows) {
          final zoneId = row['zone_id'] as int;
          latestPerZone[zoneId] = row; // stream gives latest
        }

        return latestPerZone.values.map((row) {
          final features = SensorFeatures.fromSupabase(row['sensor_data']);

          // Convert RMS to approximate dB (for display purposes)
          final double noiseDb = features.rms > 0 ? 20 * _log10(features.rms / 1.0) : 0;

          // Run the ANN to classify the sound
          final result = _mlService.classifySound(
            avg: features.avg,
            peak: features.peak,
            min: features.min,
            rms: features.rms,
          );

          final String soundClass = result['label'] as String;
          final List<Map<String, dynamic>> soundProfile =
              (result['profile'] as List?)?.map((e) {
                    final map = e as Map;
                    return map.cast<String, dynamic>();
                  }).toList() ??
                  const <Map<String, dynamic>>[];
          final NoiseLevel level = _resolveNoiseLevel(noiseDb);

          return ZoneSnapshot(
            zoneId: row['zone_id'].toString(),
            zoneName: _getZoneName(row['zone_id'] as int),
            temperatureC: features.temperatureC,
            noiseDb: noiseDb,
            noiseLevel: level,
            soundClass: soundClass,
            soundProfile: soundProfile,
            alertRaised: level == NoiseLevel.warning || level == NoiseLevel.critical,
            updatedAt: DateTime.parse(row['timestamp'] as String),
          );
        }).toList();
      });
    } catch (e) {
      return const Stream.empty();
    }
  }

  NoiseLevel _resolveNoiseLevel(double db) {
    if (db >= 72) return NoiseLevel.critical;
    if (db >= 60) return NoiseLevel.warning;
    if (db >= 45) return NoiseLevel.normal;
    return NoiseLevel.quiet;
  }

  String _getZoneName(int zoneId) {
    switch (zoneId) {
      case 1: return 'IT Department';
      case 2: return 'CS Department';
      case 3: return 'Engineering Department';
      default: return 'Zone $zoneId';
    }
  }

  double _log10(double x) => x > 0 ? log(x) / log(10) : 0;
}
