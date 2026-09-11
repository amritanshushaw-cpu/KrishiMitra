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
  final String? overrideReasonHi;
  final String effectiveChemicalTreatmentEn;
  final String effectiveChemicalTreatmentBn;
  final String effectiveChemicalTreatmentHi;
  final String recommendedPumpAction; // 'LOCK', 'UNLOCK', 'KEEP'
  final String ttsScriptBn;
  final String ttsScriptEn;
  final String ttsScriptHi;

  const FusedAdvisoryResult({
    required this.advisory,
    required this.isSprayOverrideActive,
    this.overrideReasonEn,
    this.overrideReasonBn,
    this.overrideReasonHi,
    required this.effectiveChemicalTreatmentEn,
    required this.effectiveChemicalTreatmentBn,
    this.effectiveChemicalTreatmentHi = '',
    required this.recommendedPumpAction,
    required this.ttsScriptBn,
    required this.ttsScriptEn,
    required this.ttsScriptHi,
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
    final String normalized = AppConstants.normalizeModelLabel(label);
    AdvisoryModel? base = _advisoryDb[label] ?? _advisoryDb[normalized];
    if (base == null) {
      for (final entry in _advisoryDb.entries) {
        if (entry.key.toLowerCase() == normalized.toLowerCase() ||
            normalized.toLowerCase().endsWith(entry.key.toLowerCase()) ||
            entry.key.toLowerCase().endsWith(normalized.toLowerCase())) {
          base = entry.value;
          break;
        }
      }
    }

    final AdvisoryModel advisory = base ?? AdvisoryModel(
      label: label,
      nameEn: label.replaceAll('___', ' - ').replaceAll('_', ' '),
      nameBn: 'অজানা রোগ ($label)',
      category: 'General',
      crop: 'General',
      severity: 'Low',
      symptomsEn: 'Symptoms under evaluation.',
      symptomsBn: 'লক্ষণগুলি মূল্যায়ন করা হচ্ছে।',
      organicTreatmentEn: 'Maintain normal organic farm practices.',
      organicTreatmentBn: 'স্বাভাবিক জৈব খামার অনুশীলন বজায় রাখুন।',
      chemicalTreatmentEn: 'No chemical intervention advised.',
      chemicalTreatmentBn: 'রাসায়নিক হস্তক্ষেপের পরামর্শ দেওয়া হচ্ছে না।',
      ttsPromptBn: 'আপনার গাছে অজানা রোগ ধরা পড়েছে।',
      pumpRule: 'NORMAL',
    );

    bool isSprayOverridden = false;
    String? overrideEn;
    String? overrideBn;
    String? overrideHi;
    String effChemEn = advisory.chemicalTreatmentEn;
    String effChemBn = advisory.chemicalTreatmentBn;
    String effChemHi = '';
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
      overrideEn = '🌧️ RAIN OVERRIDE: Active precipitation detected. Chemical spraying is temporarily HALTED to prevent fungicide/pesticide runoff.';
      overrideBn = '🌧️ বৃষ্টির সতর্কতা: সক্রিয় বৃষ্টিপাত শনাক্ত করা হয়েছে। কীটনাশক ধুয়ে যাওয়া রোধ করতে রাসায়নিক স্প্রে করা সাময়িকভাবে বন্ধ করা হয়েছে।';
      overrideHi = '🌧️ बारिश अलर्ट: सक्रिय वर्षा का पता चला है। कीटनाशक के बहने से रोकने के लिए रासायनिक छिड़काव अस्थायी रूप से रोक दिया गया है।';
      effChemEn = '[SUSPENDED DUE TO RAIN] Postpone spray until 24 hours after rain ceases. In the meantime, ensure drainage channels are open.';
      effChemBn = '[বৃষ্টির কারণে স্থগিত] বৃষ্টি থামার ২৪ ঘন্টা পর স্প্রে করুন। এর মধ্যে জল নিষ্কাশন ব্যবস্থা নিশ্চিত করুন।';
      effChemHi = '[बारिश के कारण स्थगित] बारिश रुकने के 24 घंटे बाद स्प्रे करें। इस बीच जल निकासी सुनिश्चित करें।';
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

    // Compile Vernacular Audio Script (Bengali)
    String ttsBn = advisory.ttsPromptBn;
    if (isSprayOverridden) {
      ttsBn = '$ttsBn তবে বর্তমানে বৃষ্টি হওয়ার কারণে যেকোনো রাসায়নিক স্প্রে করা স্থগিত রাখুন।';
    }
    if (pumpAction == 'LOCK') {
      ttsBn = '$ttsBn মাটিতে অতিরিক্ত আর্দ্রতা ও রোগের প্রকোপ কমাতে সেচ বন্ধ রাখার নির্দেশ দেওয়া হচ্ছে।';
    }

    // Compile Vernacular Audio Script (English)
    String ttsEn = 'Diagnosis: ${advisory.nameEn}. Symptoms: ${advisory.symptomsEn} Organic remedy: ${advisory.organicTreatmentEn}';
    if (isSprayOverridden) {
      ttsEn = '$ttsEn Notice: Chemical spray postponed due to rain.';
    }

    // Compile Vernacular Audio Script (Hindi)
    String ttsHi = _hindiPrompts[label] ?? 'फसल की स्थिति: ${advisory.nameEn}। जैविक उपचार और संतुलित पोषण का ध्यान रखें।';
    if (isSprayOverridden) {
      ttsHi = '$ttsHi वर्तमान में बारिश होने के कारण किसी भी रसायन का छिड़काव अभी रोक दें।';
    }
    if (pumpAction == 'LOCK') {
      ttsHi = '$ttsHi मिट्टी में अधिक नमी और फंगल संक्रमण से बचाव के लिए फिलहाल सिंचाई बंद रखें।';
    }

    return FusedAdvisoryResult(
      advisory: advisory,
      isSprayOverrideActive: isSprayOverridden,
      overrideReasonEn: overrideEn,
      overrideReasonBn: overrideBn,
      overrideReasonHi: overrideHi,
      effectiveChemicalTreatmentEn: effChemEn,
      effectiveChemicalTreatmentBn: effChemBn,
      effectiveChemicalTreatmentHi: effChemHi,
      recommendedPumpAction: pumpAction,
      ttsScriptBn: ttsBn,
      ttsScriptEn: ttsEn,
      ttsScriptHi: ttsHi,
    );
  }

  static const Map<String, String> _hindiPrompts = {
    'Disease___Potato_Early_Blight':
        'आपकी आलू की फसल में अगेती झुलसा रोग देखा गया है। पत्तियों पर गहरे भूरे रंग के छल्लेदार धब्बे बन रहे हैं। मैंकोजेब या कॉपर ऑक्सीक्लोराइड का छिड़काव करें।',
    'Disease___Potato_Late_Blight':
        'सावधान! आपकी आलू की फसल में पछेता झुलसा यानी लेट ब्लाइट रोग फैल रहा है। पत्तियों पर काले-भूरे धब्बे आ रहे हैं। तुरंत सिमोक्सानिल या रिडोमिल का छिड़काव करें।',
    'Disease___Rice_Brown_Spot':
        'धान की पत्तियों पर अंडाकार भूरे रंग के धब्बे दिख रहे हैं, जो ब्राउन स्पॉट रोग का लक्षण हैं। मैंकोजेब या कार्बेन्डाजिम का छिड़काव करने की सलाह दी जाती है।',
    'Disease___Rice_Leaf_Blast':
        'चेतावनी! धान की फसल में लीफ ब्लास्ट रोग फैल रहा है। पत्तियों पर नाव के आकार के धब्बे बन रहे हैं। तुरंत ट्राइसाइक्लाजोल फफूंदनाशक का छिड़काव करें।',
    'Disease___Tomato_Early_Blight':
        'टमाटर के पौधों में अगेती झुलसा रोग के लक्षण हैं। निचली पत्तियों पर काले छल्लेदार धब्बे दिखाई दे रहे हैं। मैंकोजेब या कॉपर फफूंदनाशक का प्रयोग करें।',
    'Disease___Tomato_Late_Blight':
        'सतर्क रहें! टमाटर की फसल में लेट ब्लाइट रोग देखा गया है। पत्तियों और तनों पर पानी जैसे काले धब्बे दिख रहे हैं। तुरंत मेटालेक्सिल या क्लोरोथैलोनिल का छिड़काव करें।',
    'Disease___Tomato_Leaf_Mold':
        'टमाटर की पत्तियों की निचली सतह पर जैतून जैसे मखमली फफूंद के धब्बे हैं। खेत में हवा का प्रवाह बढ़ाएं और कॉपर फफूंदनाशक का छिड़काव करें।',
    'Disease___Tomato_Yellow_Leaf_Curl':
        'टमाटर के पौधे पीले और मुड़े हुए हैं, जो सफेद मक्खी द्वारा फैलाए जाने वाले लीफ कर्ल वायरस का संकेत है। सफेद मक्खी नियंत्रण के लिए इमिडाक्लोप्रिड या नीम तेल का छिड़काव करें।',
    'Healthy___Potato':
        'बधाई हो! आपकी आलू की फसल पूरी तरह से स्वस्थ और रोगमुक्त है। किसी रासायनिक छिड़काव की आवश्यकता नहीं है। नियमित देखभाल जारी रखें।',
    'Healthy___Rice':
        'आपकी धान की फसल स्वस्थ और मजबूत है। कोई बीमारी नहीं पाई गई है। समय पर सिंचाई और जैविक पोषण बनाए रखें।',
    'Healthy___Tomato':
        'टमाटर के पौधे पूरी तरह से स्वस्थ और हरे-भरे हैं। किसी रासायनिक उपचार की आवश्यकता नहीं है। संतुलित पानी और जैविक खाद देते रहें।',
    'Nutrient___Nitrogen_Deficiency':
        'फसल में नाइट्रोजन की कमी पाई गई है। पुरानी पत्तियां पीली पड़ रही हैं। यूरिया या वर्मीकम्पोस्ट खाद का संतुलित प्रयोग करें।',
    'Nutrient___Phosphorus_Deficiency':
        'फसल में फास्फोरस की कमी के लक्षण हैं। पत्तियों का रंग असामान्य रूप से गहरा और बैंगनी हो रहा है। डीएपी या सिंगल सुपर फास्फेट का प्रयोग करें।',
    'Nutrient___Potassium_Deficiency':
        'फसल में पोटाश की कमी देखी गई है। पत्तियों के किनारे जले हुए और सूखे दिख रहे हैं। म्यूरेट ऑफ पोटाश या पोटाश उर्वरक का छिड़काव करें।',
    'Pest___Caterpillar':
        'फसल पर इल्लियों का हमला हुआ है, जो पत्तियों को काटकर नुकसान पहुंचा रही हैं। नीम का तेल या एमामेक्टिन बेंजोएट का छिड़काव करें।',
    'Pest___Grasshopper':
        'खेत में टिड्डियों की गतिविधि देखी गई है। फसल की सुरक्षा के लिए नीम आधारित कीटनाशक या क्लोरपायरीफॉस का छिड़काव करें।',
    'Pest___Rice_Stem_Hispa':
        'धान में तना छेदक या हिस्पा कीट का प्रकोप देखा गया है। पत्तियों पर सफेद लकीरें बन रही हैं। फिप्रोनिल या कारटैप हाइड्रोक्लोराइड का छिड़काव करें।',
    'Stage___Flowering_Fruiting':
        'फसल फूल और फल लगने की महत्वपूर्ण अवस्था में है। खेत में नमी का संतुलन बनाए रखें और सूक्ष्म पोषक तत्वों का छिड़काव करें।',
    'Stage___Seedling':
        'पौधे प्रारंभिक अवस्था में हैं। जड़ों को मजबूत बनाने के लिए हल्की सिंचाई और जैविक खाद का ध्यान रखें।',
    'Stage___Vegetative':
        'फसल तेजी से बढ़ने की वानस्पतिक अवस्था में है। पत्तियों और तनों के अच्छे विकास के लिए संतुलित पोषण और सिंचाई दें।',
  };
}
