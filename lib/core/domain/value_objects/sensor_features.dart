import 'dart:convert';

/// Normalized sensor values consumed by the inference pipeline.
class SensorFeatures {
  const SensorFeatures({
    required this.avg,
    required this.peak,
    required this.min,
    required this.rms,
    required this.temperatureC,
  });

  final double avg;
  final double peak;
  final double min;
  final double rms;
  final double temperatureC;

  factory SensorFeatures.fromSupabase(dynamic rawSensorData) {
    final Map<String, dynamic> map = rawSensorData is String
        ? (jsonDecode(rawSensorData) as Map<String, dynamic>)
        : (rawSensorData as Map<String, dynamic>);

    return SensorFeatures(
      avg: _toDouble(map['avg']),
      peak: _toDouble(map['peak']),
      min: _toDouble(map['min'], fallback: 0.0),
      rms: _toDouble(map['rms']),
      temperatureC: _toDouble(map['temperature_c'], fallback: 25.0),
    );
  }

  static double _toDouble(dynamic value, {double fallback = 0.0}) {
    if (value is num) return value.toDouble();
    return fallback;
  }
}
