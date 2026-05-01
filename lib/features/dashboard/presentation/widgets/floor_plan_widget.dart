import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';

import '../../../../core/domain/entities/zone_snapshot.dart';
import '../../../../core/domain/value_objects/noise_level.dart';

class FloorPlanWidget extends StatefulWidget {
  const FloorPlanWidget({super.key, this.liveZones});
  
  final List<ZoneSnapshot>? liveZones;

  @override
  State<FloorPlanWidget> createState() => _FloorPlanWidgetState();
}

class _ZoneConfig {
  final int id;
  final String title;
  final double x;
  final double y;

  const _ZoneConfig({
    required this.id,
    required this.title,
    required this.x,
    required this.y,
  });
}

const _zones = [
  _ZoneConfig(id: 1, title: 'IT DEPARTMENT', x: 0.30, y: 0.25),
  _ZoneConfig(id: 2, title: 'CS DEPARTMENT', x: 0.35, y: 0.75),
  _ZoneConfig(id: 3, title: 'ENGINEERING', x: 0.75, y: 0.50),
];

class _FloorPlanWidgetState extends State<FloorPlanWidget> {
  final _rng = Random(42);
  Timer? _timer;
  final Map<int, _AiEvent> _demoEvents = {};

  bool get _useDemoData {
    return widget.liveZones == null || widget.liveZones!.isEmpty;
  }

  @override
  void initState() {
    super.initState();
    // Keep demo data spinning just in case it's used
    for (final z in _zones) {
      _demoEvents[z.id] = _AiEvent.random(_rng);
    }
    
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      if (_useDemoData) {
        setState(() {
          final targetId = _zones[_rng.nextInt(_zones.length)].id;
          _demoEvents[targetId] = _AiEvent.random(_rng);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  IconData _getIconForClass(String soundClass) {
    switch (soundClass.toLowerCase()) {
      case 'ambient':
      case 'background noise':
      case 'quiet':
        return LucideIcons.wind;
      case 'conversation':
      case 'talking':
        return LucideIcons.messageCircle;
      case 'laughing':
      case 'laughter':
        return LucideIcons.smile;
      case 'shouting':
        return LucideIcons.megaphone;
      case 'clap':
      case 'clapping':
        return LucideIcons.hand;
      case 'table dragging':
      case 'chair drag':
      case 'furniture_dragging':
        return LucideIcons.armchair;
      case 'object drop':
        return LucideIcons.box;
      case 'ring phone':
      case 'phone_ringing':
        return LucideIcons.phoneCall;
      case 'notification':
        return LucideIcons.bell;
      default:
        return LucideIcons.activity;
    }
  }

  _AiSeverity _getSeverityForLevel(NoiseLevel level) {
    switch (level) {
      case NoiseLevel.quiet:
      case NoiseLevel.normal:
        return _AiSeverity.low;
      case NoiseLevel.warning:
        return _AiSeverity.medium;
      case NoiseLevel.critical:
        return _AiSeverity.high;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, _AiEvent> currentEvents = {};
    
    if (!_useDemoData) {
      for (final snapshot in widget.liveZones!) {
        final zId = int.tryParse(snapshot.zoneId) ?? 0;
        currentEvents[zId] = _AiEvent(
          x: 0, y: 0, // Not used by ZoneMarker directly anymore
          label: snapshot.soundClass,
          icon: _getIconForClass(snapshot.soundClass),
          severity: _getSeverityForLevel(snapshot.noiseLevel),
          db: snapshot.noiseDb,
        );
      }
    } else {
      currentEvents.addAll(_demoEvents);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.shadowLow,
      ),
      child: SizedBox.expand(
        child: Stack(
          children: [
            // Generated Floor Plan Background
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/floor_plan.png',
                  fit: BoxFit.cover,
                  color: AppColors.background.withValues(alpha: 0.1),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
            ),
            
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: _zones.map((zone) {
                        final event = currentEvents[zone.id];
                        if (event == null) return const SizedBox.shrink();
                        return Positioned(
                          left: zone.x * constraints.maxWidth,
                          top: zone.y * constraints.maxHeight,
                          child: _ZoneMarker(config: zone, event: event),
                        );
                      }).toList(growable: false),
                    );
                  },
                ),
              ),
            ),
            
            if (_useDemoData) 
              Positioned(
                left: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.separator.withValues(alpha: 0.6)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.flaskConical, size: 14, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Text(
                        'Demo stream (no Supabase)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ZoneMarker extends StatelessWidget {
  const _ZoneMarker({required this.config, required this.event});
  final _ZoneConfig config;
  final _AiEvent event;

  @override
  Widget build(BuildContext context) {
    final severityColor = switch (event.severity) {
      _AiSeverity.low => AppColors.success,
      _AiSeverity.medium => AppColors.statusWarning,
      _AiSeverity.high => AppColors.statusCritical,
    };

    // Clean integrated zone HUD
    return Transform.translate(
      offset: const Offset(-80, -35), // Centered above the coordinate
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated.withValues(alpha: 0.9),
          border: Border(
            left: BorderSide(color: severityColor, width: 4),
            bottom: BorderSide(color: severityColor.withValues(alpha: 0.3), width: 1),
            top: BorderSide(color: AppColors.separator.withValues(alpha: 0.2), width: 1),
            right: BorderSide(color: AppColors.separator.withValues(alpha: 0.2), width: 1),
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          boxShadow: [
            BoxShadow(
              color: severityColor.withValues(alpha: 0.15),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              config.title,
              style: TextStyle(
                color: AppColors.textPrimary.withValues(alpha: 0.9),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(event.icon, size: 14, color: severityColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    event.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: severityColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${event.db.toStringAsFixed(1)} dB',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
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

enum _AiSeverity { low, medium, high }

class _AiEvent {
  const _AiEvent({
    required this.x,
    required this.y,
    required this.label,
    required this.icon,
    required this.severity,
    required this.db,
  });

  // Normalized 0..1 coordinates within the map area.
  final double x;
  final double y;
  final String label;
  final IconData icon;
  final _AiSeverity severity;
  final double db;

  static _AiEvent random(Random rng) {
    final choices = <(String, IconData, _AiSeverity, double)>[
      ('Ambient', LucideIcons.wind, _AiSeverity.low, 38 + rng.nextDouble() * 8),
      ('Conversation', LucideIcons.messageCircle, _AiSeverity.medium, 52 + rng.nextDouble() * 10),
      ('Laughing', LucideIcons.smile, _AiSeverity.medium, 55 + rng.nextDouble() * 8),
      ('Shouting', LucideIcons.megaphone, _AiSeverity.high, 68 + rng.nextDouble() * 12),
      ('Chair drag', LucideIcons.armchair, _AiSeverity.medium, 58 + rng.nextDouble() * 8),
    ];
    final c = choices[rng.nextInt(choices.length)];
    final x = rng.nextDouble().clamp(0.08, 0.92);
    final y = rng.nextDouble().clamp(0.12, 0.88);
    return _AiEvent(x: x, y: y, label: c.$1, icon: c.$2, severity: c.$3, db: c.$4);
  }
}
