import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

class WifiCameraService {
  static const String baseUrl = "http://192.168.4.1";

  /// Fetches an 800x600 JPEG from ESP32-CAM via SoftAP
  Future<Uint8List> captureFromEsp32() async {
    final response = await http
        .get(Uri.parse('$baseUrl/snapshot'))
        .timeout(AppConstants.cameraTimeout);

    if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
      return response.bodyBytes;
    } else {
      throw Exception('ESP32-CAM returned status ${response.statusCode}');
    }
  }

  /// Fetches the JSON sensor data payload from the hardware
  Future<Map<String, dynamic>?> fetchSensorData() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body); 
      }
    } catch (e) {
      // Ignore fallback
    }
    return null;
  }
  
  /// Controls the water pump via HTTP
  Future<bool> setPumpState(bool state) async {
    try {
      final String endpoint = state ? '/pump/on' : '/pump/off';
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Safety Net Bypassing: Loads a high-res sample leaf image from bundled local assets
  Future<Uint8List> loadDemoAssetLeaf({String assetPath = AppConstants.demoRiceBlastAsset}) async {
    final ByteData byteData = await rootBundle.load(assetPath);
    return byteData.buffer.asUint8List();
  }
}
