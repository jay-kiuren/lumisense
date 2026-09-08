import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? delta;
  final Color accentColor;
  final bool isDeltaPositive;

  const QuickStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.delta,
    required this.accentColor,
    this.isDeltaPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowHeavy.withValues(alpha: 0.34),
            blurRadius: 24,
            spreadRadius: -10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 18, color: AppColors.textPrimary),
              ),
              const Spacer(),
              if (delta != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHighlight.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDeltaPositive
                            ? LucideIcons.trendingUp
                            : LucideIcons.trendingDown,
                        size: 12,
                        color: isDeltaPositive ? AppColors.textSecondary : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        delta!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDeltaPositive ? AppColors.textSecondary : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -1,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class QuickStatsRow extends StatelessWidget {
  const QuickStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(
              child: QuickStatCard(
                icon: LucideIcons.activity,
                label: 'Avg Sound Level',
                value: '48.3',
                delta: '2.1 dB',
                accentColor: AppColors.textPrimary,
                isDeltaPositive: false,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: QuickStatCard(
                icon: LucideIcons.thermometer,
                label: 'Avg Temperature',
                value: '24.8°',
                delta: '0.5°',
                accentColor: AppColors.textPrimary,
                isDeltaPositive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(
              child: QuickStatCard(
                icon: LucideIcons.alertTriangle,
                label: 'Active Alerts',
                value: '3',
                delta: '1',
                accentColor: AppColors.textPrimary,
                isDeltaPositive: true,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: QuickStatCard(
                icon: LucideIcons.radio,
                label: 'Online Sensors',
                value: '3/3',
                accentColor: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
