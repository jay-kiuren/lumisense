import '../entities/zone_snapshot.dart';

abstract class TelemetryRepository {
  Stream<List<ZoneSnapshot>> watchLiveZones();
}
