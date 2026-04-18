import 'package:flutter/material.dart';

import 'app/theme/app_theme.dart';
import 'features/shared/presentation/main_shell_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartLibraryApp());
}

class SmartLibraryApp extends StatelessWidget {
  const SmartLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LumiSense Monitor',
      theme: AppTheme.dark(),
      home: const MainShellPage(),
    );
  }
}
