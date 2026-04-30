import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/domain/entities/zone_snapshot.dart';
import '../../../../core/domain/value_objects/noise_level.dart';
import '../../../../core/theme/app_colors.dart';
import 'sound_confidence_graph.dart';

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
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isHovered ? AppColors.shadowHigh : AppColors.shadowMedium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _iconForZone(widget.snapshot.zoneId),
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.snapshot.zoneName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _timeSince(widget.snapshot.updatedAt),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 12,
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

            const SizedBox(height: 20),

            // Metrics row
            Row(
              children: [
                _MetricTile(
                  icon: LucideIcons.volume2,
                  label: 'Sound',
                  value: '${widget.snapshot.noiseDb.toStringAsFixed(1)} dB',
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 16),
                _MetricTile(
                  icon: LucideIcons.thermometer,
                  label: 'Temp',
                  value: '${widget.snapshot.temperatureC.toStringAsFixed(1)}°C',
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SoundTypeTile(
                    icon: LucideIcons.waves,
                    label: 'Type',
                    color: AppColors.textSecondary,
                    soundProfile: widget.snapshot.soundProfile,
                  ),
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

  _StatusData _statusInfo(NoiseLevel level) {
    switch (level) {
      case NoiseLevel.quiet:
        return _StatusData('Live', AppColors.statusLive);
      case NoiseLevel.normal:
        return _StatusData('Stable', AppColors.statusStable);
      case NoiseLevel.warning:
        return _StatusData('Caution', AppColors.statusWarning);
      case NoiseLevel.critical:
        return _StatusData('Critical', AppColors.statusCritical);
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 15, color: AppColors.textTertiary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
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

class _SoundTypeTile extends StatelessWidget {
  const _SoundTypeTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.soundProfile,
  });

  final IconData icon;
  final String label;
  final Color color;
  final List<Map<String, dynamic>> soundProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.textTertiary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SoundConfidenceGraph(soundProfile: soundProfile),
        ],
      ),
    );
  }
}
