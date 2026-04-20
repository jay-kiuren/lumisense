import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/domain/entities/zone_snapshot.dart';
import '../../../../core/domain/value_objects/noise_level.dart';
import '../../../../core/theme/app_colors.dart';

class DepartmentCard extends StatefulWidget {
  const DepartmentCard({super.key, required this.snapshot});

  final ZoneSnapshot snapshot;

  @override
  State<DepartmentCard> createState() => _DepartmentCardState();
}

class _DepartmentCardState extends State<DepartmentCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final status = _statusInfo(widget.snapshot.noiseLevel);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? status.color.withOpacity(0.3)
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: status.color.withOpacity(0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: status.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _iconForZone(widget.snapshot.zoneId),
                    color: status.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.snapshot.zoneName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _timeSince(widget.snapshot.updatedAt),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(
                  label: status.label,
                  color: status.color,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Metrics row
            Row(
              children: [
                _MetricTile(
                  icon: LucideIcons.volume2,
                  label: 'Sound',
                  value: '${widget.snapshot.noiseDb.toStringAsFixed(1)} dB',
                  color: status.color,
                ),
                const SizedBox(width: 16),
                _MetricTile(
                  icon: LucideIcons.thermometer,
                  label: 'Temp',
                  value: '${widget.snapshot.temperatureC.toStringAsFixed(1)}°C',
                  color: AppColors.primary,
                ),
                const SizedBox(width: 16),
                _MetricTile(
                  icon: LucideIcons.waves,
                  label: 'Type',
                  value: _formatSoundClass(widget.snapshot.soundClass),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForZone(String zoneId) {
    switch (zoneId) {
      case 'it':
        return LucideIcons.monitorSpeaker;
      case 'cs':
        return LucideIcons.server;
      case 'eng':
        return LucideIcons.cpu;
      default:
        return LucideIcons.building;
    }
  }

  String _timeSince(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 10) return 'Just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  String _formatSoundClass(String cls) {
    return cls.replaceAll('_', ' ').split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }

  _StatusData _statusInfo(NoiseLevel level) {
    switch (level) {
      case NoiseLevel.quiet:
        return _StatusData('Quiet', AppColors.success);
      case NoiseLevel.normal:
        return _StatusData('Normal', AppColors.primary);
      case NoiseLevel.warning:
        return _StatusData('Warning', AppColors.warning);
      case NoiseLevel.critical:
        return _StatusData('Critical', AppColors.error);
    }
  }
}

class _StatusData {
  final String label;
  final Color color;
  _StatusData(this.label, this.color);
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
