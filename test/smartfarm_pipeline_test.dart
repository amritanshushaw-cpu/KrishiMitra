import 'package:flutter_test/flutter_test.dart';
import 'package:smartfarm_app/models/sensor_data.dart';
import 'package:smartfarm_app/models/inference_result.dart';
import 'package:smartfarm_app/models/parsed_diagnosis.dart';
import 'package:smartfarm_app/services/sensor_fusion_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. SensorData Parsing Tests', () {
    test('Correctly parses ESP32 telemetry JSON format {"temp":35.2, "soil":15, "rain":1}', () {
      const String jsonPayload = '{"temp":35.2, "soil":15, "rain":1}';
      final sensor = SensorData.fromJsonString(jsonPayload);

      expect(sensor.temperature, 35.2);
      expect(sensor.soilMoisture, 15);
      expect(sensor.rain, 1);
      expect(sensor.isRaining, true);
      expect(sensor.isSoilCriticallyDry, true);
      expect(sensor.isSoilSaturated, false);
    });

    test('Correctly parses dry soil condition without rain', () {
      const String jsonPayload = '{"temp":28.0, "soil":80, "rain":0}';
      final sensor = SensorData.fromJsonString(jsonPayload);

      expect(sensor.isRaining, false);
      expect(sensor.isSoilCriticallyDry, false);
      expect(sensor.isSoilSaturated, true);
    });
  });

  group('2. 5-Parameter Matrix Parsing Tests', () {
    test('Parses Tomato___Late_Blight into 5 parameters', () {
      const result = InferenceResult(
        topLabel: 'Tomato___Late_Blight',
        topConfidence: 0.95,
        topCandidates: [
          PredictionCandidate(label: 'Tomato___Late_Blight', confidence: 0.95),
          PredictionCandidate(label: 'Stage___Vegetative', confidence: 0.20),
        ],
        isConfident: true,
        inferenceLatency: Duration(milliseconds: 45),
      );

      final parsed = ParsedDiagnosis.fromInference(result);

      // Crop
      expect(parsed.crop.title, 'Crop Identity');
      expect(parsed.crop.value.contains('Tomato'), true);
      expect(parsed.crop.bengaliValue, 'টমেটো');

      // Disease
      expect(parsed.disease.title, 'Pathogen / Disease');
      expect(parsed.disease.value.contains('Late Blight'), true);
      expect(parsed.disease.status, ParameterStatus.critical);

      // Pest
      expect(parsed.pest.value, 'No Infestation');
      expect(parsed.pest.status, ParameterStatus.optimal);

      // Nutrient
      expect(parsed.nutrient.value.contains('Optimal'), true);

      // Growth Stage
      expect(parsed.growthStage.value.contains('Vegetative'), true);
    });

    test('Parses Pest___Aphids correctly', () {
      const result = InferenceResult(
        topLabel: 'Pest___Aphids',
        topConfidence: 0.88,
        topCandidates: [
          PredictionCandidate(label: 'Pest___Aphids', confidence: 0.88),
        ],
        isConfident: true,
        inferenceLatency: Duration(milliseconds: 40),
      );

      final parsed = ParsedDiagnosis.fromInference(result);

      expect(parsed.pest.value, 'Aphids');
      expect(parsed.pest.status, ParameterStatus.critical);
      expect(parsed.pest.bengaliValue.contains('জাব পোকা') || parsed.pest.bengaliValue.contains('Aphids'), true);
      expect(parsed.disease.value, 'None Detected');
    });

    test('Parses Nutrient___Nitrogen_Deficiency correctly', () {
      const result = InferenceResult(
        topLabel: 'Nutrient___Nitrogen_Deficiency',
        topConfidence: 0.92,
        topCandidates: [
          PredictionCandidate(label: 'Nutrient___Nitrogen_Deficiency', confidence: 0.92),
        ],
        isConfident: true,
        inferenceLatency: Duration(milliseconds: 38),
      );

      final parsed = ParsedDiagnosis.fromInference(result);

      expect(parsed.nutrient.value.contains('Nitrogen Deficiency'), true);
      expect(parsed.nutrient.status, ParameterStatus.warning);
      expect(parsed.nutrient.bengaliValue.contains('নাইট্রোজেনের অভাব'), true);
    });
  });

  group('3. Sensor Fusion & ICAR Ruleset Tests', () {
    late SensorFusionService fusionService;

    setUp(() async {
      fusionService = SensorFusionService();
      await fusionService.initialize();
    });

    test('RULE 1: Rain active (rain=1) halts chemical spraying', () {
      const inference = InferenceResult(
        topLabel: 'Tomato___Late_Blight',
        topConfidence: 0.95,
        topCandidates: [
          PredictionCandidate(label: 'Tomato___Late_Blight', confidence: 0.95),
        ],
        isConfident: true,
        inferenceLatency: Duration(milliseconds: 42),
      );

      // Telemetry with active rain
      final sensorWithRain = SensorData(temperature: 27.5, soilMoisture: 50, rain: 1);

      final fused = fusionService.fuse(inference: inference, sensor: sensorWithRain);

      expect(fused.isSprayOverrideActive, true);
      expect(fused.overrideReasonBn!.contains('বৃষ্টির সতর্কতা'), true);
      expect(fused.effectiveChemicalTreatmentBn.contains('বৃষ্টির কারণে স্থগিত'), true);
      expect(fused.ttsScriptBn.contains('বৃষ্টি হওয়ার কারণে'), true);
    });

    test('RULE 1 (Negative): Dry conditions (rain=0) allows standard chemical treatment', () {
      const inference = InferenceResult(
        topLabel: 'Tomato___Late_Blight',
        topConfidence: 0.95,
        topCandidates: [
          PredictionCandidate(label: 'Tomato___Late_Blight', confidence: 0.95),
        ],
        isConfident: true,
        inferenceLatency: Duration(milliseconds: 42),
      );

      // Telemetry without rain
      final sensorDry = SensorData(temperature: 30.0, soilMoisture: 45, rain: 0);

      final fused = fusionService.fuse(inference: inference, sensor: sensorDry);

      expect(fused.isSprayOverrideActive, false);
      expect(fused.overrideReasonBn, isNull);
    });

    test('RULE 2: Fungal blight + saturated soil (>65%) locks water pump', () {
      const inference = InferenceResult(
        topLabel: 'Tomato___Late_Blight',
        topConfidence: 0.95,
        topCandidates: [
          PredictionCandidate(label: 'Tomato___Late_Blight', confidence: 0.95),
        ],
        isConfident: true,
        inferenceLatency: Duration(milliseconds: 42),
      );

      // Saturated soil
      final saturatedSensor = SensorData(temperature: 28.0, soilMoisture: 75, rain: 0);

      final fused = fusionService.fuse(inference: inference, sensor: saturatedSensor);

      expect(fused.recommendedPumpAction, 'LOCK');
      expect(fused.ttsScriptBn.contains('সেচ বন্ধ রাখার'), true);
    });

    test('RULE 3: Drought condition (<20% soil) recommends unlocking pump', () {
      const inference = InferenceResult(
        topLabel: 'Potato___Healthy',
        topConfidence: 0.90,
        topCandidates: [
          PredictionCandidate(label: 'Potato___Healthy', confidence: 0.90),
        ],
        isConfident: true,
        inferenceLatency: Duration(milliseconds: 35),
      );

      final droughtSensor = SensorData(temperature: 36.0, soilMoisture: 12, rain: 0);

      final fused = fusionService.fuse(inference: inference, sensor: droughtSensor);

      expect(fused.recommendedPumpAction, 'UNLOCK');
    });
  });
}
