import 'dart:convert';
import 'package:flutter/services.dart';
import '../core/constants/app_constants.dart';
import '../models/advisory_model.dart';
import '../models/inference_result.dart';
import '../models/sensor_data.dart';

class FusedAdvisoryResult {
  final AdvisoryModel advisory;
  final bool isSprayOverrideActive;
  final String? overrideReasonEn;
  final String? overrideReasonBn;
  final String effectiveChemicalTreatmentEn;
  final String effectiveChemicalTreatmentBn;
  final String recommendedPumpAction; // 'LOCK', 'UNLOCK', 'KEEP'
  final String ttsScriptBn;
  final String ttsScriptEn;

  const FusedAdvisoryResult({
    required this.advisory,
    required this.isSprayOverrideActive,
    this.overrideReasonEn,
    this.overrideReasonBn,
    required this.effectiveChemicalTreatmentEn,
    required this.effectiveChemicalTreatmentBn,
    required this.recommendedPumpAction,
    required this.ttsScriptBn,
    required this.ttsScriptEn,
  });
}

class SensorFusionService {
  Map<String, AdvisoryModel> _advisoryDb = {};
  bool _isDbLoaded = false;

  bool get isDbLoaded => _isDbLoaded;

  Future<void> initialize() async {
    try {
      final String jsonString = await rootBundle.loadString(AppConstants.advisoryDbAsset);
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      final Map<String, dynamic> advisoriesMap = decoded['advisories'] as Map<String, dynamic>? ?? {};

      _advisoryDb = advisoriesMap.map((key, value) {
        return MapEntry(key, AdvisoryModel.fromJson(key, value as Map<String, dynamic>));
      });
      _isDbLoaded = true;
    } catch (e) {
      _advisoryDb = {};
      _isDbLoaded = false;
    }
  }

  /// Core Deterministic Sensor-Fusion Engine (ICAR / FAO Guidelines)
  FusedAdvisoryResult fuse({
    required InferenceResult inference,
    required SensorData sensor,
  }) {
    final String label = inference.topLabel;
    final AdvisoryModel? base = _advisoryDb[label];

    final AdvisoryModel advisory = base ?? AdvisoryModel(
      label: label,
      nameEn: label.replaceAll('___', ' - ').replaceAll('_', ' '),
      nameBn: 'অজ্ঞাত অবস্থা ($label)',
      category: 'General',
      crop: 'General',
      severity: 'Low',
      symptomsEn: 'Symptoms under evaluation.',
      symptomsBn: 'লক্ষণ বিশ্লেষণ করা হচ্ছে।',
      organicTreatmentEn: 'Maintain normal organic farm practices.',
      organicTreatmentBn: 'সাধারণ জৈব পদ্ধতি বজায় রাখুন।',
      chemicalTreatmentEn: 'No chemical intervention advised.',
      chemicalTreatmentBn: 'রাসায়নিক ব্যবহারের প্রয়োজন নেই।',
      ttsPromptBn: 'ফসলের বর্তমান অবস্থা নিরীক্ষণ করা হচ্ছে।',
      pumpRule: 'NORMAL',
    );

    bool isSprayOverridden = false;
    String? overrideEn;
    String? overrideBn;
    String effChemEn = advisory.chemicalTreatmentEn;
    String effChemBn = advisory.chemicalTreatmentBn;
    String pumpAction = 'KEEP';

    final bool isDiseaseOrPest = advisory.category.toLowerCase() == 'disease' ||
        advisory.category.toLowerCase() == 'pest' ||
        label.contains('Blight') ||
        label.contains('Blast') ||
        label.contains('Aphids') ||
        label.contains('Whitefly') ||
        label.contains('Borer');

    // RULE 1: Rain vs Chemical Spray Override
    // Rain washes away foliar contact chemicals, wasting inputs & polluting runoff
    if (sensor.isRaining && isDiseaseOrPest) {
      isSprayOverridden = true;
      overrideEn = '⚠️ RAIN OVERRIDE: Active precipitation detected. Chemical spraying is temporarily HALTED to prevent fungicide/pesticide runoff.';
      overrideBn = '⚠️ বৃষ্টির সতর্কতা: বর্তমানে বৃষ্টি হচ্ছে। কীটনাশক বা ছত্রাকনাশক স্প্রে করা স্থগিত রাখুন, অন্যথায় বৃষ্টির জলে তা ধুয়ে নষ্ট হয়ে যাবে।';
      effChemEn = '[SUSPENDED DUE TO RAIN] Postpone spray until 24 hours after rain ceases. In the meantime, ensure drainage channels are open.';
      effChemBn = '[বৃষ্টির কারণে স্থগিত] বৃষ্টি থামার পর রোদ ওঠা পর্যন্ত অপেক্ষা করুন। আপাতত জমির জল নিষ্কাশন ব্যবস্থা সচল রাখুন।';
    }

    // RULE 2: Soil Moisture vs Disease / Pump Interlock
    // High soil saturation (>70%) with fungal blight exacerbates root rot & spore release -> HALT pump
    if (label.contains('Late_Blight') || label.contains('Early_Blight') || label.contains('Blast')) {
      if (sensor.soilMoisture > 65) {
        pumpAction = 'LOCK'; // HALT pump
      }
    } else if (sensor.soilMoisture < 20) {
      // RULE 3: Severe drought conditions -> recommend unlocking pump
      pumpAction = 'UNLOCK';
    }

    // Compile Vernacular Audio Script
    String ttsBn = advisory.ttsPromptBn;
    if (isSprayOverridden) {
      ttsBn = '$ttsBn তবে বর্তমানে বৃষ্টি হওয়ার কারণে যেকোনো রাসায়নিক স্প্রে করা স্থগিত রাখুন।';
    }
    if (pumpAction == 'LOCK') {
      ttsBn = '$ttsBn মাটিতে অতিরিক্ত আর্দ্রতা ও রোগের প্রকোপ কমাতে সেচ বন্ধ রাখার নির্দেশ দেওয়া হচ্ছে।';
    }

    String ttsEn = 'Diagnosis: ${advisory.nameEn}. Symptoms: ${advisory.symptomsEn} Organic remedy: ${advisory.organicTreatmentEn}';
    if (isSprayOverridden) {
      ttsEn = '$ttsEn Notice: Chemical spray postponed due to rain.';
    }

    return FusedAdvisoryResult(
      advisory: advisory,
      isSprayOverrideActive: isSprayOverridden,
      overrideReasonEn: overrideEn,
      overrideReasonBn: overrideBn,
      effectiveChemicalTreatmentEn: effChemEn,
      effectiveChemicalTreatmentBn: effChemBn,
      recommendedPumpAction: pumpAction,
      ttsScriptBn: ttsBn,
      ttsScriptEn: ttsEn,
    );
  }
}
