import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

class WifiCameraService {
  /// Fetches an 800x600 JPEG from ESP32-CAM via SoftAP (http://192.168.4.1/capture)
  Future<Uint8List> captureFromEsp32() async {
    final response = await http
        .get(Uri.parse(AppConstants.esp32CaptureUrl))
        .timeout(AppConstants.cameraTimeout);

    if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
      return response.bodyBytes;
    } else {
      throw Exception('ESP32-CAM returned status ${response.statusCode}');
    }
  }

  /// Safety Net Bypassing: Loads a high-res sample leaf image from bundled local assets
  Future<Uint8List> loadDemoAssetLeaf({String assetPath = AppConstants.demoLateBlightAsset}) async {
    final ByteData byteData = await rootBundle.load(assetPath);
    return byteData.buffer.asUint8List();
  }
}
