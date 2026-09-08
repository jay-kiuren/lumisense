import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Checks Supabase for an admin-uploaded replacement AI model and
/// downloads it into local app storage if it's newer than what's already
/// cached on disk. This is what lets the client swap models (the sound
/// type classifier, or the noise source classifier) without needing a new
/// app build — the bundled asset in `assets/models/` is always the
/// fallback if nothing has been uploaded yet, or if the download fails.
class RemoteModelLoader {
  static const _bucket = 'ml-models';

  /// Returns local file paths for {tflite, labels, scaler} if a remote
  /// model is available and was downloaded (or already cached)
  /// successfully. Returns null if nothing has been uploaded for
  /// [modelType] yet, or if anything goes wrong — callers should fall
  /// back to the bundled asset in that case.
  static Future<Map<String, String>?> fetch(String modelType) async {
    try {
      final client = Supabase.instance.client;
      final row = await client
          .from('ml_model_versions')
          .select()
          .eq('model_type', modelType)
          .maybeSingle();

      if (row == null) return null;

      final supportDir = await getApplicationSupportDirectory();
      final modelDir = Directory('${supportDir.path}/ml_models/$modelType');
      await modelDir.create(recursive: true);

      final tflitePath = '${modelDir.path}/model.tflite';
      final labelsPath = '${modelDir.path}/labels.txt';
      final scalerPath = '${modelDir.path}/scaler.txt';
      final versionMarker = File('${modelDir.path}/.version');
      final versionTag = row['version_tag'] as String;

      final alreadyCached = await versionMarker.exists() &&
          (await versionMarker.readAsString()).trim() == versionTag &&
          await File(tflitePath).exists();

      if (!alreadyCached) {
        final storage = client.storage.from(_bucket);

        final tfliteBytes = await storage.download(row['storage_path'] as String);
        final labelsBytes = await storage.download(row['labels_path'] as String);
        final scalerBytes = await storage.download(row['scaler_path'] as String);

        await File(tflitePath).writeAsBytes(tfliteBytes);
        await File(labelsPath).writeAsBytes(labelsBytes);
        await File(scalerPath).writeAsBytes(scalerBytes);
        await versionMarker.writeAsString(versionTag);
      }

      return {'tflite': tflitePath, 'labels': labelsPath, 'scaler': scalerPath};
    } catch (_) {
      // Offline, bucket not set up yet, corrupt row, etc. — never let a
      // bad remote model prevent the app from starting. Caller falls
      // back to the bundled asset.
      return null;
    }
  }

  /// Uploads a replacement model (3 files) and marks it as the current
  /// version for [modelType]. Every device will pick it up next time
  /// [fetch] runs (app startup), no rebuild required.
  static Future<bool> upload({
    required String modelType,
    required File tfliteFile,
    required File labelsFile,
    required File scalerFile,
    String? uploadedBy,
  }) async {
    try {
      final client = Supabase.instance.client;
      final versionTag = DateTime.now().millisecondsSinceEpoch.toString();
      final storage = client.storage.from(_bucket);

      final tflitePath = '$modelType/$versionTag/model.tflite';
      final labelsPath = '$modelType/$versionTag/labels.txt';
      final scalerPath = '$modelType/$versionTag/scaler.txt';

      await storage.uploadBinary(
        tflitePath, await tfliteFile.readAsBytes(),
        fileOptions: const FileOptions(upsert: true),
      );
      await storage.uploadBinary(
        labelsPath, await labelsFile.readAsBytes(),
        fileOptions: const FileOptions(upsert: true),
      );
      await storage.uploadBinary(
        scalerPath, await scalerFile.readAsBytes(),
        fileOptions: const FileOptions(upsert: true),
      );

      await client.from('ml_model_versions').upsert({
        'model_type': modelType,
        'storage_path': tflitePath,
        'labels_path': labelsPath,
        'scaler_path': scalerPath,
        'version_tag': versionTag,
        'uploaded_by': uploadedBy,
        'updated_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (_) {
      return false;
    }
  }

  /// The currently-active version tag for [modelType], or null if no
  /// custom model has been uploaded (still using the bundled asset).
  static Future<String?> currentVersion(String modelType) async {
    try {
      final row = await Supabase.instance.client
          .from('ml_model_versions')
          .select('version_tag, uploaded_by, updated_at')
          .eq('model_type', modelType)
          .maybeSingle();
      return row == null ? null : row['version_tag'] as String;
    } catch (_) {
      return null;
    }
  }
}
