import 'dart:convert';

class SensorData {
  final double temperature; // e.g. 35.2 in Celsius
  final int soilMoisture;    // e.g. 15 in %
  final int rain;            // 0 = Dry, 1 = Raining
  final double humidity;     // e.g. 65.0 in %
  final DateTime timestamp;

  SensorData({
    required this.temperature,
    required this.soilMoisture,
    required this.rain,
    double? humidity,
    DateTime? timestamp,
  }) : humidity = humidity ?? 65.0,
       timestamp = timestamp ?? DateTime.now();

  factory SensorData.fromJsonString(String jsonStr) {
    try {
      final Map<String, dynamic> map = jsonDecode(jsonStr);
      return SensorData(
        temperature: (map['temp'] as num?)?.toDouble() ?? 0.0,
        soilMoisture: (map['soil'] as num?)?.toInt() ?? 0,
        rain: (map['rain'] as num?)?.toInt() ?? 0,
        humidity: (map['humidity'] as num?)?.toDouble() ??
            (map['hum'] as num?)?.toDouble() ??
            65.0,
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
    'humidity': humidity,
    'timestamp': timestamp.toIso8601String(),
  };

  static SensorData defaultInitial() {
    return SensorData(temperature: 28.5, soilMoisture: 45, rain: 0);
  }
}
