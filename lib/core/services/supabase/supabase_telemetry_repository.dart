import 'dart:math' show log;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/zone_snapshot.dart';
import '../../domain/repositories/telemetry_repository.dart';
import '../../domain/value_objects/noise_level.dart';
import '../ml_inference_service.dart';

/// Connects to Supabase and listens for real-time sensor data.
/// Uses the full LUMISENSE SQL schema: sensor_readings, zone_status, noise_events.
class SupabaseTelemetryRepository implements TelemetryRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final MLInferenceService _mlService = MLInferenceService();

  Future<void> initialize() async {
    await _mlService.initialize();
  }

  @override
  Stream<List<ZoneSnapshot>> watchLiveZones() {
    try {
      return _client.from('sensor_readings').stream(primaryKey: ['id']).map((rows) {
        // Group by zone_id and take the latest reading per zone
        final Map<int, Map<String, dynamic>> latestPerZone = {};
        for (final row in rows) {
          final zoneId = row['zone_id'] as int;
          // stream gives latest, but just to be safe we pick the highest ID
          if (!latestPerZone.containsKey(zoneId) || 
              (row['id'] as int) > (latestPerZone[zoneId]!['id'] as int)) {
            latestPerZone[zoneId] = row;
          }
        }

        return latestPerZone.values.map((row) {
          final zoneId = row['zone_id'] as int;
          final double avg = (row['avg'] as num?)?.toDouble() ?? 0;
          final double peak = (row['peak'] as num?)?.toDouble() ?? 0;
          final double min = (row['min'] as num?)?.toDouble() ?? 0;
          final double rms = (row['rms'] as num?)?.toDouble() ?? 0;
          final double temperatureC = (row['temperature_c'] as num?)?.toDouble() ?? 25.0;

          // Convert RMS to approximate dB
          final double noiseDb = rms > 0 ? 20 * _log10(rms / 1.0) : 0;

          // Run the ANN to classify the sound
          final result = _mlService.classifySound(
            avg: avg,
            peak: peak,
            min: min,
            rms: rms,
          );

          final String soundClass = result['label'] as String;
          final List<Map<String, dynamic>> soundProfile =
              (result['profile'] as List?)?.map((e) {
                    final map = e as Map;
                    return map.cast<String, dynamic>();
                  }).toList() ??
                  const <Map<String, dynamic>>[];
          final NoiseLevel level = _resolveNoiseLevel(noiseDb);
          final alertRaised = level == NoiseLevel.warning || level == NoiseLevel.critical;

          // Push the AI analysis back to Supabase so the ESP32 can react
          _updateBackendStatus(
            zoneId: zoneId,
            noiseLabel: soundClass,
            noiseLevel: level,
            rms: rms,
            temperatureC: temperatureC,
            alertRaised: alertRaised,
          );

          return ZoneSnapshot(
            zoneId: zoneId.toString(),
            zoneName: _getZoneName(zoneId),
            temperatureC: temperatureC,
            noiseDb: noiseDb,
            noiseLevel: level,
            soundClass: soundClass,
            soundProfile: soundProfile,
            alertRaised: alertRaised,
            updatedAt: DateTime.parse(row['created_at'] as String),
          );
        }).toList();
      });
    } catch (e) {
      return const Stream.empty();
    }
  }

  Future<void> _updateBackendStatus({
    required int zoneId,
    required String noiseLabel,
    required NoiseLevel noiseLevel,
    required double rms,
    required double temperatureC,
    required bool alertRaised,
  }) async {
    try {
      final levelStr = noiseLevel.toString().split('.').last;
      
      // ESP32 logic mapping: green = quiet, blue = warning, red = critical
      String ledColor = 'green';
      if (levelStr == 'critical') {
        ledColor = 'red';
      } else if (levelStr == 'warning') {
        ledColor = 'blue';
      }
      
      // Update the zone_status table for ESP32 polling
      await _client.from('zone_status').upsert({
        'zone_id': zoneId,
        'noise_label': noiseLabel,
        'noise_level': levelStr,
        'led_color': ledColor,
        'buzzer_active': alertRaised,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Log critical/warning events for historical charts
      if (alertRaised) {
        await _client.from('noise_events').insert({
          'zone_id': zoneId,
          'noise_label': noiseLabel,
          'noise_level': levelStr,
          'rms': rms,
          'temperature_c': temperatureC,
        });
      }
    } catch (_) {
      // Fail silently if disconnected
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
