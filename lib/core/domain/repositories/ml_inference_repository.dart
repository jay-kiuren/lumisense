/// Contract for future ML integration.
///
/// Implementations can call Edge Impulse APIs, local inference services,
/// or receive already-classified events from ESP32 nodes.
abstract class MlInferenceRepository {
  Future<void> syncModelMetadata();
  Future<List<String>> fetchSupportedSoundClasses();
}
