import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

class WifiCameraService {
  static const String baseUrl = "http://192.168.4.1";

  /// Fetches an 800x600 JPEG from ESP32-CAM via SoftAP (http://192.168.4.1/capture)
  Future<Uint8List> captureFromEsp32() async {
    final response = await http
        .get(Uri.parse('\/capture'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
      return response.bodyBytes;
    } else {
      throw Exception('ESP32-CAM returned status \');
    }
  }

  /// Fetches the JSON sensor data payload from the hardware
  Future<Map<String, dynamic>?> fetchSensorData() async {
    try {
      final response = await http
          .get(Uri.parse('\/sensors'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body); 
      }
    } catch (e) {
      // Fallback for demo mode if not connected to hardware
    }
    return null;
  }

  /// Safety Net Bypassing: Loads a high-res sample leaf image from bundled local assets
  Future<Uint8List> loadDemoAssetLeaf({String assetPath = AppConstants.demoLateBlightAsset}) async {
    final ByteData byteData = await rootBundle.load(assetPath);
    return byteData.buffer.asUint8List();
  }
}
