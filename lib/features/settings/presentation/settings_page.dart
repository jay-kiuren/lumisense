import 'package:flutter/material.dart';

import '../../shared/presentation/page_frame.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageFrame(
      title: 'Settings',
      subtitle:
          'Configure thresholds, Firebase credentials, and ML model IDs here.',
      child: _SettingsBody(),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Card(
          child: ListTile(
            title: Text('Temperature Threshold'),
            subtitle: Text('Default: 26 C max'),
          ),
        ),
        SizedBox(height: 12),
        Card(
          child: ListTile(
            title: Text('Noise Threshold'),
            subtitle: Text('Default: 60 dB warning, 72 dB critical'),
          ),
        ),
        SizedBox(height: 12),
        Card(
          child: ListTile(
            title: Text('ML Provider'),
            subtitle: Text('Edge Impulse placeholder'),
          ),
        ),
      ],
    );
  }
}
