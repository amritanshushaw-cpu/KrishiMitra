class AdvisoryModel {
  final String label;
  final String nameEn;
  final String nameBn;
  final String category;
  final String crop;
  final String severity;
  final String symptomsEn;
  final String symptomsBn;
  final String organicTreatmentEn;
  final String organicTreatmentBn;
  final String chemicalTreatmentEn;
  final String chemicalTreatmentBn;
  final String ttsPromptBn;
  final String pumpRule; // e.g., 'HALT', 'NORMAL', 'RESUME'

  const AdvisoryModel({
    required this.label,
    required this.nameEn,
    required this.nameBn,
    required this.category,
    required this.crop,
    required this.severity,
    required this.symptomsEn,
    required this.symptomsBn,
    required this.organicTreatmentEn,
    required this.organicTreatmentBn,
    required this.chemicalTreatmentEn,
    required this.chemicalTreatmentBn,
    required this.ttsPromptBn,
    this.pumpRule = 'NORMAL',
  });

  factory AdvisoryModel.fromJson(String label, Map<String, dynamic> json) {
    return AdvisoryModel(
      label: label,
      nameEn: json['name_en'] as String? ?? label,
      nameBn: json['name_bn'] as String? ?? label,
      category: json['category'] as String? ?? 'General',
      crop: json['crop'] as String? ?? 'Multi-crop',
      severity: json['severity'] as String? ?? 'Low',
      symptomsEn: json['symptoms_en'] as String? ?? 'No specific symptoms recorded.',
      symptomsBn: json['symptoms_bn'] as String? ?? 'কোন নির্দিষ্ট লক্ষণ পাওয়া যায়নি।',
      organicTreatmentEn: json['organic_treatment_en'] as String? ?? 'Maintain general plant hygiene and organic compost balance.',
      organicTreatmentBn: json['organic_treatment_bn'] as String? ?? 'নিয়মিত জৈব সার প্রয়োগ ও পরিষ্কার পরিচ্ছন্নতা বজায় রাখুন।',
      chemicalTreatmentEn: json['chemical_treatment_en'] as String? ?? 'Consult a certified local agronomist before chemical intervention.',
      chemicalTreatmentBn: json['chemical_treatment_bn'] as String? ?? 'প্রয়োজনে স্থানীয় কৃষি কর্মকর্তার পরামর্শ নিন।',
      ttsPromptBn: json['tts_prompt_bn'] as String? ?? json['name_bn'] as String? ?? '',
      pumpRule: json['pump_rule'] as String? ?? (json['category'] == 'disease' ? 'HALT' : 'NORMAL'),
    );
  }
}
