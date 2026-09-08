import 'dart:async';
import 'dart:math' show log;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/export/csv_export.dart';
import '../../../core/theme/app_colors.dart';

String _formatLogTimestamp(DateTime dt) {
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final h = dt.hour.toString().padLeft(2, '0');
  final min = dt.minute.toString().padLeft(2, '0');
  final sec = dt.second.toString().padLeft(2, '0');
  return '${dt.year}-$m-$d $h:$min:$sec';
}

enum UserRole { admin, superAdmin }

enum _LogDateRange { today, last7Days, last30Days }

class StatisticsReportPage extends StatefulWidget {
  const StatisticsReportPage({super.key});

  @override
  State<StatisticsReportPage> createState() => _StatisticsReportPageState();
}

class _StatisticsReportPageState extends State<StatisticsReportPage> {
  final UserRole _currentRole = UserRole.superAdmin;
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();

  Timer? _pollTimer;
  List<_LogEntry> _allLogs = [];
  bool _loading = true;
  String? _error;
  bool _usingMockFallback = false;

  String? _deptFilter;
  _Severity? _severityFilter;
  _LogDateRange _dateRange = _LogDateRange.today;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _fetchLogs();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchLogs());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<_LogEntry> get _filteredLogs {
    final q = _searchController.text.trim().toLowerCase();
    final start = _filterRangeStart;
    final end = DateTime.now();

    return _allLogs.where((e) {
      if (_deptFilter != null && e.departmentShort != _deptFilter) {
        return false;
      }
      if (_severityFilter != null && e.severity != _severityFilter) {
        return false;
      }
      if (e.timestamp.isBefore(start) || e.timestamp.isAfter(end)) {
        return false;
      }
      if (q.isNotEmpty && !e.event.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  DateTime get _filterRangeStart {
    final now = DateTime.now();
    switch (_dateRange) {
      case _LogDateRange.today:
        return DateTime(now.year, now.month, now.day);
      case _LogDateRange.last7Days:
        return now.subtract(const Duration(days: 7));
      case _LogDateRange.last30Days:
        return now.subtract(const Duration(days: 30));
    }
  }

  /// Fetch window wide enough for all filter options (30 days).
  DateTime get _fetchRangeStart {
    final now = DateTime.now();
    return now.subtract(const Duration(days: 30));
  }

  Future<void> _fetchLogs() async {
    try {
      final rows = await _supabase
          .from('noise_events')
          .select(
            'id, zone_id, noise_label, noise_level, rms, temperature_c, created_at, severity, event_description',
          )
          .gte('created_at', _fetchRangeStart.toIso8601String())
          .lte('created_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false)
          .limit(5000);

      final list = <_LogEntry>[];
      for (final row in rows) {
        final id = row['id'];
        final zoneId = (row['zone_id'] as num?)?.toInt() ?? 0;
        final createdAt = DateTime.parse(row['created_at'] as String).toLocal();
        final label = (row['noise_label'] as String?) ?? 'event';
        final noiseLevelRaw = (row['noise_level'] as String?) ?? 'normal';
        final rms = (row['rms'] as num?)?.toDouble();
        final temp = (row['temperature_c'] as num?)?.toDouble();
        final desc = row['event_description'] as String?;
        final sevRaw = row['severity'] as String?;

        final severity = _severityFromRow(noiseLevelRaw, sevRaw);
        final deptShort = _zoneToDeptShort(zoneId);
        final event = desc ?? _buildEventLine(label, noiseLevelRaw, rms, temp);

        list.add(
          _LogEntry(
            dbId: id is int ? id : int.tryParse('$id'),
            id: 'LOG-$id',
            timestamp: createdAt,
            departmentShort: deptShort,
            event: event,
            severity: severity,
          ),
        );
      }

      if (list.isEmpty) {
        if (mounted) {
          setState(() {
            _allLogs = _generateMockLogs();
            _usingMockFallback = true;
            _loading = false;
            _error = null;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _allLogs = list;
          _usingMockFallback = false;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
          if (_allLogs.isEmpty) {
            _allLogs = _generateMockLogs();
            _usingMockFallback = true;
          }
        });
      }
    }
  }

  static List<_LogEntry> _generateMockLogs() {
    return List.generate(
      20,
      (i) => _LogEntry(
        dbId: null,
        id: 'LOG-${1000 + i}',
        timestamp: DateTime.now().subtract(
          Duration(minutes: i * 37, seconds: i * 13),
        ),
        departmentShort: ['IT', 'CS', 'Engineering'][i % 3],
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
  }

  static String _zoneToDeptShort(int zoneId) {
    switch (zoneId) {
      case 1:
        return 'IT';
      case 2:
        return 'CS';
      case 3:
        return 'Engineering';
      default:
        return 'Zone $zoneId';
    }
  }

  static _Severity _severityFromRow(String noiseLevel, String? severityCol) {
    final s = severityCol?.toLowerCase();
    if (s == 'critical') {
      return _Severity.critical;
    }
    if (s == 'warning') {
      return _Severity.warning;
    }
    final n = noiseLevel.toLowerCase();
    if (n == 'critical') {
      return _Severity.critical;
    }
    if (n == 'warning') {
      return _Severity.warning;
    }
    return _Severity.info;
  }

  static String _buildEventLine(
    String label,
    String noiseLevel,
    double? rms,
    double? temp,
  ) {
    final db = (rms != null && rms > 0) ? (20 * (log(rms) / log(10))) : null;
    final parts = <String>[
      label.replaceAll('_', ' '),
      noiseLevel,
      if (db != null) '${db.toStringAsFixed(1)} dB',
      if (temp != null) '${temp.toStringAsFixed(1)}°C',
    ];
    return parts.join(' · ');
  }

  Future<void> _exportCsv() async {
    final rows = _filteredLogs;
    final buf = StringBuffer()
      ..writeln('Log ID,Timestamp,Department,Event,Level');
    for (final r in rows) {
      buf.writeln(
        '${_csvCell(r.id)},${_csvCell(_formatLogTimestamp(r.timestamp))},'
        '${_csvCell(r.departmentShort)},${_csvCell(r.event)},${_csvCell(r.severity.name)}',
      );
    }
    final name =
        'lumisense_logs_${DateTime.now().millisecondsSinceEpoch}.csv';
    final path = await saveCsvToFile(name, buf.toString());
    if (!mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    if (path != null) {
      messenger.showSnackBar(
        SnackBar(content: Text('CSV saved: $path')),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('CSV export started (browser download).')),
      );
    }
  }

  static String _csvCell(String s) {
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  String _formatLastEvent(DateTime? t) {
    if (t == null) {
      return '—';
    }
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    }
    if (diff.inHours < 24) {
      final h = t.hour;
      final m = t.minute.toString().padLeft(2, '0');
      final isPm = h >= 12;
      final hh = h % 12 == 0 ? 12 : h % 12;
      return '$hh:$m ${isPm ? 'PM' : 'AM'}';
    }
    return _formatLogTimestamp(t);
  }

  Future<void> _deleteLog(_LogEntry log) async {
    if (log.dbId != null) {
      try {
        await _supabase.from('noise_events').delete().eq('id', log.dbId!);
      } catch (_) {}
    }
    setState(() => _allLogs.removeWhere((e) => e.id == log.id));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredLogs;
    final criticalCount = filtered.where((l) => l.severity == _Severity.critical).length;
    final warningCount = filtered.where((l) => l.severity == _Severity.warning).length;
    final infoCount = filtered.where((l) => l.severity == _Severity.info).length;
    final deptDistinct = filtered.map((l) => l.departmentShort).toSet().length;
    final lastTs = filtered.isEmpty
        ? null
        : filtered.map((l) => l.timestamp).reduce((a, b) => a.isAfter(b) ? a : b);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    'System events and audit trail'
                    '${_usingMockFallback ? ' · demo data' : ''}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ),
              const Spacer(),
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
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(minHeight: 2, color: AppColors.primary),
            ),
          if (_error != null && !_usingMockFallback)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),
          _buildSummaryRow(
            total: filtered.length,
            critical: criticalCount,
            warnings: warningCount,
            info: infoCount,
            departments: deptDistinct,
            lastEvent: _formatLastEvent(lastTs),
          ),
          const SizedBox(height: 20),
          _buildFilterBar(context),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.shadowLow,
              ),
              child: Column(
                children: [
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
                          const SizedBox(width: 32),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(
                        color: AppColors.borderSubtle,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final log = filtered[index];
                        return _LogRow(
                          log: log,
                          canDelete: _currentRole == UserRole.superAdmin,
                          onDelete: () => _deleteLog(log),
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
      onTap: _exportCsv,
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

  Widget _buildSummaryRow({
    required int total,
    required int critical,
    required int warnings,
    required int info,
    required int departments,
    required String lastEvent,
  }) {
    return Row(
      children: [
        _SummaryStat(label: 'TOTAL EVENTS', value: '$total'),
        const SizedBox(width: 12),
        _SummaryStat(
          label: 'CRITICAL',
          value: '$critical',
          valueColor: AppColors.error,
        ),
        const SizedBox(width: 12),
        _SummaryStat(
          label: 'WARNINGS',
          value: '$warnings',
        ),
        const SizedBox(width: 12),
        _SummaryStat(
          label: 'INFO',
          value: '$info',
        ),
        const SizedBox(width: 12),
        _SummaryStat(
          label: 'DEPARTMENTS',
          value: '$departments',
        ),
        const SizedBox(width: 12),
        _SummaryStat(
          label: 'LAST EVENT',
          value: lastEvent,
          compactValue: true,
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.shadowLow,
      ),
      child: Row(
        children: [
          _filterLabel('Department'),
          const SizedBox(width: 8),
          DropdownButton<String?>(
            value: _deptFilter,
            underline: const SizedBox(),
            dropdownColor: AppColors.surfaceElevated,
            items: const [
              DropdownMenuItem(value: null, child: Text('All')),
              DropdownMenuItem(value: 'CS', child: Text('CS')),
              DropdownMenuItem(value: 'IT', child: Text('IT')),
              DropdownMenuItem(value: 'Engineering', child: Text('Engineering')),
            ],
            onChanged: (v) => setState(() => _deptFilter = v),
          ),
          const SizedBox(width: 24),
          _filterLabel('Severity'),
          const SizedBox(width: 8),
          DropdownButton<_Severity?>(
            value: _severityFilter,
            underline: const SizedBox(),
            dropdownColor: AppColors.surfaceElevated,
            items: [
              const DropdownMenuItem<_Severity?>(value: null, child: Text('All')),
              const DropdownMenuItem(value: _Severity.critical, child: Text('Critical')),
              const DropdownMenuItem(value: _Severity.warning, child: Text('Warning')),
              const DropdownMenuItem(value: _Severity.info, child: Text('Info')),
            ],
            onChanged: (v) => setState(() => _severityFilter = v),
          ),
          const SizedBox(width: 24),
          _filterLabel('Range'),
          const SizedBox(width: 8),
          DropdownButton<_LogDateRange>(
            value: _dateRange,
            underline: const SizedBox(),
            dropdownColor: AppColors.surfaceElevated,
            items: const [
              DropdownMenuItem(
                value: _LogDateRange.today,
                child: Text('Today'),
              ),
              DropdownMenuItem(
                value: _LogDateRange.last7Days,
                child: Text('Last 7 days'),
              ),
              DropdownMenuItem(
                value: _LogDateRange.last30Days,
                child: Text('Last 30 days'),
              ),
            ],
            onChanged: (v) {
              if (v != null) {
                setState(() => _dateRange = v);
              }
            },
          ),
          const SizedBox(width: 24),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search events…',
                hintStyle: TextStyle(color: AppColors.textTertiary.withValues(alpha: 0.8)),
                prefixIcon: const Icon(LucideIcons.search, size: 16, color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterLabel(String t) {
    return Text(
      t.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.textTertiary,
        letterSpacing: 0.8,
      ),
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
  final int? dbId;
  final String id;
  final DateTime timestamp;
  final String departmentShort;
  final String event;
  final _Severity severity;

  _LogEntry({
    required this.dbId,
    required this.id,
    required this.timestamp,
    required this.departmentShort,
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
            Expanded(
              flex: 2,
              child: Text(
                _formatLogTimestamp(widget.log.timestamp),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                widget.log.departmentShort,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
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
            Expanded(
              flex: 1,
              child: _SeverityLabel(severity: widget.log.severity),
            ),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Log', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: const Text(
          'Remove this entry permanently?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
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
}

class _SeverityLabel extends StatelessWidget {
  final _Severity severity;
  const _SeverityLabel({required this.severity});

  @override
  Widget build(BuildContext context) {
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
  final bool compactValue;

  const _SummaryStat({
    required this.label,
    required this.value,
    this.valueColor,
    this.compactValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                fontSize: 10,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: compactValue ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compactValue ? 18 : 28,
                fontWeight: FontWeight.w300,
                color: valueColor ?? AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
