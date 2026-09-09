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
  } catch (e) {
    debugPrint('Supabase not fully configured yet: $e');
  }

  runApp(const SmartLibraryApp());
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