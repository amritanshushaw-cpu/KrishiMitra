class AppConstants {
  // Wi-Fi SoftAP Camera Node
  static const String esp32CameraIp = '192.168.4.1';
  static const String esp32CaptureUrl = 'http://192.168.4.1/capture';
  static const Duration cameraTimeout = Duration(seconds: 4);

  // BLE Service and Characteristic UUIDs (Standard 128-bit custom for SmartFarm ESP32)
  static const String bleDeviceName = 'SmartFarm_ESP32';
  static const String bleServiceUuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const String bleTelemetryCharUuid = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';
  static const String blePumpCharUuid = 'c8b417c8-04f8-4e38-9585-618797f79432';

  // Edge ML Preprocessing Specs
  static const int modelInputSize = 224; // 224x224
  static const double imageMean = 0.0;
  static const double imageStd = 255.0; // rescale = 1.0 / 255.0
  static const double confidenceThreshold = 0.60; // 60%

  // Asset Paths
  static const String labelsAsset = 'assets/data/labels.txt';
  static const String advisoryDbAsset = 'assets/data/advisory_db.json';
  static const String tfliteModelAsset = 'assets/models/smartfarm_unified.tflite';

  // Demo Fallback Leaf Assets (For Hackathon Pitch Resilience)
  static const String demoLateBlightAsset = 'assets/demo/tomato_late_blight.jpg';
  static const String demoHealthyAsset = 'assets/demo/potato_healthy.jpg';
  static const String demoRiceBlastAsset = 'assets/demo/rice_leaf_blast.jpg';

  // Pump Commands (JSON)
  static const String pumpLockJson = '{"pump": "LOCK"}';
  static const String pumpUnlockJson = '{"pump": "UNLOCK"}';
}
