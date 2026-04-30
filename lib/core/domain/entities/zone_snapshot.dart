import '../value_objects/noise_level.dart';

class ZoneSnapshot {
  const ZoneSnapshot({
    required this.zoneId,
    required this.zoneName,
    required this.temperatureC,
    required this.noiseDb,
    required this.noiseLevel,
    required this.soundClass,
    this.soundProfile = const [],
    required this.alertRaised,
    required this.updatedAt,
  });

  final String zoneId;
  final String zoneName;
  final double temperatureC;
  final double noiseDb;
  final NoiseLevel noiseLevel;
  final String soundClass;
  final List<Map<String, dynamic>> soundProfile;
  final bool alertRaised;
  final DateTime updatedAt;
}
