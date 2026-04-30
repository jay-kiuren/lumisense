import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Service that runs the trained ANN model to classify sounds.
///
/// Input:  4 numbers from the INMP441 sensor (Avg, Peak, Min, RMS)
/// Output: Sound class label (ambient, conversation, furniture_dragging, phone_ringing)
class MLInferenceService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  // Scaler parameters (must match the training script's StandardScaler)
  List<double> _scalerMean = [];
  List<double> _scalerScale = [];

  Future<void> initialize() async {
    try {
      // Load the TFLite model
      _interpreter = await Interpreter.fromAsset('models/sound_classifier.tflite');

      // Load the class labels
      final labelData = await rootBundle.loadString('assets/models/class_labels.txt');
      _labels = labelData.split('\n').where((l) => l.isNotEmpty).toList();

      // Load the scaler parameters
      final scalerData = await rootBundle.loadString('assets/models/scaler_params.txt');
      for (final line in scalerData.split('\n')) {
        if (line.startsWith('mean:')) {
          _scalerMean = line.replaceFirst('mean:', '').split(',').map(double.parse).toList();
        } else if (line.startsWith('scale:')) {
          _scalerScale = line.replaceFirst('scale:', '').split(',').map(double.parse).toList();
        }
      }

      debugPrint('✓ ML model loaded. Labels: $_labels');
    } catch (e) {
      debugPrint('⚠ ML model not ready yet: $e');
    }
  }

  /// Takes the raw sensor data and returns the predicted sound class.
  ///
  /// [avg]  - Average amplitude from INMP441
  /// [peak] - Peak amplitude
  /// [min]  - Minimum amplitude
  /// [rms]  - Root Mean Square (energy)
  ///
  /// Returns a Map with 'label' and 'confidence'.
  Map<String, dynamic> classifySound({
    required double avg,
    required double peak,
    required double min,
    required double rms,
  }) {
    if (_interpreter == null || _labels.isEmpty || _scalerMean.isEmpty) {
      return {'label': 'unknown', 'confidence': 0.0};
    }

    try {
      // Normalize using the same StandardScaler from training
      final normalized = [
        (avg - _scalerMean[0]) / _scalerScale[0],
        (peak - _scalerMean[1]) / _scalerScale[1],
        (min - _scalerMean[2]) / _scalerScale[2],
        (rms - _scalerMean[3]) / _scalerScale[3],
      ];

      // Input shape: [1, 4]
      var input = [normalized];

      // Output shape: [1, num_classes]
      var output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

      // Run inference
      _interpreter!.run(input, output);

      // Find the best prediction
      List<double> probabilities = (output[0] as List).cast<double>();
      int maxIndex = 0;
      double maxProb = probabilities[0];

      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      // Sort all probabilities to return a full profile for the UI graph
      List<Map<String, dynamic>> fullProfile = [];
      for (int i = 0; i < probabilities.length; i++) {
        fullProfile.add({
          'label': _labels[i],
          'confidence': probabilities[i],
        });
      }
      
      // Sort highest to lowest
      fullProfile.sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));

      return {
        'label': _labels[maxIndex],
        'confidence': maxProb,
        'profile': fullProfile, // Contains all overlapping sounds
      };
    } catch (e) {
      return {'label': 'error', 'confidence': 0.0, 'profile': []};
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}
