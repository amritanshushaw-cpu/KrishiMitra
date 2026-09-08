/// AgriCalculatorService
/// Deterministic agronomic and economic calculations based on ICAR / FAO guidelines.

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
}
