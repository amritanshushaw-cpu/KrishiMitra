import 'dart:convert';

class SensorData {
  final double temperature; // e.g. 35.2 in Celsius
  final int soilMoisture;    // e.g. 15 in %
  final int rain;            // 0 = Dry, 1 = Raining
  final DateTime timestamp;

  SensorData({
    required this.temperature,
    required this.soilMoisture,
    required this.rain,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SensorData.fromJsonString(String jsonStr) {
    try {
      final Map<String, dynamic> map = jsonDecode(jsonStr);
      return SensorData(
        temperature: (map['temp'] as num?)?.toDouble() ?? 0.0,
        soilMoisture: (map['soil'] as num?)?.toInt() ?? 0,
        rain: (map['rain'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      throw FormatException('Invalid sensor telemetry JSON: $jsonStr ($e)');
    }
  }

  bool get isRaining => rain == 1;
  bool get isSoilCriticallyDry => soilMoisture < 25;
  bool get isSoilSaturated => soilMoisture > 75;

  Map<String, dynamic> toJson() => {
    'temp': temperature,
    'soil': soilMoisture,
    'rain': rain,
    'timestamp': timestamp.toIso8601String(),
  };

  static SensorData defaultInitial() {
    return SensorData(temperature: 28.5, soilMoisture: 45, rain: 0);
  }
}
