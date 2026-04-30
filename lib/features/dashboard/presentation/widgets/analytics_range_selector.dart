import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AnalyticsRangeSelector extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  const AnalyticsRangeSelector({super.key, this.onChanged});

  @override
  State<AnalyticsRangeSelector> createState() => _AnalyticsRangeSelectorState();
}

class _AnalyticsRangeSelectorState extends State<AnalyticsRangeSelector> {
  int _selectedIndex = 0;
  final _labels = ['1 Hour', '3 Hours', '1 Day'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.workspaceBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_labels.length, (i) {
          final isSelected = i == _selectedIndex;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = i);
              widget.onChanged?.call(_labels[i]);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.textPrimary : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                _labels[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.appBackground : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
