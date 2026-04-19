import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../dashboard/presentation/widgets/analytics_range_selector.dart';
import '../../dashboard/presentation/widgets/summary_panel.dart';

class DepartmentPage extends StatefulWidget {
  const DepartmentPage({super.key});

  @override
  State<DepartmentPage> createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  int _selectedTab = 0;

  static const _departments = [
    _DeptInfo('IT Department', 'it', LucideIcons.monitorSpeaker),
    _DeptInfo('CS Department', 'cs', LucideIcons.server),
    _DeptInfo('Engineering Department', 'eng', LucideIcons.cpu),
  ];

  @override
  Widget build(BuildContext context) {
    final dept = _departments[_selectedTab];

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Department',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time monitoring · 7:00 AM – 5:00 PM',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ),
              const Spacer(),
              const AnalyticsRangeSelector(),
            ],
          ),

          const SizedBox(height: 24),

          // Tab selector
          _buildTabBar(),

          const SizedBox(height: 24),

          // Content
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Charts
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildRealtimeChart(context, dept),
                      ),
                      const SizedBox(height: 16),
                      _buildCurrentDataRow(context),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right: Summary
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SummaryPanel(),
                        const SizedBox(height: 16),
                        _buildEnvSummaryButton(context, dept),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_departments.length, (i) {
          final dept = _departments[i];
          final isSelected = i == _selectedTab;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    dept.icon,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dept.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRealtimeChart(BuildContext context, _DeptInfo dept) {
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
              Icon(dept.icon, size: 18, color: AppColors.textTertiary),
              const SizedBox(width: 10),
              Text(
                '${dept.name} — Real-time Sound Level',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.radio, size: 12, color: AppColors.success),
                    SizedBox(width: 6),
                    Text(
                      'Live',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.surfaceHighlight.withOpacity(0.5),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        final hour = 7 + value.toInt();
                        if (hour > 17) return const SizedBox();
                        final label = hour > 12 ? '${hour - 12}PM' : '${hour}AM';
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()} dB',
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 10,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: _mockSpots(_selectedTab),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.15),
                          AppColors.primary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.surfaceHighlight,
                    getTooltipItems: (spots) => spots.map((s) {
                      return LineTooltipItem(
                        '${s.y.toStringAsFixed(1)} dB',
                        const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _mockSpots(int index) {
    const data = [
      [42.0, 38.0, 55.0, 61.0, 48.0, 72.0, 65.0, 45.0, 50.0, 38.0, 44.0],
      [35.0, 44.0, 50.0, 55.0, 42.0, 60.0, 58.0, 40.0, 47.0, 36.0, 39.0],
      [55.0, 62.0, 70.0, 75.0, 68.0, 80.0, 72.0, 60.0, 65.0, 58.0, 63.0],
    ];
    return List.generate(data[index].length, (i) => FlSpot(i.toDouble(), data[index][i]));
  }

  Widget _buildCurrentDataRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _CurrentDataItem(icon: LucideIcons.activity, label: 'Status', value: 'Quiet', color: AppColors.success),
          _divider(),
          _CurrentDataItem(icon: LucideIcons.waves, label: 'Type', value: 'Ambient', color: AppColors.textPrimary),
          _divider(),
          _CurrentDataItem(icon: LucideIcons.volume2, label: 'Sound', value: '42.5 dB', color: AppColors.primary),
          _divider(),
          _CurrentDataItem(icon: LucideIcons.thermometer, label: 'Temp', value: '24.8°C', color: AppColors.success),
          _divider(),
          _CurrentDataItem(icon: LucideIcons.sunrise, label: 'AM Count', value: '124', color: AppColors.textSecondary),
          _divider(),
          _CurrentDataItem(icon: LucideIcons.sunset, label: 'PM Count', value: '98', color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, margin: const EdgeInsets.symmetric(horizontal: 16), color: AppColors.surfaceHighlight);
  }

  Widget _buildEnvSummaryButton(BuildContext context, _DeptInfo dept) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showEnvironmentalSummary(context, dept.name),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryMuted]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.fileText, size: 16, color: Colors.white),
              SizedBox(width: 10),
              Text('View Environmental Summary', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  void _showEnvironmentalSummary(BuildContext context, String deptName) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => _EnvironmentalSummaryDialog(departmentName: deptName),
    );
  }
}

class _DeptInfo {
  final String name;
  final String id;
  final IconData icon;
  const _DeptInfo(this.name, this.id, this.icon);
}

class _CurrentDataItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _CurrentDataItem({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: AppColors.textTertiary),
              const SizedBox(width: 5),
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _EnvironmentalSummaryDialog extends StatelessWidget {
  final String departmentName;
  const _EnvironmentalSummaryDialog({required this.departmentName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryMuted]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Environmental Summary Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Department: $departmentName  ·  Selected time range: 1 Hour', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(children: [Expanded(child: _DataCell(label: 'Dominant room condition', value: 'Quiet')), const SizedBox(width: 12), Expanded(child: _DataCell(label: 'Most frequent disturbance', value: 'Conversation'))]),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: _DataCell(label: 'Peak temperature', value: '26.4°C')), const SizedBox(width: 12), Expanded(child: _DataCell(label: 'Noisy alerts recorded', value: '3'))]),
            const SizedBox(height: 24),
            Text('Explanation', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('During the selected time range (1 Hour), the monitored environment was mostly in a Quiet condition. The most frequent disturbance was Conversation, with a peak temperature of 26.4°C and 3 noisy alerts recorded.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
            const SizedBox(height: 20),
            Text('Remarks / Observation', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Conditions were generally manageable, but recurring incidents suggest targeted reminders could further improve room discipline.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
            const SizedBox(height: 28),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(backgroundColor: AppColors.surfaceHighlight, foregroundColor: AppColors.textPrimary, padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String label;
  final String value;
  const _DataCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
