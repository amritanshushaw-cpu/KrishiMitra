import 'package:flutter/material.dart';
import 'inference_result.dart';

enum ParameterStatus { optimal, warning, critical, info }

class ParameterItem {
  final String title;
  final String value;
  final String bengaliValue;
  final ParameterStatus status;
  final IconData icon;

  const ParameterItem({
    required this.title,
    required this.value,
    required this.bengaliValue,
    required this.status,
    required this.icon,
  });
}

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

  /// Parses any unified label from smartfarm_unified.tflite into the 5-Parameter Matrix
  factory ParsedDiagnosis.fromInference(InferenceResult result) {
    final String label = result.topLabel;
    final List<String> parts = label.split('___');

    String cropVal = 'Multi-Crop (Field)';
    String cropBn = 'বহু-ফসল';
    ParameterStatus cropStatus = ParameterStatus.optimal;

    String diseaseVal = 'None Detected';
    String diseaseBn = 'কোন রোগ নেই';
    ParameterStatus diseaseStatus = ParameterStatus.optimal;

    String pestVal = 'No Infestation';
    String pestBn = 'পোকার আক্রমণ নেই';
    ParameterStatus pestStatus = ParameterStatus.optimal;

    String nutrientVal = 'Optimal / Balanced';
    String nutrientBn = 'সুষম পুষ্টি';
    ParameterStatus nutrientStatus = ParameterStatus.optimal;

    String stageVal = 'Vegetative Phase';
    String stageBn = 'বৃদ্ধি পর্যায়';
    ParameterStatus stageStatus = ParameterStatus.info;

    // 1. Check if label starts with Crop (Tomato, Potato, Rice)
    if (label.startsWith('Tomato___')) {
      cropVal = 'Tomato (Solanum lycopersicum)';
      cropBn = 'টমেটো';
      final String condition = parts.length > 1 ? parts[1].replaceAll('_', ' ') : '';
      if (condition.toLowerCase() == 'healthy') {
        diseaseVal = 'Healthy Foliage';
        diseaseBn = 'সুস্থ গাছ';
        diseaseStatus = ParameterStatus.optimal;
      } else {
        diseaseVal = condition;
        diseaseBn = _bengaliDiseaseName(condition);
        diseaseStatus = ParameterStatus.critical;
      }
    } else if (label.startsWith('Potato___')) {
      cropVal = 'Potato (Solanum tuberosum)';
      cropBn = 'আলু';
      final String condition = parts.length > 1 ? parts[1].replaceAll('_', ' ') : '';
      if (condition.toLowerCase() == 'healthy') {
        diseaseVal = 'Healthy Foliage';
        diseaseBn = 'সুস্থ গাছ';
        diseaseStatus = ParameterStatus.optimal;
      } else {
        diseaseVal = condition;
        diseaseBn = _bengaliDiseaseName(condition);
        diseaseStatus = ParameterStatus.critical;
      }
    } else if (label.startsWith('Rice___')) {
      cropVal = 'Paddy Rice (Oryza sativa)';
      cropBn = 'ধান';
      final String condition = parts.length > 1 ? parts[1].replaceAll('_', ' ') : '';
      if (condition.toLowerCase() == 'healthy') {
        diseaseVal = 'Healthy Foliage';
        diseaseBn = 'সুস্থ গাছ';
        diseaseStatus = ParameterStatus.optimal;
      } else {
        diseaseVal = condition;
        diseaseBn = _bengaliDiseaseName(condition);
        diseaseStatus = ParameterStatus.critical;
      }
    }
    // 2. Check if label starts with Pest
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
    // 3. Check if label starts with Nutrient
    else if (label.startsWith('Nutrient___')) {
      final String nutName = parts.length > 1 ? parts[1].replaceAll('_', ' ') : 'Deficiency';
      nutrientVal = nutName;
      nutrientBn = _bengaliNutrientName(nutName);
      nutrientStatus = ParameterStatus.warning;
    }
    // 4. Check if label starts with Stage
    else if (label.startsWith('Stage___')) {
      final String stg = parts.length > 1 ? parts[1].replaceAll('_', ' ') : 'Unknown';
      stageVal = stg;
      stageBn = _bengaliStageName(stg);
      stageStatus = ParameterStatus.info;
    }

    // Inspect secondary candidates to enrich cross-parameter detection
    for (final candidate in result.topCandidates.skip(1)) {
      if (candidate.confidence > 0.15) {
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

    return ParsedDiagnosis(
      rawLabel: label,
      crop: ParameterItem(
        title: 'Crop Identity',
        value: cropVal,
        bengaliValue: cropBn,
        status: cropStatus,
        icon: Icons.grass,
      ),
      disease: ParameterItem(
        title: 'Pathogen / Disease',
        value: diseaseVal,
        bengaliValue: diseaseBn,
        status: diseaseStatus,
        icon: Icons.coronavirus_outlined,
      ),
      pest: ParameterItem(
        title: 'Entomology / Pest',
        value: pestVal,
        bengaliValue: pestBn,
        status: pestStatus,
        icon: Icons.pest_control_outlined,
      ),
      nutrient: ParameterItem(
        title: 'Soil / Nutrient',
        value: nutrientVal,
        bengaliValue: nutrientBn,
        status: nutrientStatus,
        icon: Icons.biotech_outlined,
      ),
      growthStage: ParameterItem(
        title: 'Phenology / Stage',
        value: stageVal,
        bengaliValue: stageBn,
        status: stageStatus,
        icon: Icons.timeline_outlined,
      ),
    );
  }

  static String _bengaliDiseaseName(String en) {
    final lower = en.toLowerCase();
    if (lower.contains('late blight')) return 'নাবি ধসা রোগ (Late Blight)';
    if (lower.contains('early blight')) return 'আগাম ধসা রোগ (Early Blight)';
    if (lower.contains('leaf blast')) return 'ব্লাস্ট রোগ (Leaf Blast)';
    if (lower.contains('brown spot')) return 'বাদামি দাগ রোগ (Brown Spot)';
    if (lower.contains('leaf mold')) return 'পাতার ছত্রাক রোগ (Leaf Mold)';
    if (lower.contains('curl virus')) return 'পাতা কোঁকড়ানো ভাইরাস (Yellow Leaf Curl)';
    return en;
  }

  static String _bengaliPestName(String en) {
    final lower = en.toLowerCase();
    if (lower.contains('aphid')) return 'জাব পোকা (এফিডস)';
    if (lower.contains('stem borer')) return 'মাজরা পোকা (Stem Borer)';
    if (lower.contains('whitefly')) return 'সাদা মাছি (Whitefly)';
    return en;
  }

  static String _bengaliNutrientName(String en) {
    final lower = en.toLowerCase();
    if (lower.contains('nitrogen')) return 'নাইট্রোজেনের অভাব (N)';
    if (lower.contains('phosphorus')) return 'ফসফরাসের অভাব (P)';
    if (lower.contains('potassium')) return 'পটাশিয়ামের অভাব (K)';
    return en;
  }

  static String _bengaliStageName(String en) {
    final lower = en.toLowerCase();
    if (lower.contains('seedling')) return 'চারা পর্যায় (Seedling)';
    if (lower.contains('vegetative')) return 'বৃদ্ধি পর্যায় (Vegetative)';
    if (lower.contains('flowering')) return 'ফুল ও ফল ধারণ পর্যায় (Flowering/Fruiting)';
    return en;
  }
}
