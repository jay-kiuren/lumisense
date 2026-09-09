import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/theme/app_theme.dart';
import 'core/config/app_env.dart';
import 'core/services/settings_service.dart';
import 'features/splash/presentation/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (temporarily catching errors if keys are placeholder)
  try {
    await Supabase.initialize(
      url: AppEnv.supabaseUrl,
      anonKey: AppEnv.supabaseAnonKey,
    );

    // Load settings from Supabase so thresholds are available app-wide
    // before the first sensor reading arrives.
    await SettingsService.instance.load();

    // Run the daily retention cleanup if it's due (summarizes yesterday's
    // sensor_readings into daily_logs, then deletes raw readings older
    // than 24h). This is what keeps sensor_readings from growing
    // unbounded and eating into the Supabase storage quota. Defined in
    // lumisense_retention_rpc.sql — cheap no-op check on days it's
    // already run, so safe to call on every launch.
    await _runRetentionCleanupIfDue();
  } catch (e) {
    debugPrint('Supabase not fully configured yet: $e');
  }

  runApp(const SmartLibraryApp());
}

Future<void> _runRetentionCleanupIfDue() async {
  try {
    final needed = await Supabase.instance.client.rpc('check_cleanup_needed');
    if (needed == true) {
      final result = await Supabase.instance.client.rpc('run_daily_cleanup');
      debugPrint('✓ Retention cleanup ran: $result');
    } else {
      debugPrint('· Retention cleanup not due yet today.');
    }
  } catch (e) {
    // Never let a cleanup failure block app startup.
    debugPrint('⚠ Retention cleanup check failed: $e');
  }
}

class SmartLibraryApp extends StatelessWidget {
  const SmartLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sagana SmartSense',
      theme: AppTheme.dark(),
      home: const SplashPage(),
    );
  }
}