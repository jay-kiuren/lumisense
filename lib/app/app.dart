import 'package:flutter/material.dart';

import '../core/domain/repositories/telemetry_repository.dart';
import '../core/services/mock/mock_telemetry_repository.dart';
import '../features/alerts/presentation/alerts_page.dart';
import '../features/analytics/presentation/analytics_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/zones/presentation/zones_page.dart';
import 'theme/app_theme.dart';

enum AppSection { dashboard, zones, alerts, analytics, settings }

class SmartLibraryApp extends StatelessWidget {
  const SmartLibraryApp({super.key, this.telemetryRepository});

  final TelemetryRepository? telemetryRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LumiSense Monitor',
      theme: AppTheme.dark(),
      home: AppShell(
        repository: telemetryRepository ?? MockTelemetryRepository(),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.repository});

  final TelemetryRepository repository;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppSection selected = AppSection.dashboard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: const Color(0xFF101827),
            selectedIconTheme: const IconThemeData(color: Color(0xFF6EE7B7)),
            selectedLabelTextStyle: const TextStyle(color: Color(0xFF6EE7B7)),
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
            labelType: NavigationRailLabelType.all,
            selectedIndex: AppSection.values.indexOf(selected),
            onDestinationSelected: (index) {
              setState(() => selected = AppSection.values[index]);
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.grid_view_outlined),
                label: Text('Zones'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications_active_outlined),
                label: Text('Alerts'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                label: Text('Analytics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _content()),
        ],
      ),
    );
  }

  Widget _content() {
    switch (selected) {
      case AppSection.dashboard:
        return DashboardPage(repository: widget.repository);
      case AppSection.zones:
        return ZonesPage(repository: widget.repository);
      case AppSection.alerts:
        return AlertsPage(repository: widget.repository);
      case AppSection.analytics:
        return AnalyticsPage(repository: widget.repository);
      case AppSection.settings:
        return const SettingsPage();
    }
  }
}
