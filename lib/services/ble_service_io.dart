import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../core/constants/app_constants.dart';
import '../models/sensor_data.dart';

enum BleConnectionState { disconnected, scanning, connecting, connected, simulated }

class BleService {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _telemetryCharacteristic;
  BluetoothCharacteristic? _pumpCharacteristic;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _charSubscription;

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
    try {
      _updateState(BleConnectionState.scanning);

      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        startSimulationMode();
        return;
      }

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 5),
        withNames: [AppConstants.bleDeviceName],
      );

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult r in results) {
          if (r.device.platformName == AppConstants.bleDeviceName) {
            await FlutterBluePlus.stopScan();
            await _connectToDevice(r.device);
            break;
          }
        }
      });

      Future.delayed(const Duration(seconds: 6), () {
        if (_currentState != BleConnectionState.connected && _currentState != BleConnectionState.simulated) {
          startSimulationMode();
        }
      });
    } catch (e) {
      startSimulationMode();
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    _updateState(BleConnectionState.connecting);
    _connectedDevice = device;

    await device.connect(autoConnect: false);
    final services = await device.discoverServices();

    for (BluetoothService service in services) {
      if (service.uuid.toString().toLowerCase() == AppConstants.bleServiceUuid.toLowerCase()) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.uuid.toString().toLowerCase() == AppConstants.bleTelemetryCharUuid.toLowerCase()) {
            _telemetryCharacteristic = characteristic;
            await characteristic.setNotifyValue(true);
            _charSubscription = characteristic.lastValueStream.listen((value) {
              _onDataReceived(value);
            });
          } else if (characteristic.uuid.toString().toLowerCase() == AppConstants.blePumpCharUuid.toLowerCase()) {
            _pumpCharacteristic = characteristic;
          }
        }
      }
    }

    _updateState(BleConnectionState.connected);
  }

  void _onDataReceived(List<int> rawBytes) {
    try {
      final String jsonString = utf8.decode(rawBytes);
      final sensorData = SensorData.fromJsonString(jsonString);
      _lastSensorData = sensorData;
      _sensorStreamController.add(sensorData);
    } catch (_) {}
  }

  Future<bool> setPumpState(bool lock) async {
    final String command = lock ? AppConstants.pumpLockJson : AppConstants.pumpUnlockJson;
    final List<int> bytes = utf8.encode(command);

    if (_currentState == BleConnectionState.connected && _pumpCharacteristic != null) {
      try {
        await _pumpCharacteristic!.write(bytes, withoutResponse: false);
        return true;
      } catch (e) {
        return false;
      }
    } else {
      return true;
    }
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
    await _scanSubscription?.cancel();
    await _charSubscription?.cancel();
    await _connectedDevice?.disconnect();
    _updateState(BleConnectionState.disconnected);
  }

  void dispose() {
    _mockTimer?.cancel();
    _sensorStreamController.close();
    _stateStreamController.close();
  }
}
