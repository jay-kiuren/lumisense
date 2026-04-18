import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumisense_monitor/core/domain/entities/zone_snapshot.dart';
import 'package:lumisense_monitor/core/domain/repositories/telemetry_repository.dart';
import 'package:lumisense_monitor/core/domain/value_objects/noise_level.dart';

import 'package:lumisense_monitor/app/app.dart';

void main() {
  testWidgets('App shell renders dashboard navigation', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      SmartLibraryApp(telemetryRepository: _OneShotTelemetryRepository()),
    );
    await tester.pump();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('LumiSense Monitor'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

class _OneShotTelemetryRepository implements TelemetryRepository {
  @override
  Stream<List<ZoneSnapshot>> watchLiveZones() {
    return Stream.value([
      ZoneSnapshot(
        zoneId: 'it',
        zoneName: 'IT Zone',
        temperatureC: 24.0,
        noiseDb: 40.0,
        noiseLevel: NoiseLevel.quiet,
        soundClass: 'ambient',
        alertRaised: false,
        updatedAt: DateTime(2026, 1, 1),
      ),
      ZoneSnapshot(
        zoneId: 'cs',
        zoneName: 'CS Zone',
        temperatureC: 25.0,
        noiseDb: 42.0,
        noiseLevel: NoiseLevel.normal,
        soundClass: 'conversation',
        alertRaised: false,
        updatedAt: DateTime(2026, 1, 1),
      ),
      ZoneSnapshot(
        zoneId: 'eng',
        zoneName: 'Engineering Zone',
        temperatureC: 26.0,
        noiseDb: 50.0,
        noiseLevel: NoiseLevel.warning,
        soundClass: 'chair_dragging',
        alertRaised: true,
        updatedAt: DateTime(2026, 1, 1),
      ),
    ]);
  }
}
