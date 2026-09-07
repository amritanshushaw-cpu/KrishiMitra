import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'dart:async';
import '../services/secure_db_service.dart';
import '../services/location_service.dart';

class FarmProvider extends ChangeNotifier {
  final BleService _bleService = BleService();
  final WifiCameraService _cameraService = WifiCameraService();
  final TfliteService _tfliteService = TfliteService();
  final SensorFusionService _fusionService = SensorFusionService();
  final VoiceTtsService _ttsService = VoiceTtsService();
  Timer? _wifiPollingTimer;

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
  TtsLanguage _ttsLanguage = TtsLanguage.english;
  int _activeTabIndex = 0;
  bool _isDarkMode = false;
  bool _isCockpitMode = false;
  bool _isTtsEnabled = true;
  String _activeFieldZone = 'Area 1: Rice & Tomato Block';
  String _farmerName = 'Saptak';
  String _farmerLocation = 'Bardhaman, West Bengal';
  double? _latitude;
  double? _longitude;
  bool _isFetchingLocation = false;
  String? _locationStatusMessage;

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
  String get farmerName => _farmerName;
  String get farmerLocation => _farmerLocation;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get isFetchingLocation => _isFetchingLocation;
  String? get locationStatusMessage => _locationStatusMessage;
  String get coordinatesDisplay {
    if (_latitude != null && _longitude != null) {
      final latDir = _latitude! >= 0 ? 'N' : 'S';
      final lonDir = _longitude! >= 0 ? 'E' : 'W';
      return '${_latitude!.abs().toStringAsFixed(4)}° $latDir, ${_longitude!.abs().toStringAsFixed(4)}° $lonDir';
    }
    return '';
  }
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
                ? 'टेक्स्ट टू वॉइस सक्रिय है। फसल स्कैन करने पर स्वचालित सलाह सुनाई जाएगी।'
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

  /// Composite Crop Health Index (CCHI)
  /// Algorithm modeled on ICAR Economic Threshold Levels (ETL) and Crop Water Stress Index (CWSI).
  int get farmHealthScore {
    int score = 100; // Optimal Yield Potential

    // 1. Pathology Penalty (based on Percent Disease Index - PDI)
    if (_parsedDiagnosis != null) {
      if (_parsedDiagnosis!.disease.status == ParameterStatus.critical) {
        score -= 35; // Severe outbreak reduces yield potential dramatically
      } else if (_parsedDiagnosis!.disease.status == ParameterStatus.warning) {
        score -= 15;
      }

      // 2. Entomology Penalty (based on Economic Threshold Levels - ETL)
      if (_parsedDiagnosis!.pest.status == ParameterStatus.critical) {
        score -= 25; 
      }
      
      // 3. Nutritional Stress
      if (_parsedDiagnosis!.nutrient.status != ParameterStatus.optimal) {
        score -= 10;
      }
    }

    // 4. Hydrology & Meteorological Stress (CWSI - Crop Water Stress Index)
    final double temp = _currentSensorData.temperature;
    final int soil = _currentSensorData.soilMoisture;

    // Heat Stress Penalty (Pollen sterility threshold for typical Indian crops > 35C)
    if (temp > 35.0) {
      score -= 10;
    } else if (temp < 10.0) {
      score -= 5; // Cold stress
    }

    // Soil Moisture Stress Penalty
    if (soil < 30) {
      score -= 20; // Drought stress / Permanent Wilting Point risk
    } else if (soil > 85) {
      score -= 15; // Waterlogging / Root Hypoxia risk
    }

    // Ensure bounds
    if (score < 15) score = 15; // Minimum baseline to prevent absolute zero logic errors
    if (score > 100) score = 100;

    return score;
  }

  FarmProvider() {
    _initServices();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString('preferred_language');
      if (savedLang == 'hindi') {
        _ttsLanguage = TtsLanguage.hindi;
      } else if (savedLang == 'bengali') {
        _ttsLanguage = TtsLanguage.bengali;
      } else {
        _ttsLanguage = TtsLanguage.english; // Default
      }
      _ttsService.setLanguage(_ttsLanguage);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _initServices() async {
    _statusMessage = 'Initializing Edge Pipeline...';
    notifyListeners();

    await _tfliteService.initialize();
    await _fusionService.initialize();
    _ttsService.onPlayingStateChanged = (playing) {
      notifyListeners();
    };
    await _ttsService.initialize();

    _bleService.stateStream.listen((state) {
      _bleState = state;
      notifyListeners();
    });

    // Start Polling ESP32 Wi-Fi for Sensors instead of BLE
    _wifiPollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final Map<String, dynamic>? data = await _cameraService.fetchSensorData();
        if (data != null) {
          final double t = (data['temperature'] as num?)?.toDouble() ?? 0.0;
          final double h = (data['humidity'] as num?)?.toDouble() ?? 0.0;
          final int s = (data['soil'] as num?)?.toInt() ?? 0;
          final bool r = data['rain'] == true;
          
          _currentSensorData = SensorData(
            temperature: t,
            humidity: h,
            soilMoisture: s,
            rain: r ? 1 : 0,
          );
          
          if (_lastInference != null) {
            _fusedAdvisory = _fusionService.fuse(
              inference: _lastInference!,
              sensor: _currentSensorData,
            );
          }
          notifyListeners();
        }
      } catch (e) { }
    });

    await _bleService.connect();
    await _loadFarmerProfile();
    await _loadFarmerLocation();
    autoFetchLocation();
    _statusMessage = 'System Ready (Offline)';
    notifyListeners();
  }

  Future<void> togglePump() async {
    final bool nextState = !_isPumpLocked;
    final bool success = await _cameraService.setPumpState(nextState);
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
    _statusMessage = 'ðŸ›¡ï¸ Safety Net Active: Loading Local Pitch Asset...';
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
      await _cameraService.setPumpState(true);
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
      await _ttsService.speak(_fusedAdvisory!.ttsScriptHi, overrideLang: TtsLanguage.hindi);
    }
    notifyListeners();
  }

  Future<void> stopVoiceAdvisory() async {
    await _ttsService.stop();
    notifyListeners();
  }


  Future<void> setTtsLanguage(TtsLanguage lang) async {
    _ttsLanguage = lang;
    _ttsService.setLanguage(lang);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      String langStr = 'bengali';
      if (lang == TtsLanguage.hindi) langStr = 'hindi';
      if (lang == TtsLanguage.english) langStr = 'english';
      await prefs.setString('preferred_language', langStr);
    } catch (_) {}
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

  Future<void> _loadFarmerProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('farmer_name');
      if (savedName != null && savedName.trim().isNotEmpty) {
        _farmerName = savedName.trim();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading farmer profile: $e');
    }
  }

  Future<void> _loadFarmerLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLoc = prefs.getString('farmer_location');
      if (savedLoc != null && savedLoc.trim().isNotEmpty) {
        _farmerLocation = savedLoc.trim();
      }
      _latitude = prefs.getDouble('farmer_lat');
      _longitude = prefs.getDouble('farmer_lon');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading location: $e');
    }
  }

  Future<void> autoFetchLocation() async {
    _isFetchingLocation = true;
    _locationStatusMessage = 'Auto-detecting farm location...';
    notifyListeners();

    try {
      final loc = await LocationService.instance.fetchCurrentLocation();
      if (loc != null) {
        _farmerLocation = loc.formattedPlotLocation;
        _latitude = loc.latitude;
        _longitude = loc.longitude;
        _locationStatusMessage = 'Location synced: $_farmerLocation';
      } else {
        _locationStatusMessage = 'Using cached farm location';
      }
    } catch (e) {
      _locationStatusMessage = 'Offline: Using cached location';
    } finally {
      _isFetchingLocation = false;
      notifyListeners();
    }
  }

  void setFarmerLocation(String newLocation) {
    if (newLocation.trim().isNotEmpty) {
      _farmerLocation = newLocation.trim();
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('farmer_location', _farmerLocation);
      });
      notifyListeners();
    }
  }

  void setFarmerName(String name) {
    _farmerName = name.trim().isNotEmpty ? name.trim() : 'Saptak';
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('farmer_name', _farmerName);
    });
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await stopVoiceAdvisory();
    notifyListeners();
  }

  @override
  void dispose() {
    _wifiPollingTimer?.cancel();
    _bleService.dispose();
    _tfliteService.dispose();
    _ttsService.stop();
    super.dispose();
  }
}

