import '../models/advisory_model.dart';
import '../models/sensor_data.dart';
import '../models/parsed_diagnosis.dart';

class AdvisoryEngine {
  // ICAR & FAO Knowledge Base implemented as a local Map for rapid offline access.
  static final Map<String, Map<String, dynamic>> _icarDatabase = {
    'Potato___Late_Blight': {
      'name_en': 'Late Blight (Phytophthora infestans)',
      'name_bn': 'নাবি ধসা রোগ (Late Blight)',
      'category': 'Disease',
      'crop': 'Potato',
      'severity': 'Critical',
      'symptoms_en': 'Water-soaked spots on leaves turning brown/black. White fungal growth on undersides.',
      'organic_treatment_en': 'Copper oxychloride spray. Haulm destruction 10-15 days before harvest.',
      'chemical_treatment_en': 'Prophylactic spray of Mancozeb (0.25%) or systemic sprays like Metalaxyl.',
      'pump_rule': 'HALT',
    },
    'Tomato___Yellow_Leaf_Curl_Virus': {
      'name_en': 'Yellow Leaf Curl (Whitefly Vector)',
      'name_bn': 'পাতা কোঁকড়ানো ভাইরাস (Yellow Leaf Curl)',
      'category': 'Disease/Pest Vector',
      'crop': 'Tomato',
      'severity': 'High',
      'symptoms_en': 'Leaves curl upward, yellow margins, stunted growth.',
      'organic_treatment_en': 'Yellow sticky traps (15-20/acre). Spray Neem oil (10,000 ppm at 2ml/L).',
      'chemical_treatment_en': 'Systemic insecticides for vector control: Imidacloprid (0.3ml/L).',
      'pump_rule': 'NORMAL',
    },
    'Rice___Brown_Spot': {
      'name_en': 'Brown Spot (Bipolaris oryzae)',
      'name_bn': 'বাদামি দাগ রোগ (Brown Spot)',
      'category': 'Disease',
      'crop': 'Rice',
      'severity': 'Medium',
      'symptoms_en': 'Oval to cylindrical brown spots on leaves. Often associated with Nitrogen deficiency.',
      'organic_treatment_en': 'Seed treatment with Pseudomonas fluorescens. Ensure adequate soil nutrition.',
      'chemical_treatment_en': 'Spray Mancozeb (0.2%) or Propiconazole (0.1%).',
      'pump_rule': 'NORMAL',
    }
  };

  /// SENSOR FUSION ENGINE: Combines AI visual output with ESP32 Hardware data
  static AdvisoryModel generateAdvice(ParsedDiagnosis diagnosis, SensorData? sensors) {
    String label = diagnosis.rawLabel;
    
    // 1. Fetch base scientific rules from ICAR database
    Map<String, dynamic>? baseData = _icarDatabase[label];
    
    // If not in our specific DB yet, provide a robust fallback
    baseData ??= {
      'name_en': diagnosis.disease.value,
      'name_bn': diagnosis.disease.bengaliValue,
      'category': 'Unknown',
      'crop': diagnosis.crop.value,
      'severity': 'Monitor',
    };

    AdvisoryModel model = AdvisoryModel.fromJson(label, baseData);

    // 2. APPLY SENSOR FUSION RULES (Environmental Triggers)
    if (sensors != null) {
      if (label == 'Potato___Late_Blight' && sensors.humidity > 85.0 && sensors.temperature >= 10 && sensors.temperature <= 22) {
        // ICAR Rule: High humidity and cool temps accelerate late blight perfectly
        return AdvisoryModel(
          label: model.label,
          nameEn: model.nameEn,
          nameBn: model.nameBn,
          category: model.category,
          crop: model.crop,
          severity: 'CRITICAL OUTBREAK DETECTED (Weather Match)',
          symptomsEn: "\\n\n[SENSOR ALERT]: Current weather (\°C, \% RH) is highly conducive to rapid spread!",
          symptomsBn: model.symptomsBn,
          organicTreatmentEn: model.organicTreatmentEn,
          organicTreatmentBn: model.organicTreatmentBn,
          chemicalTreatmentEn: "\ URGENT: Apply immediately due to high humidity.",
          chemicalTreatmentBn: model.chemicalTreatmentBn,
          ttsPromptBn: model.ttsPromptBn,
          pumpRule: 'HALT', // Do not spray water if humidity is already 90%
        );
      }
      
      if (label == 'Tomato___Yellow_Leaf_Curl_Virus' && sensors.humidity < 60 && sensors.temperature > 25) {
         // FAO Rule: Whiteflies thrive in dry, hot conditions
         return AdvisoryModel(
          label: model.label,
          nameEn: model.nameEn,
          nameBn: model.nameBn,
          category: model.category,
          crop: model.crop,
          severity: 'HIGH RISK (Whitefly Breeding Condition)',
          symptomsEn: "\\n\n[SENSOR ALERT]: Dry heat (\°C) is accelerating Whitefly breeding.",
          symptomsBn: model.symptomsBn,
          organicTreatmentEn: model.organicTreatmentEn,
          organicTreatmentBn: model.organicTreatmentBn,
          chemicalTreatmentEn: model.chemicalTreatmentEn,
          chemicalTreatmentBn: model.chemicalTreatmentBn,
          ttsPromptBn: model.ttsPromptBn,
          pumpRule: 'NORMAL',
        );
      }
    }

    return model;
  }
}
