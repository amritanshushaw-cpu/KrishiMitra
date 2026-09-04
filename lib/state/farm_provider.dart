import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/localization/app_strings.dart';
import '../models/inference_result.dart';
import '../models/parsed_diagnosis.dart';
import '../models/sensor_data.dart';
import '../services/ble_service.dart';
import '../services/sensor_fusion_service.dart';
import '../services/tflite_service.dart';
import '../services/voice_tts_service.dart';
import '../services/wifi_camera_service.dart';

class FarmProvider extends ChangeNotifier {
  final BleService _bleService = BleService();
  final WifiCameraService _cameraService = WifiCameraService();
  final TfliteService _tfliteService = TfliteService();
  final SensorFusionService _fusionService = SensorFusionService();
  final VoiceTtsService _ttsService = VoiceTtsService();

  // State Variables
  SensorData _currentSensorData = SensorData.defaultInitial();
  BleConnectionState _bleState = BleConnectionState.disconnected;
  bool _isPumpLocked = false;
  bool _isCapturing = false;
  bool _isInferenceRunning = false;
  String? _statusMessage;

  Uint8List? _currentLeafBytes;
  InferenceResult? _lastInference;
  ParsedDiagnosis? _parsedDiagnosis;
  FusedAdvisoryResult? _fusedAdvisory;

  bool _isSafetyNetMode = false;
  TtsLanguage _ttsLanguage = TtsLanguage.bengali;
  int _activeTabIndex = 0;
  bool _isDarkMode = false;
  bool _isCockpitMode = false;
  bool _isTtsEnabled = true;
  String _activeFieldZone = 'Area 1: Rice & Tomato Block';

  // Getters
  SensorData get sensorData => _currentSensorData;
  BleConnectionState get bleState => _bleState;
  bool get isPumpLocked => _isPumpLocked;
  bool get isCapturing => _isCapturing;
  bool get isInferenceRunning => _isInferenceRunning;
  String? get statusMessage => _statusMessage;
  Uint8List? get currentLeafBytes => _currentLeafBytes;
  InferenceResult? get lastInference => _lastInference;
  ParsedDiagnosis? get parsedDiagnosis => _parsedDiagnosis;
  FusedAdvisoryResult? get fusedAdvisory => _fusedAdvisory;
  bool get isSafetyNetMode => _isSafetyNetMode;
  TtsLanguage get ttsLanguage => _ttsLanguage;
  bool get isTtsPlaying => _ttsService.isPlaying;
  bool get isTtsEnabled => _isTtsEnabled;
  int get activeTabIndex => _activeTabIndex;
  bool get isDarkMode => _isDarkMode;
  bool get isCockpitMode => _isCockpitMode;
  String get activeFieldZone => _activeFieldZone;
  AppStrings get strings => AppStrings.of(_ttsLanguage);

  void toggleTtsEnabled([bool? value]) {
    _isTtsEnabled = value ?? !_isTtsEnabled;
    if (!_isTtsEnabled) {
      stopVoiceAdvisory();
    }
    notifyListeners();
  }

  Future<void> toggleVoicePlayback() async {
    if (isTtsPlaying) {
      await stopVoiceAdvisory();
    } else {
      if (_fusedAdvisory != null) {
        await playVoiceAdvisory();
      } else {
        final testMsg = _ttsLanguage == TtsLanguage.bengali
            ? 'টেক্সট টু ভয়েস সক্রিয় আছে। ফসল স্ক্যান করলে স্বয়ংক্রিয় প্রেসক্রিপশন শোনানো হবে।'
            : (_ttsLanguage == TtsLanguage.hindi
                ? 'टेक्स्ट टू वॉयस सक्रिय है। फसल स्कैन करने पर स्वचालित सलाह सुनाई जाएगी।'
                : 'Text to voice is active. Diagnosis and ICAR prescription will be read aloud automatically.');
        await _ttsService.speak(testMsg, overrideLang: _ttsLanguage);
        notifyListeners();
      }
    }
  }

  void toggleCockpitMode([bool? value]) {
    _isCockpitMode = value ?? !_isCockpitMode;
    notifyListeners();
  }

  int get farmHealthScore {
    if (_parsedDiagnosis == null) return 92;
    if (_parsedDiagnosis!.disease.status == ParameterStatus.critical) return 64;
    if (_parsedDiagnosis!.disease.status == ParameterStatus.warning) return 78;
    return 95;
  }

  FarmProvider() {
    _initServices();
  }

  Future<void> _initServices() async {
    _statusMessage = 'Initializing Edge Pipeline...';
    notifyListeners();

    await _tfliteService.initialize();
    await _fusionService.initialize();
    await _ttsService.initialize();

    _bleService.stateStream.listen((state) {
      _bleState = state;
      notifyListeners();
    });

    _bleService.sensorStream.listen((sensorData) {
      _currentSensorData = sensorData;
      if (_lastInference != null) {
        _fusedAdvisory = _fusionService.fuse(
          inference: _lastInference!,
          sensor: _currentSensorData,
        );
      }
      notifyListeners();
    });

    await _bleService.connect();
    _statusMessage = 'System Ready (Offline)';
    notifyListeners();
  }

  Future<void> togglePump() async {
    final bool nextState = !_isPumpLocked;
    final bool success = await _bleService.setPumpState(nextState);
    if (success) {
      _isPumpLocked = nextState;
      notifyListeners();
    }
  }

  Future<void> captureAndAnalyze() async {
    _isCapturing = true;
    _statusMessage = 'Requesting 800x600 stream from ESP32...';
    notifyListeners();

    try {
      final Uint8List bytes = await _cameraService.captureFromEsp32();
      _currentLeafBytes = bytes;
      _isCapturing = false;
      notifyListeners();

      await _processImageBytes(bytes, 'camera_stream.jpg');
    } catch (e) {
      _isCapturing = false;
      _statusMessage = 'ESP32 Camera unreachable. Auto-activating Safety Net...';
      notifyListeners();
      await triggerSafetyNetDemo();
    }
  }

  Future<void> triggerSafetyNetDemo({String? assetPath}) async {
    _isSafetyNetMode = true;
    _isInferenceRunning = true;
    _statusMessage = '🛡️ Safety Net Active: Loading Local Pitch Asset...';
    notifyListeners();

    try {
      final String path = assetPath ?? AppConstants.demoLateBlightAsset;
      final Uint8List bytes = await _cameraService.loadDemoAssetLeaf(assetPath: path);
      _currentLeafBytes = bytes;
      await _processImageBytes(bytes, path);
      _statusMessage = 'Edge Analysis Complete (Zero Latency)';
    } catch (e) {
      _statusMessage = 'Error loading demo asset: $e';
    } finally {
      _isInferenceRunning = false;
      notifyListeners();
    }
  }

  Future<void> _processImageBytes(Uint8List bytes, String hintName) async {
    _isInferenceRunning = true;
    _statusMessage = 'Cropping 224x224 & Running TFLite...';
    notifyListeners();

    final result = await _tfliteService.runInference(bytes, hintName: hintName);
    _lastInference = result;

    _parsedDiagnosis = ParsedDiagnosis.fromInference(result);

    _fusedAdvisory = _fusionService.fuse(
      inference: result,
      sensor: _currentSensorData,
    );

    if (_fusedAdvisory!.recommendedPumpAction == 'LOCK' && !_isPumpLocked) {
      await _bleService.setPumpState(true);
      _isPumpLocked = true;
    }

    _isInferenceRunning = false;
    _statusMessage = 'Diagnosis: ${result.topLabel} (${(result.topConfidence * 100).toStringAsFixed(1)}%)';
    notifyListeners();

    if (_isTtsEnabled) {
      playVoiceAdvisory();
    }
  }

  Future<void> playVoiceAdvisory() async {
    if (_fusedAdvisory == null) return;

    if (_ttsLanguage == TtsLanguage.bengali) {
      await _ttsService.speak(_fusedAdvisory!.ttsScriptBn, overrideLang: TtsLanguage.bengali);
    } else if (_ttsLanguage == TtsLanguage.english) {
      await _ttsService.speak(_fusedAdvisory!.ttsScriptEn, overrideLang: TtsLanguage.english);
    } else {
      await _ttsService.speak(_fusedAdvisory!.ttsScriptBn, overrideLang: TtsLanguage.hindi);
    }
    notifyListeners();
  }

  Future<void> stopVoiceAdvisory() async {
    await _ttsService.stop();
    notifyListeners();
  }


  void setTtsLanguage(TtsLanguage lang) {
    _ttsLanguage = lang;
    notifyListeners();
  }

  void setTabIndex(int index) {
    _activeTabIndex = index;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setActiveFieldZone(String zone) {
    _activeFieldZone = zone;
    notifyListeners();
  }

  void injectTelemetry({required double temp, required int soil, required int rain}) {
    _bleService.injectTelemetry(temp: temp, soil: soil, rain: rain);
  }

  @override
  void dispose() {
    _bleService.dispose();
    _tfliteService.dispose();
    _ttsService.stop();
    super.dispose();
  }
}
