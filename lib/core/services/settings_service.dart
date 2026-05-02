import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_settings.dart';

/// Singleton service that loads app settings from Supabase once on startup
/// and exposes them as a [ValueNotifier].
///
/// Usage:
///   final settings = SettingsService.instance.settings.value;
///
/// To react to changes:
///   SettingsService.instance.settings.addListener(() { ... });
class SettingsService {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  final ValueNotifier<AppSettings> settings =
      ValueNotifier<AppSettings>(const AppSettings());

  bool _loaded = false;

  // ── Public API ──────────────────────────────────────────────────────────

  /// Call once at app startup (e.g. in main.dart after Supabase.initialize).
  /// Safe to call multiple times — only fetches once unless [force] is true.
  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;
    try {
      final client = Supabase.instance.client;
      final rows = await client
          .from('settings')
          .select()
          .eq('id', 1)
          .limit(1);

      if (rows.isNotEmpty) {
        settings.value = AppSettings.fromMap(rows.first);
      }
      _loaded = true;
    } catch (_) {
      // Network error — keep defaults; try again next time
    }
  }

  /// Persist a new [AppSettings] to Supabase and update the local notifier.
  Future<bool> save(AppSettings newSettings) async {
    try {
      final client = Supabase.instance.client;
      await client.from('settings').upsert(newSettings.toMap());
      settings.value = newSettings;
      return true;
    } catch (_) {
      return false;
    }
  }
}