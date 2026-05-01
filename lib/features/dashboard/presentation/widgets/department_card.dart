import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/domain/entities/zone_snapshot.dart';
import '../../../../core/domain/value_objects/noise_level.dart';
import '../../../../core/theme/app_colors.dart';
import 'sound_confidence_graph.dart';

class DepartmentCard extends StatelessWidget {
  const DepartmentCard({super.key, required this.snapshot});

  final ZoneSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final status = _statusInfo(snapshot.noiseLevel);

    return Column(
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
                _iconForZone(snapshot.zoneId),
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
                    snapshot.zoneName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeSince(snapshot.updatedAt),
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

        const SizedBox(height: 16),
        const Divider(color: AppColors.separator, thickness: 0.5, height: 1),
        const SizedBox(height: 8),

        // Metrics vertically structured
        _MetricRow(
          icon: LucideIcons.volume2,
          label: 'Sound Level',
          value: '${snapshot.noiseDb.toStringAsFixed(1)} dB',
          color: AppColors.textPrimary,
        ),
        _MetricRow(
          icon: LucideIcons.thermometer,
          label: 'Temperature',
          value: '${snapshot.temperatureC.toStringAsFixed(1)}°C',
          color: AppColors.textPrimary,
        ),

        const SizedBox(height: 8),
        const Divider(color: AppColors.separator, thickness: 0.5, height: 1),

        _SoundTypeSection(
          soundProfile: snapshot.soundProfile,
        ),
      ],
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

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoundTypeSection extends StatelessWidget {
  const _SoundTypeSection({
    required this.soundProfile,
  });

  final List<Map<String, dynamic>> soundProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(LucideIcons.waves, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 10),
            const Text(
              'Live Sound Profile',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SoundConfidenceGraph(soundProfile: soundProfile),
      ],
    );
  }
}
