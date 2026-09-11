import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
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
import '../services/secure_db_service.dart';
import 'dart:async';
import '../services/location_service.dart';


class FarmNotification {
  final String id;
  final String message;
  final DateTime timestamp;
  bool isResponded;

  FarmNotification({
    required this.id,
    required this.message,
    required this.timestamp,
    this.isResponded = false,
  });
}

class FarmProvider extends ChangeNotifier {
  final BleService _bleService = BleService();
  final WifiCameraService _cameraService = WifiCameraService();
  final TfliteService _tfliteService = TfliteService();
  final SensorFusionService _fusionService = SensorFusionService();
  final VoiceTtsService _ttsService = VoiceTtsService();
  final SecureDatabaseService _dbService = SecureDatabaseService.instance;
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
  final List<int> _tabHistory = [0];
  final List<FarmNotification> _notifications = [];
  bool _isDarkMode = true;
  bool _isCockpitMode = false;
  bool _isTtsEnabled = true;
  String _activeFieldZone = 'Area 1: Rice & Tomato Block';
  String _farmerName = 'Saptak';
  String _farmerMobile = '';
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
  List<int> get tabHistory => List.unmodifiable(_tabHistory);
  bool get isDarkMode => _isDarkMode;
  bool get isCockpitMode => _isCockpitMode;
  String get activeFieldZone => _activeFieldZone;
  String get farmerName => _farmerName;
  String get farmerMobile => _farmerMobile;
  List<FarmNotification> get notifications => _notifications;
  int get unreadNotificationCount => _notifications.where((n) => !n.isResponded).length;
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
    Future.microtask(() => _deferredInit());
  }

  Future<void> _deferredInit() async {
    await _loadSavedLanguage();
    await _loadFarmerProfile();
    await _loadFarmerLocation();
    await _initServices();
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

    try {
      await _tfliteService.initialize();
    } catch (_) {}

    try {
      await _fusionService.initialize();
    } catch (_) {}

    _ttsService.onPlayingStateChanged = (playing) {
      notifyListeners();
    };

    try {
      await _ttsService.initialize();
    } catch (_) {}

    _bleService.stateStream.listen((state) {
      _bleState = state;
      notifyListeners();
    });

    _bleService.sensorStream.listen((data) {
      // Keep static values when offline or simulated.
      // Values will only automatically update from the live stream when the real ESP32 is connected.
      if (_bleState != BleConnectionState.connected) return;

      _currentSensorData = data;
      if (_lastInference != null) {
        _fusedAdvisory = _fusionService.fuse(
          inference: _lastInference!,
          sensor: _currentSensorData,
        );
      }
      notifyListeners();
    });

    // Start Polling ESP32 Wi-Fi for Sensors only with concurrency guard
    bool isPollingWifi = false;
    _wifiPollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (isPollingWifi) return;
      isPollingWifi = true;
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
      } catch (e) { } finally {
        isPollingWifi = false;
      }
    });

    _bleService.connect();
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

  Future<void> captureFromPhoneCamera() async {
    _isCapturing = true;
    _statusMessage = 'Opening device back camera...';
    notifyListeners();

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo == null) {
        _isCapturing = false;
        _statusMessage = 'Camera capture cancelled';
        notifyListeners();
        return;
      }

      final Uint8List bytes = await photo.readAsBytes();
      _currentLeafBytes = bytes;
      _isCapturing = false;
      _statusMessage = 'Analyzing photo with Edge TFLite...';
      notifyListeners();

      await _processImageBytes(bytes, photo.name.isNotEmpty ? photo.name : 'phone_camera.jpg');
    } catch (e) {
      _isCapturing = false;
      _statusMessage = 'Phone camera error: $e';
      notifyListeners();
    }
  }

  Future<void> pickFromGallery() async {
    _isCapturing = true;
    _statusMessage = 'Opening phone storage...';
    notifyListeners();

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo == null) {
        _isCapturing = false;
        _statusMessage = 'Storage selection cancelled';
        notifyListeners();
        return;
      }

      final Uint8List bytes = await photo.readAsBytes();
      _currentLeafBytes = bytes;
      _isCapturing = false;
      _statusMessage = 'Analyzing photo with Edge TFLite...';
      notifyListeners();

      await _processImageBytes(bytes, photo.name.isNotEmpty ? photo.name : 'storage_leaf.jpg');
    } catch (e) {
      _isCapturing = false;
      _statusMessage = 'Storage upload error: $e';
      notifyListeners();
    }
  }

  Future<void> triggerSafetyNetDemo({String? assetPath}) async {
    _isSafetyNetMode = true;
    _isInferenceRunning = true;
    _statusMessage = 'ðŸ›¡ï¸ Safety Net Active: Loading Local Pitch Asset...';
    notifyListeners();

    try {
      final String path = assetPath ?? AppConstants.demoRiceBlastAsset;
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

    if (_fusedAdvisory != null) {
      await _dbService.saveSensorAndAdvisoryData(
        temperature: _currentSensorData.temperature,
        humidity: _currentSensorData.humidity,
        rainDetected: _currentSensorData.isRaining ? 1 : 0,
        soilMoisture: _currentSensorData.soilMoisture.toDouble(),
        pumpStatus: _isPumpLocked ? 'LOCKED/ON' : 'OFF',
        aiDiagnosis: _parsedDiagnosis?.disease.value ?? 'Healthy',
        advisoryOutput: _fusedAdvisory!.advisory.nameEn,
      );
    }

    if (_fusedAdvisory!.recommendedPumpAction == 'LOCK' && !_isPumpLocked) {
      await _cameraService.setPumpState(true);
      _isPumpLocked = true;
    }

    _isInferenceRunning = false;
    _statusMessage = 'Diagnosis: ${result.topLabel} (${(result.topConfidence * 100).toStringAsFixed(1)}%)';
    notifyListeners();
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


  void respondToNotification(String id, bool accepted) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isResponded = true;
      _notifications.removeAt(index);
      notifyListeners();
    }
  }
  void setTabIndex(int index) {
    if (_activeTabIndex != index) {
      _tabHistory.add(index);
      _activeTabIndex = index;
      notifyListeners();
    }
  }

  bool popTab() {
    if (_tabHistory.length > 1) {
      _tabHistory.removeLast();
      _activeTabIndex = _tabHistory.last;
      notifyListeners();
      return true;
    }
    return false;
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('is_dark_mode', _isDarkMode);
    }).catchError((_) {});
  }

  void setActiveFieldZone(String zone) {
    _activeFieldZone = zone;
    notifyListeners();
  }

  void injectTelemetry({required double temp, required int soil, required int rain, double? humidity}) {
    _currentSensorData = SensorData(
      temperature: temp,
      soilMoisture: soil,
      rain: rain,
      humidity: humidity ?? _currentSensorData.humidity,
    );
    _bleService.injectTelemetry(temp: temp, soil: soil, rain: rain);
    if (_lastInference != null) {
      _fusedAdvisory = _fusionService.fuse(
        inference: _lastInference!,
        sensor: _currentSensorData,
      );
    }
    notifyListeners();
  }

  Future<void> _loadFarmerProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDark = prefs.getBool('is_dark_mode');
      if (savedDark != null) {
        _isDarkMode = savedDark;
        notifyListeners();
      }
      final savedName = prefs.getString('farmer_name');
      if (savedName != null && savedName.trim().isNotEmpty) {
        _farmerName = savedName.trim();
        notifyListeners();
      }
      final savedMobile = prefs.getString('current_username');
      if (savedMobile != null && savedMobile.trim().isNotEmpty) {
        _farmerMobile = savedMobile.trim();
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

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final user = _farmerMobile.isNotEmpty
        ? _farmerMobile
        : (prefs.getString('current_username') ?? 'farmer');

    return await _dbService.changePassword(user, currentPassword, newPassword);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await stopVoiceAdvisory();
    notifyListeners();
  }

  Future<void> runBatchModelDiagnostics() async {
    final List<String> testFiles = [
      '/data/local/tmp/test_leaves/01_tomato_early_blight.jpg',
      '/data/local/tmp/test_leaves/02_rice_brown_spot.jpg',
      '/data/local/tmp/test_leaves/03_tomato_late_blight.jpg',
      '/data/local/tmp/test_leaves/04_potato_early_blight.jpg',
      '/data/local/tmp/test_leaves/05_rice_leaf_blast.jpg',
    ];

    print('====================================================');
    print('STARTING ON-DEVICE ML MODEL COMPREHENSIVE BENCHMARK');
    print('====================================================');

    for (final path in testFiles) {
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final stopwatch = Stopwatch()..start();
        final res = await _tfliteService.runInference(bytes, hintName: path);
        stopwatch.stop();

        print('--> TEST IMAGE: $path');
        print('    File Size: ${bytes.length} bytes');
        print('    Latency: ${stopwatch.elapsedMilliseconds} ms');
        print('    TOP PREDICTION: [${res.topLabel}] with ${(res.topConfidence * 100).toStringAsFixed(2)}% confidence');
        print('    Top 3 Candidates:');
        for (final c in res.topCandidates) {
          print('       - ${c.label}: ${(c.confidence * 100).toStringAsFixed(2)}%');
        }
        print('----------------------------------------------------');
      } else {
        print('Test file not found: $path');
      }
    }
    print('====================================================');
    print('ON-DEVICE ML BENCHMARK COMPLETED');
    print('====================================================');
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

