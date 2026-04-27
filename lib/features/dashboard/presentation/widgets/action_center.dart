import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class ActionCenter extends StatefulWidget {
  const ActionCenter({super.key});

  @override
  State<ActionCenter> createState() => _ActionCenterState();
}

class _ActionCenterState extends State<ActionCenter> {
  // Buzzer states (Armed = false, Muted/Overridden = true)
  bool _globalBuzzerOverride = false;
  bool _itBuzzerOverride = false;
  bool _csBuzzerOverride = false;
  bool _engBuzzerOverride = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceHighlight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.shieldAlert, size: 18, color: AppColors.warning),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alarm System Status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Manage automated buzzer triggers',
                    style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildOverrideSwitch(
            icon: LucideIcons.globe,
            label: 'Global Alarm',
            value: _globalBuzzerOverride,
            onChanged: (v) {
              setState(() {
                _globalBuzzerOverride = v;
                if (v) {
                  _itBuzzerOverride = true;
                  _csBuzzerOverride = true;
                  _engBuzzerOverride = true;
                }
              });
            },
            isGlobal: true,
          ),
          Divider(color: AppColors.surfaceHighlight.withOpacity(0.5), height: 24),
          _buildOverrideSwitch(
            icon: LucideIcons.monitorSpeaker,
            label: 'IT Zone',
            value: _itBuzzerOverride,
            onChanged: (v) => setState(() => _itBuzzerOverride = v),
          ),
          const SizedBox(height: 12),
          _buildOverrideSwitch(
            icon: LucideIcons.server,
            label: 'CS Zone',
            value: _csBuzzerOverride,
            onChanged: (v) => setState(() => _csBuzzerOverride = v),
          ),
          const SizedBox(height: 12),
          _buildOverrideSwitch(
            icon: LucideIcons.cpu,
            label: 'Eng Zone',
            value: _engBuzzerOverride,
            onChanged: (v) => setState(() => _engBuzzerOverride = v),
          ),
        ],
      ),
    );
  }

  Widget _buildOverrideSwitch({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isGlobal = false,
  }) {
    // If value == true, it means Muted (overridden). Default is false (Armed).
    final isMuted = value;

    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isGlobal ? 14 : 13,
              fontWeight: isGlobal ? FontWeight.w600 : FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (isMuted ? AppColors.warning : AppColors.success).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isMuted ? AppColors.warning : AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isMuted ? 'Muted' : 'Armed',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isMuted ? AppColors.warning : AppColors.success,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 24,
          child: Switch(
            value: isMuted,
            onChanged: onChanged,
            activeColor: AppColors.textPrimary,
            activeTrackColor: AppColors.warning,
            inactiveThumbColor: AppColors.textSecondary,
            inactiveTrackColor: AppColors.surfaceHighlight,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ),
      ],
    );
  }
}
