import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class BuzzerControl extends StatefulWidget {
  const BuzzerControl({super.key});

  @override
  State<BuzzerControl> createState() => _BuzzerControlState();
}

class _BuzzerControlState extends State<BuzzerControl> {
  bool _globalBuzzer = true;
  bool _itBuzzer = true;
  bool _csBuzzer = true;
  bool _engBuzzer = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.bellRing, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Text(
                'Buzzer Control',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _BuzzerRow(
            label: 'Global Buzzer',
            value: _globalBuzzer,
            icon: LucideIcons.globe,
            onChanged: (v) => setState(() {
              _globalBuzzer = v;
              if (!v) {
                _itBuzzer = false;
                _csBuzzer = false;
                _engBuzzer = false;
              }
            }),
          ),
          const SizedBox(height: 8),
          Divider(color: AppColors.surfaceHighlight.withOpacity(0.5)),
          const SizedBox(height: 8),
          _BuzzerRow(
            label: 'IT Buzzer',
            value: _itBuzzer,
            icon: LucideIcons.monitorSpeaker,
            onChanged: _globalBuzzer
                ? (v) => setState(() => _itBuzzer = v)
                : null,
          ),
          const SizedBox(height: 6),
          _BuzzerRow(
            label: 'CS Buzzer',
            value: _csBuzzer,
            icon: LucideIcons.server,
            onChanged: _globalBuzzer
                ? (v) => setState(() => _csBuzzer = v)
                : null,
          ),
          const SizedBox(height: 6),
          _BuzzerRow(
            label: 'Engineering Buzzer',
            value: _engBuzzer,
            icon: LucideIcons.cpu,
            onChanged: _globalBuzzer
                ? (v) => setState(() => _engBuzzer = v)
                : null,
          ),
        ],
      ),
    );
  }
}

class _BuzzerRow extends StatelessWidget {
  final String label;
  final bool value;
  final IconData icon;
  final ValueChanged<bool>? onChanged;

  const _BuzzerRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onChanged != null;
    final labelColor = isEnabled ? AppColors.textPrimary : AppColors.textTertiary;

    return Row(
      children: [
        Icon(icon, size: 16, color: isEnabled ? AppColors.textSecondary : AppColors.textTertiary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: labelColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(
          height: 28,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.textPrimary,
            activeTrackColor: AppColors.success,
            inactiveThumbColor: AppColors.textTertiary,
            inactiveTrackColor: AppColors.surfaceHighlight,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ),
      ],
    );
  }
}
