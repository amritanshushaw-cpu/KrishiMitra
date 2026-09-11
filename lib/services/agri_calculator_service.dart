/// AgriCalculatorService
/// Deterministic agronomic and economic calculations based on ICAR / FAO guidelines.
import '../core/constants/app_constants.dart';

enum CropType {
  paddy('Paddy (Rice)', 'ধান', 40.0, 20.0, 20.0, 22.0, 2183.0),
  tomato('Tomato', 'টমেটো', 60.0, 40.0, 40.0, 150.0, 1600.0),
  potato('Potato', 'আলু', 72.0, 40.0, 48.0, 100.0, 1250.0),
  wheat('Wheat', 'গম', 48.0, 24.0, 16.0, 18.0, 2275.0),
  maize('Maize (Corn)', 'ভুট্টা', 48.0, 24.0, 20.0, 28.0, 2090.0);

  final String nameEn;
  final String nameBn;
  final double defaultN; // kg/acre
  final double defaultP; // kg/acre
  final double defaultK; // kg/acre
  final double typicalYieldQuintalsPerAcre;
  final double defaultMspPricePerQuintal;

  const CropType(
    this.nameEn,
    this.nameBn,
    this.defaultN,
    this.defaultP,
    this.defaultK,
    this.typicalYieldQuintalsPerAcre,
    this.defaultMspPricePerQuintal,
  );
}

enum LandUnit {
  acre('Acre', 1.0),
  bigha('Bigha', 0.3306); // 1 Bigha ≈ 0.3306 Acre in Eastern India (3.025 Bigha/Acre)

  final String label;
  final double toAcreMultiplier;

  const LandUnit(this.label, this.toAcreMultiplier);
}

enum FertilizerCombination {
  ureaDapMop('Urea + DAP + MOP', 'Standard Indian Market Formulation'),
  ureaSspMop('Urea + Single Super Phosphate (SSP) + MOP', 'Sulfur-Rich Formulation');

  final String label;
  final String description;

  const FertilizerCombination(this.label, this.description);
}

class FertilizerCalculationResult {
  final double ureaKg;
  final double ureaBags; // 45kg bag
  final double dapKg;
  final double dapBags; // 50kg bag
  final double sspKg;
  final double sspBags; // 50kg bag
  final double mopKg;
  final double mopBags; // 50kg bag

  final double totalFertilizerKg;
  final double estimatedCostInr;

  // Split application recommendations
  final String basalDoseSummary;
  final String vegetativeDoseSummary;
  final String floweringDoseSummary;

  const FertilizerCalculationResult({
    required this.ureaKg,
    required this.ureaBags,
    required this.dapKg,
    required this.dapBags,
    required this.sspKg,
    required this.sspBags,
    required this.mopKg,
    required this.mopBags,
    required this.totalFertilizerKg,
    required this.estimatedCostInr,
    required this.basalDoseSummary,
    required this.vegetativeDoseSummary,
    required this.floweringDoseSummary,
  });
}

enum SprayPreset {
  lateBlightFungicide(
    'Late Blight / Fungal Leaf Blast',
    'Mancozeb 75% WP',
    '2.0 g / Liter',
    2.0,
    true, // isPowder (grams)
    7, // PHI days
    'Apply thoroughly covering upper and lower leaf surfaces.',
  ),
  suckingPestInsecticide(
    'Aphids & Whiteflies (Sucking Pests)',
    'Imidacloprid 17.8% SL',
    '0.5 ml / Liter',
    0.5,
    false, // isLiquid (ml)
    14,
    'Spray during early morning or dusk to protect beneficial pollinators.',
  ),
  borerCaterpillar(
    'Fruit Borer & Leaf Folders',
    'Chlorantraniliprole 18.5% SC',
    '0.3 ml / Liter',
    0.3,
    false,
    10,
    'Ensure canopy penetration. Do not apply if rain is expected in 3 hours.',
  ),
  bioNeemPreventive(
    'Organic Foliar Neem Oil',
    'Cold-Pressed Neem Oil (10,000 ppm)',
    '3.0 ml / Liter',
    3.0,
    false,
    1,
    'Mix with 1 ml liquid soap per liter as emulsifier. Zero chemical residue.',
  );

  final String targetIssue;
  final String chemicalName;
  final String dosageLabel;
  final double dosePerLiter;
  final bool isPowder;
  final int phiDays;
  final String advisoryNotes;

  const SprayPreset(
    this.targetIssue,
    this.chemicalName,
    this.dosageLabel,
    this.dosePerLiter,
    this.isPowder,
    this.phiDays,
    this.advisoryNotes,
  );
}

class SprayCalculationResult {
  final double totalWaterLiters;
  final int totalTanks;
  final double chemicalPerTank;
  final double totalChemicalRequired;
  final bool isPowder;
  final int phiDays;
  final String safetyAdvisory;

  const SprayCalculationResult({
    required this.totalWaterLiters,
    required this.totalTanks,
    required this.chemicalPerTank,
    required this.totalChemicalRequired,
    required this.isPowder,
    required this.phiDays,
    required this.safetyAdvisory,
  });
}

class FarmEconomicsResult {
  final double totalInputBudget;
  final double totalYieldQuintals;
  final double grossRevenue;
  final double estimatedNetProfit;
  final double noLossPricePerQuintal; // Break-even selling price
  final double breakEvenYieldQuintals; // Break-even yield needed
  final double returnOnInvestmentPct;
  final double profitMarginPct;
  final bool isProfitable;

  const FarmEconomicsResult({
    required this.totalInputBudget,
    required this.totalYieldQuintals,
    required this.grossRevenue,
    required this.estimatedNetProfit,
    required this.noLossPricePerQuintal,
    required this.breakEvenYieldQuintals,
    required this.returnOnInvestmentPct,
    required this.profitMarginPct,
    required this.isProfitable,
  });
}

class AgriCalculatorService {
  /// Calculate exact fertilizer requirements
  static FertilizerCalculationResult calculateFertilizer({
    required CropType crop,
    required double area,
    required LandUnit unit,
    required FertilizerCombination combo,
    double? customN,
    double? customP,
    double? customK,
  }) {
    final double areaAcres = area * unit.toAcreMultiplier;
    final double targetN = (customN ?? crop.defaultN) * areaAcres;
    final double targetP = (customP ?? crop.defaultP) * areaAcres;
    final double targetK = (customK ?? crop.defaultK) * areaAcres;

    double ureaKg = 0;
    double dapKg = 0;
    double sspKg = 0;
    double mopKg = 0;

    if (combo == FertilizerCombination.ureaDapMop) {
      // DAP provides 46% P2O5 and 18% N
      // MOP provides 60% K2O
      // Urea provides 46% N
      dapKg = targetP / 0.46;
      final double nFromDap = dapKg * 0.18;
      final double remainingN = (targetN - nFromDap).clamp(0.0, double.infinity);
      ureaKg = remainingN / 0.46;
      mopKg = targetK / 0.60;
    } else {
      // Single Super Phosphate (SSP) provides 16% P2O5 and 0% N
      sspKg = targetP / 0.16;
      ureaKg = targetN / 0.46;
      mopKg = targetK / 0.60;
    }

    final double ureaBags = ureaKg / 45.0; // 45kg bag standard
    final double dapBags = dapKg / 50.0; // 50kg bag standard
    final double sspBags = sspKg / 50.0;
    final double mopBags = mopKg / 50.0; // 50kg bag standard

    final double totalKg = ureaKg + dapKg + sspKg + mopKg;

    // Subsidized market rate approx: Urea ~₹267/bag, DAP ~₹1350/bag, MOP ~₹1700/bag, SSP ~₹450/bag
    double cost = (ureaBags * 267.0) + (dapBags * 1350.0) + (sspBags * 450.0) + (mopBags * 1700.0);

    // Split Schedules
    final basalUrea = (ureaKg * 0.50).toStringAsFixed(1);
    final basalDap = dapKg > 0 ? '${dapKg.toStringAsFixed(1)} kg DAP + ' : '';
    final basalSsp = sspKg > 0 ? '${sspKg.toStringAsFixed(1)} kg SSP + ' : '';
    final basalMop = (mopKg * 0.50).toStringAsFixed(1);

    final vegUrea = (ureaKg * 0.25).toStringAsFixed(1);
    final flowerUrea = (ureaKg * 0.25).toStringAsFixed(1);
    final flowerMop = (mopKg * 0.50).toStringAsFixed(1);

    return FertilizerCalculationResult(
      ureaKg: ureaKg,
      ureaBags: ureaBags,
      dapKg: dapKg,
      dapBags: dapBags,
      sspKg: sspKg,
      sspBags: sspBags,
      mopKg: mopKg,
      mopBags: mopBags,
      totalFertilizerKg: totalKg,
      estimatedCostInr: cost,
      basalDoseSummary: '$basalDap$basalSsp$basalUrea kg Urea, $basalMop kg MOP',
      vegetativeDoseSummary: '$vegUrea kg Urea (Active Tillering / Branching)',
      floweringDoseSummary: '$flowerUrea kg Urea + $flowerMop kg MOP (Panicle / Bloom)',
    );
  }

  /// Calculate pesticide / foliar spray requirements
  static SprayCalculationResult calculateSpray({
    required double area,
    required LandUnit unit,
    required SprayPreset preset,
    required double tankCapacityLiters,
    double waterVolumeLitersPerAcre = 160.0,
  }) {
    final double areaAcres = area * unit.toAcreMultiplier;
    final double totalWaterLiters = areaAcres * waterVolumeLitersPerAcre;
    final int totalTanks = (totalWaterLiters / tankCapacityLiters).ceil().clamp(1, 999);
    final double chemicalPerTank = preset.dosePerLiter * tankCapacityLiters;
    final double totalChemical = totalWaterLiters * preset.dosePerLiter;

    return SprayCalculationResult(
      totalWaterLiters: totalWaterLiters,
      totalTanks: totalTanks,
      chemicalPerTank: chemicalPerTank,
      totalChemicalRequired: totalChemical,
      isPowder: preset.isPowder,
      phiDays: preset.phiDays,
      safetyAdvisory: preset.advisoryNotes,
    );
  }

  /// Calculate farming economics, break-even price & yield
  static FarmEconomicsResult calculateEconomics({
    required double area,
    required LandUnit unit,
    required double expectedYieldPerUnit,
    required double marketPricePerQuintal,
    required double seedsCost,
    required double tillageCost,
    required double fertilizerCost,
    required double pesticideCost,
    required double irrigationCost,
    required double laborHarvestCost,
  }) {
    final double areaAcres = area * unit.toAcreMultiplier;
    final double totalInputBudget = seedsCost +
        tillageCost +
        fertilizerCost +
        pesticideCost +
        irrigationCost +
        laborHarvestCost;

    final double totalYieldQuintals = expectedYieldPerUnit * (unit == LandUnit.acre ? area : areaAcres);
    final double grossRevenue = totalYieldQuintals * marketPricePerQuintal;
    final double estimatedNetProfit = grossRevenue - totalInputBudget;

    // Break-even (no-loss) calculations
    final double noLossPrice = totalYieldQuintals > 0
        ? totalInputBudget / totalYieldQuintals
        : 0.0;

    final double breakEvenYield = marketPricePerQuintal > 0
        ? totalInputBudget / marketPricePerQuintal
        : 0.0;

    final double roiPct = totalInputBudget > 0
        ? (estimatedNetProfit / totalInputBudget) * 100.0
        : 0.0;

    final double profitMargin = grossRevenue > 0
        ? (estimatedNetProfit / grossRevenue) * 100.0
        : 0.0;

    return FarmEconomicsResult(
      totalInputBudget: totalInputBudget,
      totalYieldQuintals: totalYieldQuintals,
      grossRevenue: grossRevenue,
      estimatedNetProfit: estimatedNetProfit,
      noLossPricePerQuintal: noLossPrice,
      breakEvenYieldQuintals: breakEvenYield,
      returnOnInvestmentPct: roiPct,
      profitMarginPct: profitMargin,
      isProfitable: estimatedNetProfit >= 0,
    );
  }

  // =========================================================================
  // RESEARCH-BACKED THERAPEUTIC DISEASE RECOVERY FERTILIZER ENGINE
  // Based on ICAR-CPRI, ICAR-NRRI, IRRI, and FAO Peer-Reviewed Research
  // =========================================================================

  static final Map<String, DiseaseRecoveryRecipe> diseaseRecoveryRecipes = {
    'Potato___Late_Blight': const DiseaseRecoveryRecipe(
      id: 'Potato___Late_Blight',
      crop: CropType.potato,
      diseaseNameEn: 'Potato Late Blight (Phytophthora infestans)',
      diseaseNameBn: 'আলুর নাবী ধসা রোগ',
      researchCitation: 'ICAR-Central Potato Research Institute (CPRI) Bulletin No. 42 & Phytopathology 98(3)',
      cellularMechanism: 'Potassium phosphite translocates systemically via xylem & phloem to arrest oomycete hyphae and trigger phytoalexin synthesis; calcium ions reinforce the pectin middle lamella against fungal polygalacturonase enzymes.',
      farmerActionGuide: 'Apply this curative tank mixture of Potassium Phosphite (or MKP) and Calcium Nitrate to halt late blight progression and protect uninfected leaves. Broadcast Potash to strengthen stem tissues and boost tuber recovery.',
      nitrogenAdvisory: 'CRITICAL: Immediately suspend top-dressing Urea. Excessive vegetative nitrogen causes succulent cell walls with high free amino acids, accelerating rapid zoospore penetration.',
      haltNitrogen: true,
      foliarComponents: [
        NutrientComponent(
          nameEn: 'Potassium Phosphite (or MKP 00:52:34)',
          nameBn: 'পটাশিয়াম ফসফাইট (বা ০:৫২:৩৪)',
          chemicalFormula: 'K₂HPO₃ / KH₂PO₄',
          method: NutrientAppMethod.foliarSpray,
          dosePerLiter: 2.5, // g/L
          doseKgPerAcre: 0.50, // 500g in 200L water
          isLiquid: false,
          role: 'Halts late blight spread and stimulates natural plant defense',
          marketSource: 'Potassium Phosphite 40% SL or Water-Soluble MKP 00:52:34',
        ),
        NutrientComponent(
          nameEn: 'Calcium Nitrate (15.5% N, 18.8% Ca)',
          nameBn: 'ক্যালসিয়াম নাইট্রেট',
          chemicalFormula: 'Ca(NO₃)₂',
          method: NutrientAppMethod.foliarSpray,
          dosePerLiter: 3.0, // g/L
          doseKgPerAcre: 0.60, // 600g in 200L water
          isLiquid: false,
          role: 'Hardens plant cell walls against fungal penetration',
          marketSource: 'Water-Soluble 100% Chelated Calcium Nitrate',
        ),
      ],
      soilComponents: [
        NutrientComponent(
          nameEn: 'Muriate of Potash (MOP 60% K₂O)',
          nameBn: 'মিউরেট অফ পটাশ (এমওপি)',
          chemicalFormula: 'KCl (60% K₂O)',
          method: NutrientAppMethod.soilBroadcast,
          dosePerLiter: 0.0,
          doseKgPerAcre: 12.0, // 12 kg/acre
          isLiquid: false,
          role: 'Vascular bundle thickening & tuber turgor defense',
          marketSource: 'Standard Red/White Potash Fertilizer',
        ),
      ],
      sprayInterval: 'Apply 2 foliar sprays at 7-10 day intervals. Best sprayed early morning after dew dries.',
      practicalInstructions: 'Dissolve Potassium Phosphite/MKP and Calcium Nitrate in clean water (approx. 200L/acre). Avoid mixing with copper fungicides. Combine with registered fungicide (Metalaxyl+Mancozeb) for dual biological-chemical cure.',
    ),

    'Tomato___Late_Blight': const DiseaseRecoveryRecipe(
      id: 'Tomato___Late_Blight',
      crop: CropType.tomato,
      diseaseNameEn: 'Tomato Late Blight (Phytophthora infestans)',
      diseaseNameBn: 'টমেটোর নাবী ধসা রোগ',
      researchCitation: 'ICAR-IIHR Bengaluru & AVRDC Plant Health Technical Manual',
      cellularMechanism: 'Phosphite ions stimulate host Systemic Acquired Resistance (SAR) cascades; combined with calcium and boron to prevent stem canker, petiole necrosis, and fruit rot.',
      farmerActionGuide: 'Spray this curative combo of Potassium Phosphite, Calcium Nitrate, and Boron to stop blight lesions, protect growing tips, and prevent fruit rot. Broadcast Potash to strengthen vine vigor.',
      nitrogenAdvisory: 'STOP high-nitrogen fertilizers. Excess nitrogen expands canopy density, trapping microclimatic humidity and escalating oomycete sporulation.',
      haltNitrogen: true,
      foliarComponents: [
        NutrientComponent(
          nameEn: 'Potassium Phosphite (or MKP 00:52:34)',
          nameBn: 'পটাশিয়াম ফসফাইট (বা ০:৫২:৩৪)',
          chemicalFormula: 'K₂HPO₃ / KH₂PO₄',
          method: NutrientAppMethod.foliarSpray,
          dosePerLiter: 2.5,
          doseKgPerAcre: 0.50,
          isLiquid: false,
          role: 'Arrests fungal blight progression across leaves and stems',
          marketSource: 'Potassium Phosphite 40% SL or Monopotassium Phosphate',
        ),
        NutrientComponent(
          nameEn: 'Calcium Nitrate',
          nameBn: 'ক্যালসিয়াম নাইট্রেট',
          chemicalFormula: 'Ca(NO₃)₂',
          method: NutrientAppMethod.foliarSpray,
          dosePerLiter: 2.5,
          doseKgPerAcre: 0.50,
          isLiquid: false,
          role: 'Builds leaf surface barrier against rot and tissue collapse',
          marketSource: '100% Water Soluble Calcium Nitrate',
        ),
        NutrientComponent(
          nameEn: 'Boron 20% (Disodium Octaborate)',
          nameBn: 'বোরন ২০%',
          chemicalFormula: 'Na₂B₈O₁₃·4H₂O',
          method: NutrientAppMethod.foliarSpray,
          dosePerLiter: 0.5,
          doseKgPerAcre: 0.10,
          isLiquid: false,
          role: 'Protects flower clusters and prevents blossom-end fruit rot',
          marketSource: 'Agricultural Boron 20% Soluble Powder',
        ),
      ],
      soilComponents: [
        NutrientComponent(
          nameEn: 'Muriate of Potash (MOP 60% K₂O)',
          nameBn: 'মিউরেট অফ পটাশ (এমওপি)',
          chemicalFormula: 'KCl (60% K₂O)',
          method: NutrientAppMethod.soilBroadcast,
          dosePerLiter: 0.0,
          doseKgPerAcre: 10.0,
          isLiquid: false,
          role: 'Replenishes systemic potassium reserves and hardens stem tissues',
          marketSource: 'Standard MOP 60% Potash',
        ),
      ],
      sprayInterval: 'Apply 2 foliar sprays at 7-day intervals; ensure full coverage of undersides of leaves.',
      practicalInstructions: 'Spray during morning or late afternoon. Discard severely necrotic foliage before application to minimize spore load. Keep soil moist but avoid waterlogging.',
    ),

    'Potato___Early_Blight': const DiseaseRecoveryRecipe(
      id: 'Potato___Early_Blight',
      crop: CropType.potato,
      diseaseNameEn: 'Potato Early Blight (Alternaria solani)',
      diseaseNameBn: 'আলুর আগাম ধসা রোগ',
      researchCitation: 'ICAR-CPRI Agronomy Series & FAO Plant Protection Paper 176',
      cellularMechanism: 'Alternaria is a necrotrophic pathogen that targets potassium-exhausted, senescing leaves. Supplemental Potassium and Magnesium maintain chlorophyll retention and counter alternaric acid phytotoxins.',
      farmerActionGuide: 'Spray Potassium Nitrate with Magnesium Sulfate to heal dark concentric target spots and restore lush green leaves. Apply Potash at root zone to recover plant strength.',
      nitrogenAdvisory: 'Maintain balanced nitrogen. Do not starve the plant, but avoid high vegetative nitrogen surges; focus on Potassium:Nitrogen balance.',
      haltNitrogen: false,
      foliarComponents: [
        NutrientComponent(
          nameEn: 'Potassium Nitrate (13:0:45)',
          nameBn: 'পটাশিয়াম নাইট্রেট (১৩:০:৪৫)',
          chemicalFormula: 'KNO₃',
          method: NutrientAppMethod.foliarSpray,
          dosePerLiter: 4.0,
          doseKgPerAcre: 0.80,
          isLiquid: false,
          role: 'Halts premature leaf yellowing & replenishes leaf potassium',
          marketSource: '100% Water Soluble Potassium Nitrate (13:0:45)',
        ),
        NutrientComponent(
          nameEn: 'Magnesium Sulfate (Epsom Salt)',
          nameBn: 'ম্যাগনেসিয়াম সালফেট',
          chemicalFormula: 'MgSO₄·7H₂O',
          method: NutrientAppMethod.foliarSpray,
          dosePerLiter: 3.0,
          doseKgPerAcre: 0.60,
          isLiquid: false,
          role: 'Restores leaf greenness and active photosynthesis',
          marketSource: 'Agricultural Grade Magnesium Sulfate 9.6% Mg',
        ),
      ],
      soilComponents: [
        NutrientComponent(
          nameEn: 'Muriate of Potash (MOP)',
          nameBn: 'মিউরেট অফ পটাশ (এমওপি)',
          chemicalFormula: 'KCl',
          method: NutrientAppMethod.soilBroadcast,
          dosePerLiter: 0.0,
          doseKgPerAcre: 8.0,
          isLiquid: false,
          role: 'Supplements plant resistance against fungal toxins',
          marketSource: 'Standard MOP 60%',
        ),
      ],
      sprayInterval: 'Spray at first sign of target spots; repeat once after 10-12 days.',
      practicalInstructions: 'Ensure canopy penetration. Best applied in combination with contact protector Mancozeb 75% WP @ 2g/L.',
    ),

    'Tomato___Early_Blight': const DiseaseRecoveryRecipe(
      id: 'Tomato___Early_Blight',
      crop: CropType.tomato,
      diseaseNameEn: 'Tomato Early Blight (Alternaria solani)',
      diseaseNameBn: 'টমেটোর আগাম ধসা রোগ',
      researchCitation: 'ICAR-IIHR Tomato Disease Management & Journal of Plant Pathology',
      cellularMechanism: 'Potassium boosts structural lignin in stem collars; foliar Magnesium prevents interveinal chlorosis and delays lower leaf senescence.',
      farmerActionGuide: 'Spray Potassium Nitrate and Magnesium Sulfate to halt early blight spots and keep leaves productive. Broadcast Potash to help fruit set and vine vigor.',
      nitrogenAdvisory: 'Avoid nitrogen exhaustion. Apply balanced foliar potassium to sustain fruit sizing while controlling leaf spotting.',
      haltNitrogen: false,
      foliarComponents: [
        NutrientComponent(
          nameEn: 'Potassium Nitrate (13:0:45)',
          nameBn: 'পটাশিয়াম নাইট্রেট (১৩:০:৪৫)',
          chemicalFormula: 'KNO₃',
          method: NutrientAppMethod.foliarSpray,
          dosePerLiter: 3.5,
          doseKgPerAcre: 0.70,
          isLiquid: false,
          role: 'Strengthens leaf margins against fungal necrosis',
          marketSource: 'Water Soluble Multi-K 13:0:45',
        ),
        NutrientComponent(
          nameEn: 'Magnesium Sulfate',
          nameBn: 'ম্যাগনেসিয়াম সালফেট',
          chemicalFormula: 'MgSO₄·7H₂O',
          method: NutrientAppMethod.foliarSpray,
          dosePerLiter: 2.5,
          doseKgPerAcre: 0.50,
          isLiquid: false,
          role: 'Maintains green leaf area and fruit sizing efficiency',
          marketSource: 'Epsom Salt Agricultural Grade',
        ),
      ],
      soilComponents: [
        NutrientComponent(
          nameEn: 'Muriate of Potash (MOP)',
          nameBn: 'মিউরেট অফ পটাশ',
          chemicalFormula: 'KCl',
          method: NutrientAppMethod.soilBroadcast,
          dosePerLiter: 0.0,
          doseKgPerAcre: 8.0,
          isLiquid: false,
          role: 'Prevents potassium exhaustion during active fruit load',
          marketSource: 'Standard Potash Fertilizer',
        ),
      ],
      sprayInterval: 'Apply every 8-10 days after pruning lower affected leaves.',
      practicalInstructions: 'Mulch soil surface to prevent spore splash from soil onto lower foliage.',
    ),

    'Rice___Leaf_Blast': const DiseaseRecoveryRecipe(
      id: 'Rice___Leaf_Blast',
      crop: CropType.paddy,
      diseaseNameEn: 'Rice Leaf Blast (Magnaporthe oryzae)',
      diseaseNameBn: 'ধানের ব্লাস্ট রোগ (লিফ ব্লাস্ট)',
      researchCitation: 'ICAR-National Rice Research Institute (NRRI) Cuttack & IRRI Rice Knowledge Bank',
      cellularMechanism: 'Soluble silicon deposits beneath the leaf cuticle forming a rigid double-layer amorphous silica-cellulose matrix that physically blocks blast appressorium penetration pegs; Potash thickens parenchyma cell walls.',
      farmerActionGuide: 'Spray Soluble Silica and Monopotassium Phosphate (MKP) to build a protective shield on rice leaves that physically blocks blast fungus. Apply Potash to protect the panicle neck.',
      nitrogenAdvisory: 'HALT UREA IMMEDIATELY: High nitrogen is the single largest trigger for blast epidemics by drastically reducing silicified epidermal cell density.',
      haltNitrogen: true,
      foliarComponents: [
        NutrientComponent(
          nameEn: 'Soluble Potassium Silicate (or Foliar Silica)',
          nameBn: 'পটাশিয়াম সিলিকেট (তরল সিলিকা)',
          chemicalFormula: 'K₂SiO₃',
          method: NutrientAppMethod.foliarSpray,
          dosePerLiter: 2.5, // ml/L
          doseKgPerAcre: 0.50, // 500 ml/acre
          isLiquid: true,
          role: 'Creates physical protective shield on leaves blocking blast fungus',
          marketSource: 'Agricultural Grade Liquid Potassium Silicate (20% SiO₂)',
        ),
        NutrientComponent(
          nameEn: 'Monopotassium Phosphate (MKP 00:52:34)',
          nameBn: 'মনোপটাশিয়াম ফসফেট (০:৫২:৩৪)',
          chemicalFormula: 'KH₂PO₄',
          method: NutrientAppMethod.foliarSpray,
          dosePerLiter: 2.0,
          doseKgPerAcre: 0.40,
          isLiquid: false,
          role: 'Strengthens stems & leaf sheaths to stop lesion spread',
          marketSource: '100% Water Soluble MKP (00:52:34)',
        ),
      ],
      soilComponents: [
        NutrientComponent(
          nameEn: 'Muriate of Potash (MOP 60% K₂O)',
          nameBn: 'মিউরেট অফ পটাশ (এমওপি)',
          chemicalFormula: 'KCl (60% K₂O)',
          method: NutrientAppMethod.soilBroadcast,
          dosePerLiter: 0.0,
          doseKgPerAcre: 10.0,
          isLiquid: false,
          role: 'Protects stem and panicle neck against blast collapse',
          marketSource: 'Standard MOP 60%',
        ),
      ],
      sprayInterval: 'Spray immediately at appearance of eye-shaped lesions; repeat at boot leaf stage.',
      practicalInstructions: 'Keep 2-3 inches standing water in field. Do not drain field during blast outbreak. Combine with Tricyclazole 75% WP @ 0.6g/L for immediate curative control.',
    ),

    'Rice___Brown_Spot': const DiseaseRecoveryRecipe(
      id: 'Rice___Brown_Spot',
      crop: CropType.paddy,
      diseaseNameEn: 'Rice Brown Spot (Bipolaris oryzae)',
      diseaseNameBn: 'ধানের বাদামি দাগ রোগ (ব্রাউন স্পট)',
      researchCitation: 'ICAR-NRRI & IRRI Nutrient Disorders and Nutrient Management in Rice',
      cellularMechanism: 'Brown spot is an indicator of chronic potassium, silicon, and zinc starvation in leached soils. Replenishing Zinc and Potassium activates plant superoxide dismutase (SOD) enzymes to detoxify fungal ophiobolin toxins.',
      farmerActionGuide: 'Spray Chelated Zinc with Potassium Nitrate to relieve nutritional stress and heal brown spots. Broadcast Zinc Sulfate and Potash to the soil to strengthen tillers.',
      nitrogenAdvisory: 'Apply light balanced nitrogen with potash; do not under-fertilize as starved plants suffer maximum mortality.',
      haltNitrogen: false,
      foliarComponents: [
        NutrientComponent(
          nameEn: 'Zinc Chelate (EDTA Zn 12%)',
          nameBn: 'চিলেটেড জিংক (১২%)',
          chemicalFormula: 'Zn-EDTA',
          method: NutrientAppMethod.foliarSpray,
          dosePerLiter: 1.0,
          doseKgPerAcre: 0.20,
          isLiquid: false,
          role: 'Revives stressed leaf tissue and neutralizes fungal toxins',
          marketSource: 'Agricultural Chelated Zinc 12% EDTA',
        ),
        NutrientComponent(
          nameEn: 'Potassium Nitrate (13:0:45)',
          nameBn: 'পটাশিয়াম নাইট্রেট (১৩:০:৪৫)',
          chemicalFormula: 'KNO₃',
          method: NutrientAppMethod.foliarSpray,
          dosePerLiter: 3.0,
          doseKgPerAcre: 0.60,
          isLiquid: false,
          role: 'Rapid leaf nutrient absorption to overcome starvation',
          marketSource: '100% Water Soluble 13:0:45',
        ),
      ],
      soilComponents: [
        NutrientComponent(
          nameEn: 'Zinc Sulfate Heptahydrate (21% Zn)',
          nameBn: 'জিংফ সালফেট (২১%)',
          chemicalFormula: 'ZnSO₄·7H₂O',
          method: NutrientAppMethod.soilBroadcast,
          dosePerLiter: 0.0,
          doseKgPerAcre: 5.0,
          isLiquid: false,
          role: 'Root zone micronutrient replenishment for tillering strength',
          marketSource: 'Agricultural Zinc Sulfate 21%',
        ),
        NutrientComponent(
          nameEn: 'Muriate of Potash (MOP 60%)',
          nameBn: 'মিউরেট অফ পটাশ',
          chemicalFormula: 'KCl (60% K₂O)',
          method: NutrientAppMethod.soilBroadcast,
          dosePerLiter: 0.0,
          doseKgPerAcre: 12.0,
          isLiquid: false,
          role: 'Strengthens leaf cells against brown spot lesion enlargement',
          marketSource: 'Standard MOP 60%',
        ),
      ],
      sprayInterval: 'Foliar spray at tillering and panicle initiation; apply soil Zinc and MOP during weeding.',
      practicalInstructions: 'Correct poor soil drainage and incorporate organic compost before next season.',
    ),

    'Tomato___Leaf_Mold': const DiseaseRecoveryRecipe(
      id: 'Tomato___Leaf_Mold',
      crop: CropType.tomato,
      diseaseNameEn: 'Tomato Leaf Mold (Passalora fulva)',
      diseaseNameBn: 'টমেটোর পাতা ছত্রাক রোগ (লিফ মোল্ড)',
      researchCitation: 'ICAR-IIHR Bengaluru Bulletin No. 38 & AVRDC Plant Health Guidelines',
      cellularMechanism: 'High humidity triggers conidiophore sporulation on lower leaf surfaces; Potassium Bicarbonate elevates leaf surface pH to inhibit conidial spore germination, while soluble calcium reinforces mesophyll pectin middle lamella against mycelial invasion.',
      farmerActionGuide: 'Spray Potassium Bicarbonate (or MKP 00:52:34) combined with Calcium Nitrate to suppress mold spores, stop velvety patches on leaf undersides, and harden foliage. Broadcast Potash to maintain plant vigor.',
      nitrogenAdvisory: 'RESTRICT NITROGEN: Excessive nitrogen accelerates dense canopy humidity and creates soft, succulent foliage highly susceptible to rapid fungal mold sporulation.',
      haltNitrogen: true,
      foliarComponents: [
        NutrientComponent(
          nameEn: 'Potassium Bicarbonate (or MKP 00:52:34)',
          nameBn: 'পটাশিয়াম বাইকার্বনেট (বা ০:৫২:৩৪)',
          chemicalFormula: 'KHCO₃ / KH₂PO₄',
          method: NutrientAppMethod.foliarSpray,
          dosePerLiter: 3.0,
          doseKgPerAcre: 0.60,
          isLiquid: false,
          role: 'Elevates surface pH to stop mold spore germination and leaf yellowing',
          marketSource: 'Agricultural Potassium Bicarbonate or Water-Soluble MKP 00:52:34',
        ),
        NutrientComponent(
          nameEn: 'Calcium Nitrate',
          nameBn: 'ক্যালসিয়াম নাইট্রেট',
          chemicalFormula: 'Ca(NO₃)₂',
          method: NutrientAppMethod.foliarSpray,
          dosePerLiter: 2.5,
          doseKgPerAcre: 0.50,
          isLiquid: false,
          role: 'Strengthens leaf cuticle and inner cell walls against mold fungal invasion',
          marketSource: '100% Water-Soluble Calcium Nitrate',
        ),
      ],
      soilComponents: [
        NutrientComponent(
          nameEn: 'Muriate of Potash (MOP 60% K₂O)',
          nameBn: 'মিউরেট অফ পটাশ (এমওপি)',
          chemicalFormula: 'KCl (60% K₂O)',
          method: NutrientAppMethod.soilBroadcast,
          dosePerLiter: 0.0,
          doseKgPerAcre: 10.0,
          isLiquid: false,
          role: 'Replenishes plant potassium reserves for sustained vascular water transport',
          marketSource: 'Standard MOP 60% Potash',
        ),
      ],
      sprayInterval: 'Apply 2 foliar sprays at 7-10 day intervals; thoroughly coat the undersides of leaves where mold velvety growth develops.',
      practicalInstructions: 'Prune lower infected leaves to improve canopy aeration and lower relative humidity. Avoid overhead sprinkler irrigation. Combine with registered fungicide (Difenoconazole 25% EC @ 0.5ml/L) if infection has spread to upper canopy.',
    ),

    'Tomato___Yellow_Leaf_Curl': const DiseaseRecoveryRecipe(
      id: 'Tomato___Yellow_Leaf_Curl',
      crop: CropType.tomato,
      diseaseNameEn: 'Tomato Yellow Leaf Curl (TYLCV Begomovirus)',
      diseaseNameBn: 'টমেটোর পাতা কোঁকড়ানো ভাইরাস (লিফ কার্ল)',
      researchCitation: 'ICAR-IIHR Bengaluru Begomovirus Management Bulletin & AVRDC International Vegetable Virus Protocol; Journal of Plant Nutrition',
      cellularMechanism: 'Viral systemic infection stunts apical meristems and induces severe zinc/boron transport failure; targeted foliar Zinc-EDTA and Boron stimulate plant ribonucleases, restore auxin hormone synthesis in shoot tips, and prevent blossom drop. Soluble MKP supplies phosphorus and potassium energy to sustain fruit set on unaffected lateral branches.',
      farmerActionGuide: 'Spray Chelated Zinc, Boron, and Monopotassium Phosphate (MKP 00:52:34) to relieve viral stunting, prevent flower drop, and stimulate healthy new branch growth. Broadcast Potash to help fruit development while managing whitefly vectors.',
      nitrogenAdvisory: 'Avoid high Urea top-dressing surges; lush succulent shoots attract heavy whitefly populations that spread the virus.',
      haltNitrogen: false,
      foliarComponents: [
        NutrientComponent(
          nameEn: 'Chelated Zinc (EDTA Zn 12%)',
          nameBn: 'চিলেটেড জিংক (১২%)',
          chemicalFormula: 'Zn-EDTA',
          method: NutrientAppMethod.foliarSpray,
          dosePerLiter: 1.0,
          doseKgPerAcre: 0.20,
          isLiquid: false,
          role: 'Activates plant defense enzymes and restores auxin growth in stunted shoot tips',
          marketSource: 'Agricultural Chelated Zinc 12% EDTA',
        ),
        NutrientComponent(
          nameEn: 'Soluble Boron 20% (Disodium Octaborate)',
          nameBn: 'বোরন ২০%',
          chemicalFormula: 'Na₂B₈O₁₃·4H₂O',
          method: NutrientAppMethod.foliarSpray,
          dosePerLiter: 0.5,
          doseKgPerAcre: 0.10,
          isLiquid: false,
          role: 'Prevents blossom drop, preserves flower viability, and promotes fruit set',
          marketSource: 'Agricultural Boron 20% Soluble Powder',
        ),
        NutrientComponent(
          nameEn: 'Monopotassium Phosphate (MKP 00:52:34)',
          nameBn: 'মনোপটাশিয়াম ফসফেট (০:৫২:৩৪)',
          chemicalFormula: 'KH₂PO₄',
          method: NutrientAppMethod.foliarSpray,
          dosePerLiter: 2.5,
          doseKgPerAcre: 0.50,
          isLiquid: false,
          role: 'Supplies vital high-potassium energy to support lateral branches and fruit sizing',
          marketSource: '100% Water-Soluble MKP (00:52:34)',
        ),
      ],
      soilComponents: [
        NutrientComponent(
          nameEn: 'Muriate of Potash (MOP 60% K₂O)',
          nameBn: 'মিউরেট অফ পটাশ (এমওপি)',
          chemicalFormula: 'KCl (60% K₂O)',
          method: NutrientAppMethod.soilBroadcast,
          dosePerLiter: 0.0,
          doseKgPerAcre: 10.0,
          isLiquid: false,
          role: 'Maintains cell turgor pressure and counteracts viral vascular collapse',
          marketSource: 'Standard MOP 60% Potash',
        ),
      ],
      sprayInterval: 'Apply foliar micronutrient-potassium spray every 10-12 days during active growth and flowering.',
      practicalInstructions: 'Uproot and bury severely stunted early-infected plants to remove virus source. Install yellow sticky traps (15-20 per acre) at canopy level to capture whitefly vectors. Apply Neem oil (10,000 ppm) @ 3ml/L or Imidacloprid 17.8% SL @ 0.5ml/L to control vector transmission.',
    ),
  };

  /// Safely resolves any model label, normalized key, or variant to a scientific recovery recipe
  static DiseaseRecoveryRecipe? getRecoveryRecipe(String? idOrLabel) {
    if (idOrLabel == null || idOrLabel.isEmpty) return null;
    if (diseaseRecoveryRecipes.containsKey(idOrLabel)) {
      return diseaseRecoveryRecipes[idOrLabel];
    }
    final normalized = AppConstants.normalizeModelLabel(idOrLabel);
    if (diseaseRecoveryRecipes.containsKey(normalized)) {
      return diseaseRecoveryRecipes[normalized];
    }
    final clean = idOrLabel
        .replaceAll('Disease___', '')
        .replaceAll('_Virus', '');
    if (diseaseRecoveryRecipes.containsKey(clean)) {
      return diseaseRecoveryRecipes[clean];
    }
    for (final entry in diseaseRecoveryRecipes.entries) {
      final entryClean = entry.key.replaceAll('Disease___', '').replaceAll('_Virus', '');
      if (entryClean.toLowerCase() == clean.toLowerCase() ||
          entryClean.toLowerCase() == normalized.toLowerCase()) {
        return entry.value;
      }
    }
    return null;
  }

  /// Calculate exact disease recovery fertilizer requirements
  static RecoveryCalculationResult calculateDiseaseRecovery({
    required DiseaseRecoveryRecipe recipe,
    required double area,
    required LandUnit unit,
    double tankCapacityLiters = 16.0,
    double waterVolumeLitersPerAcre = 200.0,
  }) {
    final double areaAcres = area * unit.toAcreMultiplier;
    final double totalWaterLiters = (areaAcres * waterVolumeLitersPerAcre).clamp(16.0, 10000.0);
    final int totalKnapsackTanks = (totalWaterLiters / tankCapacityLiters).ceil().clamp(1, 999);

    final List<CalculatedNutrientItem> foliarItems = recipe.foliarComponents.map((comp) {
      final double totalAmount = comp.dosePerLiter * totalWaterLiters;
      final double perTankAmount = comp.dosePerLiter * tankCapacityLiters;

      return CalculatedNutrientItem(
        nameEn: comp.nameEn,
        nameBn: comp.nameBn,
        chemicalFormula: comp.chemicalFormula,
        amountTotal: totalAmount,
        amountPerTank: perTankAmount,
        isLiquid: comp.isLiquid,
        role: comp.role,
        marketSource: comp.marketSource,
      );
    }).toList();

    final List<CalculatedSoilItem> soilItems = recipe.soilComponents.map((comp) {
      final double totalKg = comp.doseKgPerAcre * areaAcres;
      return CalculatedSoilItem(
        nameEn: comp.nameEn,
        nameBn: comp.nameBn,
        chemicalFormula: comp.chemicalFormula,
        totalKg: totalKg,
        role: comp.role,
        marketSource: comp.marketSource,
      );
    }).toList();

    return RecoveryCalculationResult(
      recipe: recipe,
      areaAcres: areaAcres,
      totalWaterLiters: totalWaterLiters,
      totalKnapsackTanks: totalKnapsackTanks,
      tankCapacityLiters: tankCapacityLiters,
      foliarItems: foliarItems,
      soilItems: soilItems,
    );
  }
}

// -----------------------------------------------------------------------------
// Data structures for Scientific Disease Recovery Fertilizer Models
// -----------------------------------------------------------------------------

enum NutrientAppMethod {
  foliarSpray,
  soilBroadcast,
}

class NutrientComponent {
  final String nameEn;
  final String nameBn;
  final String chemicalFormula;
  final NutrientAppMethod method;
  final double dosePerLiter; // g/L or ml/L
  final double doseKgPerAcre; // for soil or baseline
  final bool isLiquid; // true = ml, false = grams
  final String role;
  final String marketSource;

  const NutrientComponent({
    required this.nameEn,
    required this.nameBn,
    required this.chemicalFormula,
    required this.method,
    required this.dosePerLiter,
    required this.doseKgPerAcre,
    required this.isLiquid,
    required this.role,
    required this.marketSource,
  });
}

class DiseaseRecoveryRecipe {
  final String id;
  final CropType crop;
  final String diseaseNameEn;
  final String diseaseNameBn;
  final String researchCitation;
  final String cellularMechanism;
  final String farmerActionGuide;
  final String nitrogenAdvisory;
  final bool haltNitrogen;
  final List<NutrientComponent> foliarComponents;
  final List<NutrientComponent> soilComponents;
  final String sprayInterval;
  final String practicalInstructions;

  const DiseaseRecoveryRecipe({
    required this.id,
    required this.crop,
    required this.diseaseNameEn,
    required this.diseaseNameBn,
    required this.researchCitation,
    required this.cellularMechanism,
    required this.farmerActionGuide,
    required this.nitrogenAdvisory,
    required this.haltNitrogen,
    required this.foliarComponents,
    required this.soilComponents,
    required this.sprayInterval,
    required this.practicalInstructions,
  });
}

class CalculatedNutrientItem {
  final String nameEn;
  final String nameBn;
  final String chemicalFormula;
  final double amountTotal; // grams or ml
  final double amountPerTank; // grams or ml
  final bool isLiquid;
  final String role;
  final String marketSource;

  const CalculatedNutrientItem({
    required this.nameEn,
    required this.nameBn,
    required this.chemicalFormula,
    required this.amountTotal,
    required this.amountPerTank,
    required this.isLiquid,
    required this.role,
    required this.marketSource,
  });
}

class CalculatedSoilItem {
  final String nameEn;
  final String nameBn;
  final String chemicalFormula;
  final double totalKg;
  final String role;
  final String marketSource;

  const CalculatedSoilItem({
    required this.nameEn,
    required this.nameBn,
    required this.chemicalFormula,
    required this.totalKg,
    required this.role,
    required this.marketSource,
  });
}

class RecoveryCalculationResult {
  final DiseaseRecoveryRecipe recipe;
  final double areaAcres;
  final double totalWaterLiters;
  final int totalKnapsackTanks;
  final double tankCapacityLiters;
  final List<CalculatedNutrientItem> foliarItems;
  final List<CalculatedSoilItem> soilItems;

  const RecoveryCalculationResult({
    required this.recipe,
    required this.areaAcres,
    required this.totalWaterLiters,
    required this.totalKnapsackTanks,
    required this.tankCapacityLiters,
    required this.foliarItems,
    required this.soilItems,
  });
}

