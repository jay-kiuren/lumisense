import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class NoiseFrequencyChart extends StatelessWidget {
  const NoiseFrequencyChart({super.key});

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
              const Icon(LucideIcons.pieChart, size: 16, color: AppColors.textTertiary),
              const SizedBox(width: 8),
              Text(
                'Noise Type Frequency',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 28,
                sections: [
                  PieChartSectionData(
                    value: 40,
                    color: AppColors.success,
                    radius: 32,
                    title: '',
                  ),
                  PieChartSectionData(
                    value: 25,
                    color: AppColors.primary,
                    radius: 32,
                    title: '',
                  ),
                  PieChartSectionData(
                    value: 20,
                    color: AppColors.warning,
                    radius: 32,
                    title: '',
                  ),
                  PieChartSectionData(
                    value: 15,
                    color: AppColors.error,
                    radius: 32,
                    title: '',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _LegendItem(color: AppColors.success, label: 'Ambient', percent: '40%'),
          const SizedBox(height: 6),
          _LegendItem(color: AppColors.primary, label: 'Conversation', percent: '25%'),
          const SizedBox(height: 6),
          _LegendItem(color: AppColors.warning, label: 'Chair Drag', percent: '20%'),
          const SizedBox(height: 6),
          _LegendItem(color: AppColors.error, label: 'Loud Talk', percent: '15%'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String percent;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          percent,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
