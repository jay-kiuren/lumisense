import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SoundConfidenceGraph extends StatelessWidget {
  const SoundConfidenceGraph({
    super.key,
    required this.soundProfile,
    this.topN = 3,
  });

  final List<Map<String, dynamic>> soundProfile;
  final int topN;

  @override
  Widget build(BuildContext context) {
    final normalized = _normalizedTopN(soundProfile, topN: topN);
    
    if (normalized.isEmpty) {
      return const Center(
        child: Text(
          '—',
          style: TextStyle(color: AppColors.textTertiary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          normalized
              .map((e) => '${e.label} ${e.percent.toStringAsFixed(0)}%')
              .join('  •  '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceHighlight.withValues(alpha: 0.3),
            ),
            child: Row(
              children: normalized.map((item) {
                return Expanded(
                  flex: (item.percent * 100).toInt(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: item.color,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<_SoundItem> _normalizedTopN(
    List<Map<String, dynamic>> profile, {
    required int topN,
  }) {
    final items = <_SoundItem>[];
    for (final entry in profile) {
      final label = entry['label']?.toString().trim();
      if (label == null || label.isEmpty) continue;

      final rawConf = entry['confidence'];
      if (rawConf == null) continue;
      final conf = rawConf is num ? rawConf.toDouble() : double.tryParse(rawConf.toString()) ?? 0.0;

      final percent = conf <= 1.0 ? conf * 100.0 : conf;
      if (percent > 1.0) { // Only show sounds > 1% confidence
        items.add(_SoundItem(label: _prettyLabel(label), percent: percent));
      }
    }

    items.sort((a, b) => b.percent.compareTo(a.percent));
    return items.take(topN).toList();
  }

  String _prettyLabel(String label) {
    final v = label.replaceAll('_', ' ').trim();
    return v.isEmpty ? label : v;
  }
}

class _SoundItem {
  _SoundItem({required this.label, required this.percent});

  final String label;
  final double percent;

  Color get color {
    final h = label.hashCode.abs() % 3;
    switch (h) {
      case 0:
        return AppColors.textPrimary.withValues(alpha: 0.92);
      case 1:
        return AppColors.textSecondary.withValues(alpha: 0.92);
      default:
        return AppColors.textTertiary.withValues(alpha: 0.92);
    }
  }
}

