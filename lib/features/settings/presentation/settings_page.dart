import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Configure thresholds, connections, and ML model parameters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(title: 'Thresholds', icon: LucideIcons.sliders),
                  const SizedBox(height: 16),
                  _SettingsTile(
                    icon: LucideIcons.thermometer,
                    title: 'Temperature Threshold',
                    subtitle: 'Maximum acceptable temperature before alert',
                    trailing: '26.0°C',
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: 10),
                  _SettingsTile(
                    icon: LucideIcons.volume1,
                    title: 'Noise Warning Threshold',
                    subtitle: 'Sound level that triggers a warning state',
                    trailing: '60 dB',
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: 10),
                  _SettingsTile(
                    icon: LucideIcons.volumeX,
                    title: 'Noise Critical Threshold',
                    subtitle: 'Sound level that triggers a critical alert',
                    trailing: '72 dB',
                    color: AppColors.error,
                  ),

                  const SizedBox(height: 32),
                  _SectionHeader(title: 'Connections', icon: LucideIcons.plug),
                  const SizedBox(height: 16),
                  _SettingsTile(
                    icon: LucideIcons.database,
                    title: 'Firebase Configuration',
                    subtitle: 'Realtime database connection credentials',
                    trailing: 'Connected',
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 10),
                  _SettingsTile(
                    icon: LucideIcons.radio,
                    title: 'ESP32 Nodes',
                    subtitle: 'Hardware sensor node configuration',
                    trailing: '3 online',
                    color: AppColors.success,
                  ),

                  const SizedBox(height: 32),
                  _SectionHeader(title: 'Machine Learning', icon: LucideIcons.brain),
                  const SizedBox(height: 16),
                  _SettingsTile(
                    icon: LucideIcons.cpu,
                    title: 'ML Model Provider',
                    subtitle: 'Edge Impulse sound classification model',
                    trailing: 'Active',
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 10),
                  _SettingsTile(
                    icon: LucideIcons.layers,
                    title: 'Supported Sound Classes',
                    subtitle: 'ambient, conversation, chair_dragging, loud_talking',
                    trailing: '4 classes',
                    color: AppColors.textSecondary,
                  ),

                  const SizedBox(height: 32),
                  _SectionHeader(title: 'Application', icon: LucideIcons.settings),
                  const SizedBox(height: 16),
                  _SettingsTile(
                    icon: LucideIcons.info,
                    title: 'About Lumisense',
                    subtitle: 'Version 1.0.0 · Smart Library Monitor',
                    trailing: '',
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textTertiary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final Color color;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.color,
  });

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _isHovered ? AppColors.surfaceHighlight.withOpacity(0.6) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.icon, size: 20, color: widget.color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.trailing.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.trailing,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.color,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
