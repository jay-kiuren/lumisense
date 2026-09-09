import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/supabase/supabase_telemetry_repository.dart';
import '../../../../core/config/zone_names.dart';

// Zone ID mapping (matches Supabase zones table seeds)
const _zoneIds = {ZoneNames.zone1: 1, ZoneNames.zone2: 2, ZoneNames.zone3: 3};

class ActionCenter extends StatefulWidget {
  const ActionCenter({super.key});

  @override
  State<ActionCenter> createState() => _ActionCenterState();
}

class _ActionCenterState extends State<ActionCenter> {
  final _repo = SupabaseTelemetryRepository();

  // Mute override: when true, zone is MUTED (mode=manual, manual_state=false)
  bool _itBuzzerOverride  = false;
  bool _csBuzzerOverride  = false;
  bool _engBuzzerOverride = false;

  // Tracks which zones have a pending "fire" in progress (button cooldown)
  final Set<String> _triggering = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.shadowLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ──────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.shieldAlert,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alarm System Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Manage automated buzzer triggers',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: AppColors.separator, height: 24, thickness: 0.5),

          // ── ZONE ROWS ────────────────────────────────────────
          _buildZoneRow(
            icon: LucideIcons.monitorSpeaker,
            label: ZoneNames.zone1,
            zoneId: 1,
            isMuted: _itBuzzerOverride,
            onMuteChanged: (v) => _onMuteChanged(ZoneNames.zone1, v),
          ),
          const SizedBox(height: 14),
          _buildZoneRow(
            icon: LucideIcons.server,
            label: ZoneNames.zone2,
            zoneId: 2,
            isMuted: _csBuzzerOverride,
            onMuteChanged: (v) => _onMuteChanged(ZoneNames.zone2, v),
          ),
          const SizedBox(height: 14),
          _buildZoneRow(
            icon: LucideIcons.cpu,
            label: ZoneNames.zone3,
            zoneId: 3,
            isMuted: _engBuzzerOverride,
            onMuteChanged: (v) => _onMuteChanged(ZoneNames.zone3, v),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  ZONE ROW — mute switch + manual trigger button
  // ─────────────────────────────────────────────────────────
  Widget _buildZoneRow({
    required IconData icon,
    required String label,
    required int zoneId,
    required bool isMuted,
    required ValueChanged<bool> onMuteChanged,
  }) {
    final isBusy = _triggering.contains(label);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: icon · label · status badge · mute switch
        Row(
          children: [
            Icon(icon, size: 17, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Status badge
            SizedBox(
              width: 78,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isMuted ? AppColors.error : AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isMuted ? 'Muted' : 'Armed',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isMuted
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 88,
              child: Align(
                alignment: Alignment.centerRight,
                child: Switch(
                  value: isMuted,
                  onChanged: onMuteChanged,
                  activeThumbColor: AppColors.textPrimary,
                  activeTrackColor: AppColors.textTertiary,
                  inactiveThumbColor: AppColors.textSecondary,
                  inactiveTrackColor: AppColors.statusLive,
                  trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                ),
              ),
            ),
          ],
        ),

        // Row 2: "Override Trigger" button (disabled when muted or busy)
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: _TriggerButton(
            label: label,
            zoneId: zoneId,
            isMuted: isMuted,
            isBusy: isBusy,
            onTrigger: () => _onTriggerPressed(label, zoneId),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  MUTE TOGGLE — writes mode='manual', manual_state=false
  //  (silences auto-trigger) or restores mode='auto'
  // ─────────────────────────────────────────────────────────
  Future<void> _onMuteChanged(String label, bool mute) async {
    setState(() {
      switch (label) {
        case ZoneNames.zone1: _itBuzzerOverride  = mute; break;
        case ZoneNames.zone2: _csBuzzerOverride  = mute; break;
        case ZoneNames.zone3: _engBuzzerOverride = mute; break;
      }
    });

    final zoneId = _zoneIds[label]!;
    await _repo.setMuteZone(zoneId: zoneId, mute: mute);
  }

  // ─────────────────────────────────────────────────────────
  //  OVERRIDE TRIGGER — fires buzzer for 5 s then resets
  // ─────────────────────────────────────────────────────────
  Future<void> _onTriggerPressed(String label, int zoneId) async {
    if (_triggering.contains(label)) return;

    setState(() => _triggering.add(label));
    final durationSec = SettingsService.instance.settings.value.alarmDurationSec.round();
    await _repo.triggerBuzzerOverride(zoneId: zoneId, durationSeconds: durationSec);

    // Show a brief snackbar confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Buzzer triggered for $label (${durationSec}s)'),
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.surfaceElevated,
        ),
      );
    }

    // Re-enable after durationSec + 1 s buffer
    await Future.delayed(Duration(seconds: durationSec + 1));
    if (mounted) setState(() => _triggering.remove(label));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TRIGGER BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _TriggerButton extends StatelessWidget {
  const _TriggerButton({
    required this.label,
    required this.zoneId,
    required this.isMuted,
    required this.isBusy,
    required this.onTrigger,
  });

  final String label;
  final int zoneId;
  final bool isMuted;
  final bool isBusy;
  final VoidCallback onTrigger;

  @override
  Widget build(BuildContext context) {
    final disabled = isMuted || isBusy;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTrigger,
        borderRadius: BorderRadius.circular(7),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: disabled
                ? AppColors.surfaceElevated.withValues(alpha: 0.4)
                : AppColors.statusWarning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: disabled
                  ? AppColors.separator
                  : AppColors.statusWarning.withValues(alpha: 0.35),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isBusy) ...[
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppColors.statusWarning.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'Firing...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.statusWarning.withValues(alpha: 0.6),
                  ),
                ),
              ] else ...[
                Icon(
                  LucideIcons.bellRing,
                  size: 13,
                  color: disabled
                      ? AppColors.textTertiary
                      : AppColors.statusWarning,
                ),
                const SizedBox(width: 7),
                Text(
                  isMuted ? 'Buzzer Muted' : 'Override Trigger',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: disabled
                        ? AppColors.textTertiary
                        : AppColors.statusWarning,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}