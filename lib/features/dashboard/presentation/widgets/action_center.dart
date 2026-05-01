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
  bool _itBuzzerOverride = false;
  bool _csBuzzerOverride = false;
  bool _engBuzzerOverride = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.shadowLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.shieldAlert,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alarm System Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Manage automated buzzer triggers',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(
            color: AppColors.separator,
            height: 24,
            thickness: 0.5,
          ),
          _buildOverrideSwitch(
            icon: LucideIcons.monitorSpeaker,
            label: 'IT Zone',
            value: _itBuzzerOverride,
            onChanged: (v) => setState(() => _itBuzzerOverride = v),
          ),
          const SizedBox(height: 14),
          _buildOverrideSwitch(
            icon: LucideIcons.server,
            label: 'CS Zone',
            value: _csBuzzerOverride,
            onChanged: (v) => setState(() => _csBuzzerOverride = v),
          ),
          const SizedBox(height: 14),
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
  }) {
    // If value == true, it means Muted (overridden). Default is false (Armed).
    final isMuted = value;

    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          width: 78,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isMuted ? AppColors.error : AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isMuted ? 'Muted' : 'Armed',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isMuted ? AppColors.error : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 88,
          child: Align(
            alignment: Alignment.centerRight,
            child: Switch(
              value: isMuted,
              onChanged: onChanged,
              activeThumbColor: AppColors.textPrimary,
              activeTrackColor: AppColors.textTertiary,
              inactiveThumbColor: AppColors.textSecondary,
              inactiveTrackColor: AppColors.statusLive,
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }
}
