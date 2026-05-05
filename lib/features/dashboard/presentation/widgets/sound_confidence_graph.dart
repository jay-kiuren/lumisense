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
        // Legend: colored dots + labels with percentages
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: normalized.map((e) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: e.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${e.label} ${e.percent.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                        fontSize: 11,
                      ),
                ),
              ],
            );
          }).toList(),
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

  /// Distinct colors for the stacked bar segments so each sound type
  /// is immediately distinguishable.
  static const _palette = [
    Color(0xFF0A84FF), // blue
    Color(0xFF30D158), // green
    Color(0xFFFF9F0A), // amber
    Color(0xFFBF5AF2), // purple
    Color(0xFFFF453A), // red
    Color(0xFF64D2FF), // cyan
    Color(0xFFFFD60A), // yellow
  ];

  Color get color {
    final index = label.hashCode.abs() % _palette.length;
    return _palette[index].withValues(alpha: 0.88);
  }
}


