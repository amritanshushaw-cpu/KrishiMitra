import 'dart:async';
import 'dart:math';
import '../models/sensor_data.dart';

enum BleConnectionState { disconnected, scanning, connecting, connected, simulated }

class BleService {
  final _sensorStreamController = StreamController<SensorData>.broadcast();
  final _stateStreamController = StreamController<BleConnectionState>.broadcast();

  Stream<SensorData> get sensorStream => _sensorStreamController.stream;
  Stream<BleConnectionState> get stateStream => _stateStreamController.stream;

  BleConnectionState _currentState = BleConnectionState.disconnected;
  BleConnectionState get currentState => _currentState;

  SensorData _lastSensorData = SensorData.defaultInitial();
  SensorData get lastSensorData => _lastSensorData;

  Timer? _mockTimer;

  void _updateState(BleConnectionState state) {
    _currentState = state;
    _stateStreamController.add(state);
  }

  Future<void> connect() async {
    startSimulationMode();
  }

  Future<bool> setPumpState(bool lock) async {
    return true;
  }

  void startSimulationMode() {
    _mockTimer?.cancel();
    _updateState(BleConnectionState.simulated);

    final random = Random();
    _mockTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final double temp = 30.0 + random.nextDouble() * 5.0;
      final int soil = 20 + random.nextInt(40);
      final int rain = random.nextDouble() > 0.85 ? 1 : 0;

      final data = SensorData(
        temperature: double.parse(temp.toStringAsFixed(1)),
        soilMoisture: soil,
        rain: rain,
      );
      _lastSensorData = data;
      _sensorStreamController.add(data);
    });
  }

  void injectTelemetry({required double temp, required int soil, required int rain}) {
    final data = SensorData(temperature: temp, soilMoisture: soil, rain: rain);
    _lastSensorData = data;
    _sensorStreamController.add(data);
  }

  Future<void> disconnect() async {
    _mockTimer?.cancel();
    _updateState(BleConnectionState.disconnected);
  }

  void dispose() {
    _mockTimer?.cancel();
    _sensorStreamController.close();
    _stateStreamController.close();
  }
}
