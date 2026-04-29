import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class SummaryPanel extends StatelessWidget {
  const SummaryPanel({super.key});

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
          Text(
            'Summary',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          _SummaryRow(
            icon: LucideIcons.volume2,
            label: 'Average Sound Level',
            value: '48.3 dB',
            color: AppColors.primary,
          ),
          _SummaryRow(
            icon: LucideIcons.volumeX,
            label: 'Highest Sound Level',
            value: '72.1 dB',
            color: AppColors.error,
          ),
          _SummaryRow(
            icon: LucideIcons.thermometer,
            label: 'Average Temperature',
            value: '24.8°C',
            color: AppColors.success,
          ),
          _SummaryRow(
            icon: LucideIcons.thermometerSun,
            label: 'Highest Temperature',
            value: '28.9°C',
            color: AppColors.warning,
          ),
          _SummaryRow(
            icon: LucideIcons.waves,
            label: 'Most Common Noise',
            value: 'Conversation',
            color: AppColors.textSecondary,
          ),
          _SummaryRow(
            icon: LucideIcons.alertTriangle,
            label: 'Red Trigger Count',
            value: '3',
            color: AppColors.error,
          ),
          _SummaryRow(
            icon: LucideIcons.building2,
            label: 'Most Noisy Dept',
            value: 'Engineering',
            color: AppColors.warning,
          ),
          _SummaryRow(
            icon: LucideIcons.database,
            label: 'Total Records',
            value: '1,284',
            color: AppColors.textSecondary,
          ),
          _SummaryRow(
            icon: LucideIcons.clock,
            label: 'Most Noisy Period',
            value: 'PM',
            color: AppColors.primary,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isLast;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: AppColors.surfaceHighlight.withValues(alpha: 0.5),
            height: 1,
          ),
      ],
    );
  }
}
