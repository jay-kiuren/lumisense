import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Noise range adjustments
  double _noiseWarningThreshold = 60.0;
  double _noiseCriticalThreshold = 72.0;
  double _tempThreshold = 26.0;

  // Alarm pattern
  int _selectedPattern = 0;
  final _patternNames = ['Continuous', 'Pulsing', 'Escalating', 'Short Burst'];
  double _alarmDuration = 5.0;
  double _alarmCooldown = 30.0;

  bool _hasUnsavedChanges = false;

  void _markDirty() {
    if (!_hasUnsavedChanges) setState(() => _hasUnsavedChanges = true);
  }

  void _saveAll() {
    setState(() => _hasUnsavedChanges = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(LucideIcons.checkCircle, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Settings saved successfully'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(24),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configure noise thresholds, buzzer overrides, and alarm patterns',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (_hasUnsavedChanges)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.alertCircle,
                        size: 13,
                        color: AppColors.warning,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Unsaved changes',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _hasUnsavedChanges ? _saveAll : null,
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: _hasUnsavedChanges
                          ? const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryMuted,
                              ],
                            )
                          : null,
                      color: _hasUnsavedChanges
                          ? null
                          : AppColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.save,
                          size: 16,
                          color: _hasUnsavedChanges
                              ? Colors.white
                              : AppColors.textTertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Save All',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _hasUnsavedChanges
                                ? Colors.white
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── NOISE RANGE ──
                  _SectionHeader(
                    title: 'Noise Range Adjustment',
                    icon: LucideIcons.sliders,
                  ),
                  const SizedBox(height: 16),
                  _buildNoiseRangeSection(),


                  const SizedBox(height: 36),

                  // ── ALARM PATTERN ──
                  _SectionHeader(
                    title: 'Alarm Pattern Calibration',
                    icon: LucideIcons.waves,
                  ),
                  const SizedBox(height: 16),
                  _buildAlarmPatternSection(),

                  const SizedBox(height: 36),

                  // ── CONNECTIONS ──
                  _SectionHeader(title: 'Connections', icon: LucideIcons.plug),
                  const SizedBox(height: 16),
                  _SettingsTile(
                    icon: LucideIcons.database,
                    title: 'Firebase Configuration',
                    subtitle: 'Realtime database connection',
                    trailing: 'Connected',
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 10),
                  _SettingsTile(
                    icon: LucideIcons.radio,
                    title: 'ESP32 Nodes',
                    subtitle: 'Hardware sensor nodes',
                    trailing: '3 online',
                    color: AppColors.success,
                  ),

                  const SizedBox(height: 36),

                  // ── ML ──
                  _SectionHeader(
                    title: 'Machine Learning',
                    icon: LucideIcons.brain,
                  ),
                  const SizedBox(height: 16),
                  _SettingsTile(
                    icon: LucideIcons.cpu,
                    title: 'ML Model Provider',
                    subtitle: 'Edge Impulse sound classification',
                    trailing: 'Active',
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 10),
                  _SettingsTile(
                    icon: LucideIcons.layers,
                    title: 'Supported Sound Classes',
                    subtitle:
                        'ambient, conversation, chair_dragging, loud_talking',
                    trailing: '4 classes',
                    color: AppColors.textSecondary,
                  ),

                  const SizedBox(height: 36),

                  _SectionHeader(
                    title: 'Application',
                    icon: LucideIcons.settings,
                  ),
                  const SizedBox(height: 16),
                  _SettingsTile(
                    icon: LucideIcons.info,
                    title: 'About Lumisense',
                    subtitle: 'Version 1.0.0 · Smart Library Monitor',
                    trailing: '',
                    color: AppColors.textTertiary,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Noise Range Section ──

  Widget _buildNoiseRangeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _SliderRow(
            icon: LucideIcons.volume1,
            label: 'Warning Threshold',
            value: _noiseWarningThreshold,
            min: 40,
            max: 80,
            unit: 'dB',
            color: AppColors.warning,
            onChanged: (v) {
              setState(() => _noiseWarningThreshold = v);
              _markDirty();
            },
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.surfaceHighlight.withOpacity(0.5)),
          const SizedBox(height: 20),
          _SliderRow(
            icon: LucideIcons.volumeX,
            label: 'Critical Threshold',
            value: _noiseCriticalThreshold,
            min: 60,
            max: 100,
            unit: 'dB',
            color: AppColors.error,
            onChanged: (v) {
              setState(() => _noiseCriticalThreshold = v);
              _markDirty();
            },
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.surfaceHighlight.withOpacity(0.5)),
          const SizedBox(height: 20),
          _SliderRow(
            icon: LucideIcons.thermometer,
            label: 'Temperature Threshold',
            value: _tempThreshold,
            min: 20,
            max: 40,
            unit: '°C',
            color: AppColors.warning,
            onChanged: (v) {
              setState(() => _tempThreshold = v);
              _markDirty();
            },
          ),
        ],
      ),
    );
  }

  // ── Alarm Pattern Section ──

  Widget _buildAlarmPatternSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select alarm pattern, duration, and cooldown period between triggers.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Pattern selector
          Text(
            'ALARM PATTERN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_patternNames.length, (i) {
              final isSelected = i == _selectedPattern;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedPattern = i);
                  _markDirty();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _patternNames[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 28),
          Divider(color: AppColors.surfaceHighlight.withOpacity(0.5)),
          const SizedBox(height: 20),

          _SliderRow(
            icon: LucideIcons.timer,
            label: 'Alarm Duration',
            value: _alarmDuration,
            min: 1,
            max: 30,
            unit: 'sec',
            color: AppColors.primary,
            onChanged: (v) {
              setState(() => _alarmDuration = v);
              _markDirty();
            },
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.surfaceHighlight.withOpacity(0.5)),
          const SizedBox(height: 20),
          _SliderRow(
            icon: LucideIcons.clock,
            label: 'Cooldown Period',
            value: _alarmCooldown,
            min: 5,
            max: 120,
            unit: 'sec',
            color: AppColors.textSecondary,
            onChanged: (v) {
              setState(() => _alarmCooldown = v);
              _markDirty();
            },
          ),
        ],
      ),
    );
  }
}

// ── Reusable widgets ──

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

class _SliderRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final Color color;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: AppColors.surfaceHighlight,
              thumbColor: color,
              overlayColor: color.withOpacity(0.15),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: ((max - min) * 2).toInt(),
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 72,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${value.toStringAsFixed(1)} $unit',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
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
          color: _isHovered
              ? AppColors.surfaceHighlight.withOpacity(0.6)
              : AppColors.surface,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
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
            const Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
