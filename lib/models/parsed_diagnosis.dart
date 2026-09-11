import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import 'inference_result.dart';

enum ParameterStatus { optimal, warning, critical, info }

class ParameterItem {
  final String title;
  final String value;
  final String bengaliValue;
  final String hindiValue;
  final ParameterStatus status;
  final IconData icon;

  const ParameterItem({
    required this.title,
    required this.value,
    required this.bengaliValue,
    this.hindiValue = "",
    required this.status,
    required this.icon,
  });
}

/// Rich 5-Parameter Agronomic Diagnostic Result
class ParsedDiagnosis {
  final String rawLabel;
  final ParameterItem crop;
  final ParameterItem disease;
  final ParameterItem pest;
  final ParameterItem nutrient;
  final ParameterItem growthStage;

  const ParsedDiagnosis({
    required this.rawLabel,
    required this.crop,
    required this.disease,
    required this.pest,
    required this.nutrient,
    required this.growthStage,
  });

  List<ParameterItem> get allParameters => [
    crop,
    disease,
    pest,
    nutrient,
    growthStage,
  ];

  factory ParsedDiagnosis.fromInference(InferenceResult result) {
    final String rawLabel = result.topLabel;
    final String label = AppConstants.normalizeModelLabel(rawLabel);
    final List<String> parts = label.split('___');

    String cropVal = 'Multi-Crop (Field)';
    String cropBn = 'বহু-ফসল ক্ষেত্র';
    ParameterStatus cropStatus = ParameterStatus.optimal;

    String diseaseVal = 'None Detected';
    String diseaseBn = 'কোনো রোগ নেই';
    ParameterStatus diseaseStatus = ParameterStatus.optimal;

    String pestVal = 'No Infestation';
    String pestBn = 'কোনো পোকা নেই';
    ParameterStatus pestStatus = ParameterStatus.optimal;

    String nutrientVal = 'Optimal (N-P-K Balanced)';
    String nutrientBn = 'অনুকূল (N-P-K সুষম)';
    ParameterStatus nutrientStatus = ParameterStatus.optimal;

    String stageVal = 'Vegetative Phase';
    String stageBn = 'বৃদ্ধি পর্যায় (Vegetative)';
    ParameterStatus stageStatus = ParameterStatus.info;

    if (label.startsWith('Tomato___') || label.startsWith('Potato___') || label.startsWith('Rice___')) {
      final String cropName = parts[0];
      final String condition = parts.length > 1 ? parts[1].replaceAll('_', ' ') : 'Healthy';

      if (cropName == 'Tomato') {
        cropVal = 'Tomato (Solanum lycopersicum)';
        cropBn = 'টমেটো';
      } else if (cropName == 'Potato') {
        cropVal = 'Potato (Solanum tuberosum)';
        cropBn = 'আলু';
      } else if (cropName == 'Rice') {
        cropVal = 'Paddy Rice (Oryza sativa)';
        cropBn = 'ধান';
      }

      if (condition.toLowerCase() == 'healthy') {
        diseaseVal = 'Healthy Foliage';
        diseaseBn = 'সুস্থ পাতা';
        diseaseStatus = ParameterStatus.optimal;
      } else {
        diseaseVal = condition;
        diseaseBn = _bengaliDiseaseName(condition);
        diseaseStatus = ParameterStatus.critical;
      }
    }
    else if (label.startsWith('Pest___')) {
      final String pestName = parts.length > 1 ? parts[1].replaceAll('_', ' ') : 'Unknown';
      pestVal = pestName;
      pestBn = _bengaliPestName(pestName);
      pestStatus = ParameterStatus.critical;
      if (pestName.toLowerCase().contains('rice')) {
        cropVal = 'Paddy Rice (Oryza sativa)';
        cropBn = 'ধান';
      }
    }
    else if (label.startsWith('Nutrient___')) {
      final String nutName = parts.length > 1 ? parts[1].replaceAll('_', ' ') : 'Deficiency';
      nutrientVal = nutName;
      nutrientBn = _bengaliNutrientName(nutName);
      nutrientStatus = ParameterStatus.warning;
    }
    else if (label.startsWith('Stage___')) {
      final String stg = parts.length > 1 ? parts[1].replaceAll('_', ' ') : 'Unknown';
      stageVal = stg;
      stageBn = _bengaliStageName(stg);
      stageStatus = ParameterStatus.info;
    }

    // Inspect secondary candidates to enrich cross-parameter detection
    for (final candidate in result.topCandidates.skip(1)) {
      if (candidate.confidence > 0.10) {
        if (candidate.label.startsWith('Stage___') && stageVal == 'Vegetative Phase') {
          final String s = candidate.label.split('___').last.replaceAll('_', ' ');
          stageVal = s;
          stageBn = _bengaliStageName(s);
        } else if (candidate.label.startsWith('Nutrient___') && nutrientStatus == ParameterStatus.optimal) {
          final String n = candidate.label.split('___').last.replaceAll('_', ' ');
          nutrientVal = '$n (Sub-clinical)';
          nutrientBn = '${_bengaliNutrientName(n)} (প্রাথমিক)';
          nutrientStatus = ParameterStatus.warning;
        }
      }
    }

    // Comprehensive scan across all top candidates to resolve crop, disease, and pest
    for (final candidate in result.topCandidates) {
      final String cLabel = AppConstants.normalizeModelLabel(candidate.label);
      final cParts = cLabel.split('___');
      if (cropVal == 'Multi-Crop (Field)') {
        if (cLabel.startsWith('Tomato___')) {
          cropVal = 'Tomato (Solanum lycopersicum)';
          cropBn = 'টমেটো';
        } else if (cLabel.startsWith('Potato___')) {
          cropVal = 'Potato (Solanum tuberosum)';
          cropBn = 'আলু';
        } else if (cLabel.startsWith('Rice___')) {
          cropVal = 'Paddy Rice (Oryza sativa)';
          cropBn = 'ধান';
        }
      }
      if (diseaseStatus == ParameterStatus.optimal && (diseaseVal == 'None Detected' || diseaseVal == 'Healthy Foliage')) {
        if (cLabel.startsWith('Tomato___') || cLabel.startsWith('Potato___') || cLabel.startsWith('Rice___')) {
          final cond = cParts.length > 1 ? cParts[1].replaceAll('_', ' ') : '';
          if (cond.isNotEmpty && cond.toLowerCase() != 'healthy') {
            diseaseVal = cond;
            diseaseBn = _bengaliDiseaseName(cond);
            diseaseStatus = ParameterStatus.critical;
          }
        }
      }
      if (pestStatus == ParameterStatus.optimal && pestVal == 'No Infestation') {
        if (cLabel.startsWith('Pest___')) {
          final pName = cParts.length > 1 ? cParts[1].replaceAll('_', ' ') : 'Unknown';
          pestVal = pName;
          pestBn = _bengaliPestName(pName);
          pestStatus = ParameterStatus.critical;
        }
      }
    }

    return ParsedDiagnosis(
      rawLabel: label,
      crop: ParameterItem(
        title: 'Crop Identity',
        value: cropVal,
        bengaliValue: cropBn,
        hindiValue: _hindiCropName(cropVal),
        status: cropStatus,
        icon: Icons.grass,
      ),
      disease: ParameterItem(
        title: 'Pathogen / Disease',
        value: diseaseVal,
        bengaliValue: diseaseBn,
        hindiValue: _hindiDiseaseName(diseaseVal),
        status: diseaseStatus,
        icon: Icons.coronavirus_outlined,
      ),
      pest: ParameterItem(
        title: 'Entomology / Pest',
        value: pestVal,
        bengaliValue: pestBn,
        hindiValue: _hindiPestName(pestVal),
        status: pestStatus,
        icon: Icons.pest_control_outlined,
      ),
      nutrient: ParameterItem(
        title: 'Soil / Nutrient',
        value: nutrientVal,
        bengaliValue: nutrientBn,
        hindiValue: _hindiNutrientName(nutrientVal),
        status: nutrientStatus,
        icon: Icons.biotech_outlined,
      ),
      growthStage: ParameterItem(
        title: 'Phenology / Stage',
        value: stageVal,
        bengaliValue: stageBn,
        hindiValue: _hindiStageName(stageVal),
        status: stageStatus,
        icon: Icons.timeline_outlined,
      ),
    );
  }

  // ========================================================
  // MASSIVE AGRONOMIC NLP DICTIONARY (BENGALI & HINDI)
  // ========================================================
  static String _hindiCropName(String en) {
    final lower = en.toLowerCase();
    if (lower.contains('tomato')) return 'टमाटर';
    if (lower.contains('potato')) return 'आलू';
    if (lower.contains('rice') || lower.contains('paddy')) return 'धान';
    return 'बहु-फसल खेत';
  }

  static String _bengaliDiseaseName(String en) {
    final lower = en.toLowerCase();
    if (lower.contains('late blight')) return 'নাবি ধসা (Late Blight)';
    if (lower.contains('early blight')) return 'আগাম ধসা (Early Blight)';
    if (lower.contains('leaf blast')) return 'পাতা ঝলসানো / ব্লাস্ট (Leaf Blast)';
    if (lower.contains('brown spot')) return 'বাদামি দাগ (Brown Spot)';
    if (lower.contains('leaf mold')) return 'পাতা পচা (Leaf Mold)';
    if (lower.contains('curl')) return 'পাতা কোঁকড়ানো (Yellow Leaf Curl)';
    if (lower.contains('mosaic')) return 'মোজাইক ভাইরাস (Mosaic Virus)';
    if (lower.contains('bacterial blight')) return 'ব্যাকটেরিয়াজনিত পাতা পোড়া (Bacterial Blight)';
    if (lower.contains('hispa')) return 'পামরি পোকা (Stem Hispa)';
    return en;
  }

  static String _hindiDiseaseName(String en) {
    final lower = en.toLowerCase();
    if (lower.contains('late blight')) return 'पछेती झुलसा (Late Blight)';
    if (lower.contains('early blight')) return 'अगेती झुलसा (Early Blight)';
    if (lower.contains('leaf blast')) return 'पत्ती झुलसा (Leaf Blast)';
    if (lower.contains('brown spot')) return 'भूरा धब्बा (Brown Spot)';
    if (lower.contains('leaf mold')) return 'पत्ती फफूंदी (Leaf Mold)';
    if (lower.contains('curl')) return 'पत्ती मरोड़ (Leaf Curl)';
    if (lower.contains('mosaic')) return 'मोज़ेक वायरस (Mosaic)';
    if (lower.contains('bacterial blight')) return 'जीवाणु झुलसा (Bacterial Blight)';
    if (lower.contains('hispa')) return 'हिसपा कीट (Hispa)';
    return en;
  }

  static String _bengaliPestName(String en) {
    final lower = en.toLowerCase();
    if (lower.contains('aphid')) return 'জাব পোকা (Aphids)';
    if (lower.contains('stem borer')) return 'মাজরা পোকা (Stem Borer)';
    if (lower.contains('whitefly')) return 'সাদা মাছি (Whitefly)';
    if (lower.contains('caterpillar')) return 'লেদা পোকা (Caterpillar)';
    if (lower.contains('grasshopper')) return 'ঘাসফড়িং (Grasshopper)';
    return en;
  }

  static String _hindiPestName(String en) {
    final lower = en.toLowerCase();
    if (lower.contains('aphid')) return 'माहू या चेपा (Aphid)';
    if (lower.contains('stem borer')) return 'तना छेदक (Stem Borer)';
    if (lower.contains('whitefly')) return 'सफेद मक्खी (Whitefly)';
    if (lower.contains('caterpillar')) return 'इल्ली (Caterpillar)';
    if (lower.contains('grasshopper')) return 'टिड्डा (Grasshopper)';
    return en;
  }

  static String _bengaliNutrientName(String en) {
    final lower = en.toLowerCase();
    if (lower.contains('nitrogen')) return 'নাইট্রোজেনের অভাব (N)';
    if (lower.contains('phosphorus')) return 'ফসফরাসের অভাব (P)';
    if (lower.contains('potassium')) return 'পটাশিয়ামের অভাব (K)';
    if (lower.contains('zinc')) return 'দস্তার অভাব (Zn)';
    if (lower.contains('calcium')) return 'ক্যালসিয়ামের অভাব (Ca)';
    return en;
  }

  static String _hindiNutrientName(String en) {
    final lower = en.toLowerCase();
    if (lower.contains('nitrogen')) return 'नाइट्रोजन की कमी (N)';
    if (lower.contains('phosphorus')) return 'फास्फोरस की कमी (P)';
    if (lower.contains('potassium')) return 'पोटाश की कमी (K)';
    if (lower.contains('zinc')) return 'जिंक की कमी (Zn)';
    if (lower.contains('calcium')) return 'कैल्शियम की कमी (Ca)';
    return en;
  }

  static String _bengaliStageName(String en) {
    final lower = en.toLowerCase();
    if (lower.contains('seedling')) return 'চারা অবস্থা (Seedling)';
    if (lower.contains('vegetative')) return 'বৃদ্ধি পর্যায় (Vegetative)';
    if (lower.contains('flowering')) return 'ফুল আসা পর্যায় (Flowering)';
    if (lower.contains('maturity')) return 'পরিপক্বতা (Maturity)';
    return en;
  }

  static String _hindiStageName(String en) {
    final lower = en.toLowerCase();
    if (lower.contains('seedling')) return 'पौध अवस्था (Seedling)';
    if (lower.contains('vegetative')) return 'वानस्पतिक अवस्था (Vegetative)';
    if (lower.contains('flowering')) return 'पुष्पन अवस्था (Flowering)';
    if (lower.contains('maturity')) return 'परिपक्वता (Maturity)';
    return en;
  }
}
