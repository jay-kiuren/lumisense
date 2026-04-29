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
                    'Statistics Report',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Immutable audit logs · Only Super Admin can delete entries',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _currentRole == UserRole.superAdmin
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surfaceHighlight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _currentRole == UserRole.superAdmin
                          ? LucideIcons.shieldCheck
                          : LucideIcons.shield,
                      size: 14,
                      color: _currentRole == UserRole.superAdmin
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _currentRole == UserRole.superAdmin
                          ? 'Super Admin'
                          : 'Admin',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _currentRole == UserRole.superAdmin
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildExportButton(),
            ],
          ),

          const SizedBox(height: 28),

          // Quick summary row
          _buildSummaryRow(),

          const SizedBox(height: 24),

          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 36),
                _headerCell('Log ID', flex: 1),
                _headerCell('Timestamp', flex: 2),
                _headerCell('Department', flex: 1),
                _headerCell('Event', flex: 4),
                _headerCell('Severity', flex: 1),
                if (_currentRole == UserRole.superAdmin)
                  const SizedBox(width: 44),
              ],
            ),
          ),

          // Log entries
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _logs.length,
                separatorBuilder: (_, _) => Divider(
                  color: AppColors.surfaceHighlight.withValues(alpha: 0.4),
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
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.download,
                size: 16,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 8),
              Text(
                'Export',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        _SummaryStat(
          icon: LucideIcons.fileText,
          label: 'Total Logs',
          value: '${_logs.length}',
          color: AppColors.primary,
        ),
        const SizedBox(width: 16),
        _SummaryStat(
          icon: LucideIcons.alertTriangle,
          label: 'Critical Events',
          value:
              '${_logs.where((l) => l.severity == _Severity.critical).length}',
          color: AppColors.error,
        ),
        const SizedBox(width: 16),
        _SummaryStat(
          icon: LucideIcons.alertCircle,
          label: 'Warnings',
          value:
              '${_logs.where((l) => l.severity == _Severity.warning).length}',
          color: AppColors.warning,
        ),
        const SizedBox(width: 16),
        _SummaryStat(
          icon: LucideIcons.info,
          label: 'Info',
          value: '${_logs.where((l) => l.severity == _Severity.info).length}',
          color: AppColors.textSecondary,
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
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textTertiary,
          letterSpacing: 0.5,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _hovered
            ? AppColors.surfaceHighlight.withValues(alpha: 0.3)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Severity dot
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 28),
              decoration: BoxDecoration(
                color: _severityColor(widget.log.severity),
                shape: BoxShape.circle,
              ),
            ),
            // ID
            Expanded(
              flex: 1,
              child: Text(
                widget.log.id,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
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
              flex: 1,
              child: Text(
                widget.log.department,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
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
            // Severity badge
            Expanded(
              flex: 1,
              child: _SeverityBadge(severity: widget.log.severity),
            ),
            // Delete (super admin only)
            if (widget.canDelete)
              SizedBox(
                width: 44,
                child: _hovered
                    ? IconButton(
                        onPressed: () => _confirmDelete(context),
                        icon: const Icon(
                          LucideIcons.trash2,
                          size: 16,
                          color: AppColors.error,
                        ),
                        splashRadius: 16,
                        tooltip: 'Delete (Super Admin)',
                      )
                    : const SizedBox(width: 44),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.alertTriangle,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Delete Log Entry',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete ${widget.log.id}? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.surfaceHighlight,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        widget.onDelete();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _severityColor(_Severity s) {
    switch (s) {
      case _Severity.info:
        return AppColors.textTertiary;
      case _Severity.warning:
        return AppColors.warning;
      case _Severity.critical:
        return AppColors.error;
    }
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

class _SeverityBadge extends StatelessWidget {
  final _Severity severity;
  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = severity == _Severity.critical
        ? AppColors.error
        : severity == _Severity.warning
        ? AppColors.warning
        : AppColors.textTertiary;
    final label = severity == _Severity.critical
        ? 'Critical'
        : severity == _Severity.warning
        ? 'Warning'
        : 'Info';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
