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
    this.isInactive = false,
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

  /// True when the last data received is older than 10 minutes.
  /// Set by SupabaseTelemetryRepository after the staleness check.
  final bool isInactive;

  /// Convenience: how long since the last reading
  Duration get staleDuration => DateTime.now().difference(updatedAt);

  ZoneSnapshot copyWith({
    String? zoneId,
    String? zoneName,
    double? temperatureC,
    double? noiseDb,
    NoiseLevel? noiseLevel,
    String? soundClass,
    List<Map<String, dynamic>>? soundProfile,
    bool? alertRaised,
    DateTime? updatedAt,
    bool? isInactive,
  }) {
    return ZoneSnapshot(
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      temperatureC: temperatureC ?? this.temperatureC,
      noiseDb: noiseDb ?? this.noiseDb,
      noiseLevel: noiseLevel ?? this.noiseLevel,
      soundClass: soundClass ?? this.soundClass,
      soundProfile: soundProfile ?? this.soundProfile,
      alertRaised: alertRaised ?? this.alertRaised,
      updatedAt: updatedAt ?? this.updatedAt,
      isInactive: isInactive ?? this.isInactive,
    );
  }
}