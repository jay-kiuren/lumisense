import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

enum UserRole { admin, superAdmin }

class StatisticsReportPage extends StatefulWidget {
  const StatisticsReportPage({super.key});

  @override
  State<StatisticsReportPage> createState() => _StatisticsReportPageState();
}

class _StatisticsReportPageState extends State<StatisticsReportPage> {
  // Mock: set to superAdmin to test delete visibility
  final UserRole _currentRole = UserRole.superAdmin;

  final List<_LogEntry> _logs = List.generate(
    20,
    (i) => _LogEntry(
      id: 'LOG-${1000 + i}',
      timestamp: DateTime.now().subtract(
        Duration(minutes: i * 37, seconds: i * 13),
      ),
      department: ['IT', 'CS', 'Engineering'][i % 3],
      event: [
        'Noise level exceeded 72 dB (Critical)',
        'Temperature spike: 29.1°C',
        'Buzzer triggered — loud_talking detected',
        'Sensor reconnected after 3s dropout',
        'Sound classification: chair_dragging',
        'Environmental summary exported',
      ][i % 6],
      severity: [
        _Severity.critical,
        _Severity.warning,
        _Severity.critical,
        _Severity.info,
        _Severity.warning,
        _Severity.info,
      ][i % 6],
    ),
  );

  @override
  Widget build(BuildContext context) {
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
                    'Logs',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'System events and audit trail',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ),
              const Spacer(),
              // Role indicator (minimal)
              if (_currentRole == UserRole.superAdmin)
                const Row(
                  children: [
                    Icon(LucideIcons.shieldCheck, size: 14, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text(
                      'Super Admin',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              const SizedBox(width: 24),
              _buildExportButton(),
            ],
          ),

          const SizedBox(height: 36),

          // Quick summary row inside elevated containers
          _buildSummaryRow(),

          const SizedBox(height: 32),

          // Log entries inside an elevated card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.shadowLow,
              ),
              child: Column(
                children: [
                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.separator, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        _headerCell('Log ID', flex: 1),
                        _headerCell('Timestamp', flex: 2),
                        _headerCell('Department', flex: 2),
                        _headerCell('Event', flex: 4),
                        _headerCell('Level', flex: 1),
                        if (_currentRole == UserRole.superAdmin)
                          const SizedBox(width: 32), // spacer for delete button
                      ],
                    ),
                  ),
                  
                  // Table body
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: _logs.length,
                      separatorBuilder: (_, _) => const Divider(
                        color: AppColors.borderSubtle,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        return _LogRow(
                          log: log,
                          canDelete: _currentRole == UserRole.superAdmin,
                          onDelete: () {
                            setState(() => _logs.removeAt(index));
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          boxShadow: AppColors.shadowLow,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.download, size: 14, color: AppColors.textPrimary),
            SizedBox(width: 8),
            Text(
              'Export CSV',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        _SummaryStat(
          label: 'TOTAL EVENTS',
          value: '${_logs.length}',
        ),
        const SizedBox(width: 16),
        _SummaryStat(
          label: 'CRITICAL',
          value: '${_logs.where((l) => l.severity == _Severity.critical).length}',
          valueColor: AppColors.error,
        ),
        const SizedBox(width: 16),
        _SummaryStat(
          label: 'WARNINGS',
          value: '${_logs.where((l) => l.severity == _Severity.warning).length}',
        ),
      ],
    );
  }

  Widget _headerCell(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// --- Data models ---

enum _Severity { info, warning, critical }

class _LogEntry {
  final String id;
  final DateTime timestamp;
  final String department;
  final String event;
  final _Severity severity;

  _LogEntry({
    required this.id,
    required this.timestamp,
    required this.department,
    required this.event,
    required this.severity,
  });
}

// --- Widgets ---

class _LogRow extends StatefulWidget {
  final _LogEntry log;
  final bool canDelete;
  final VoidCallback onDelete;

  const _LogRow({
    required this.log,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  State<_LogRow> createState() => _LogRowState();
}

class _LogRowState extends State<_LogRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        color: _hovered ? AppColors.surfaceElevated : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            // ID
            Expanded(
              flex: 1,
              child: Text(
                widget.log.id,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            // Timestamp
            Expanded(
              flex: 2,
              child: Text(
                _formatTime(widget.log.timestamp),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            // Department
            Expanded(
              flex: 2,
              child: Text(
                widget.log.department,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            // Event
            Expanded(
              flex: 4,
              child: Text(
                widget.log.event,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Severity minimal text
            Expanded(
              flex: 1,
              child: _SeverityLabel(severity: widget.log.severity),
            ),
            // Delete (super admin only)
            if (widget.canDelete)
              SizedBox(
                width: 32,
                child: _hovered
                    ? IconButton(
                        onPressed: () => _confirmDelete(context),
                        icon: const Icon(LucideIcons.x, size: 16, color: AppColors.textTertiary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 16,
                      )
                    : const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    // Keep dialog minimal too
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Log', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: const Text('Remove this entry permanently?', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onDelete();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final sec = dt.second.toString().padLeft(2, '0');
    return '${dt.year}-$month-$day $hour:$min:$sec';
  }
}

class _SeverityLabel extends StatelessWidget {
  final _Severity severity;
  const _SeverityLabel({required this.severity});

  @override
  Widget build(BuildContext context) {
    // Completely flat, no background box, just text.
    final color = severity == _Severity.critical
        ? AppColors.error
        : severity == _Severity.warning
        ? AppColors.textSecondary
        : AppColors.textTertiary;
        
    final label = severity == _Severity.critical
        ? 'CRITICAL'
        : severity == _Severity.warning
        ? 'WARNING'
        : 'INFO';

    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: color,
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryStat({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.shadowLow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: valueColor ?? AppColors.textPrimary,
                letterSpacing: -1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
