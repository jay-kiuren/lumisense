import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class SummaryPanel extends StatelessWidget {
  const SummaryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    const highestSoundDb = 72.1;
    final highestSoundColor = highestSoundDb > 70
        ? AppColors.statusCritical
        : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.shadowMedium,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 20),
            _SummaryRow(
              icon: LucideIcons.volume2,
              label: 'Average Sound Level',
              value: '48.3 dB',
              color: AppColors.textPrimary,
            ),
            _SummaryRow(
              icon: LucideIcons.volumeX,
              label: 'Highest Sound Level',
              value: '${highestSoundDb.toStringAsFixed(1)} dB',
              color: highestSoundColor,
            ),
            _SummaryRow(
              icon: LucideIcons.thermometer,
              label: 'Average Temperature',
              value: '24.8°C',
              color: AppColors.textPrimary,
            ),
            _SummaryRow(
              icon: LucideIcons.thermometerSun,
              label: 'Highest Temperature',
              value: '28.9°C',
              color: AppColors.textPrimary,
            ),
            _SummaryRow(
              icon: LucideIcons.waves,
              label: 'Most Common Noise',
              value: 'Conversation',
              color: AppColors.textPrimary,
            ),
            _SummaryRow(
              icon: LucideIcons.alertTriangle,
              label: 'Red Trigger Count',
              value: '3',
              color: AppColors.textPrimary,
            ),
            _SummaryRow(
              icon: LucideIcons.building2,
              label: 'Most Noisy Dept',
              value: 'Engineering',
              color: AppColors.textPrimary,
            ),
            _SummaryRow(
              icon: LucideIcons.database,
              label: 'Total Records',
              value: '1,284',
              color: AppColors.textPrimary,
            ),
            _SummaryRow(
              icon: LucideIcons.clock,
              label: 'Most Noisy Period',
              value: 'PM',
              color: AppColors.textPrimary,
              isLast: true,
            ),
          ],
        ),
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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 17, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 100,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            color: AppColors.separator,
            thickness: 0.5,
            height: 1,
          ),
      ],
    );
  }
}
