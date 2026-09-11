import 'package:flutter_test/flutter_test.dart';
import 'package:smartfarm_app/services/agri_calculator_service.dart';

void main() {
  group('Scientific Disease Recovery Fertilizer Tests', () {
    test('Potato Late Blight: verifies ICAR-CPRI recipe and exact component scaling for 1 Acre', () {
      final recipe = AgriCalculatorService.diseaseRecoveryRecipes['Potato___Late_Blight']!;
      expect(recipe.crop, CropType.potato);
      expect(recipe.haltNitrogen, isTrue);
      expect(recipe.researchCitation, contains('ICAR-Central Potato Research Institute'));

      final result = AgriCalculatorService.calculateDiseaseRecovery(
        recipe: recipe,
        area: 1.0,
        unit: LandUnit.acre,
      );

      // 1 Acre = 200 Liters of water
      expect(result.totalWaterLiters, equals(200.0));
      // 200L / 16L = 12.5 -> 13 tanks
      expect(result.totalKnapsackTanks, equals(13));

      // Potassium Phosphite @ 2.5 g/L -> 500g total, 40g per 16L tank
      final phosphite = result.foliarItems.firstWhere((i) => i.nameEn.contains('Potassium Phosphite'));
      expect(phosphite.amountTotal, equals(500.0));
      expect(phosphite.amountPerTank, equals(40.0));

      // Calcium Nitrate @ 3.0 g/L -> 600g total, 48g per 16L tank
      final calcium = result.foliarItems.firstWhere((i) => i.nameEn.contains('Calcium Nitrate'));
      expect(calcium.amountTotal, equals(600.0));
      expect(calcium.amountPerTank, equals(48.0));

      // Soil MOP @ 12 kg/acre
      final mop = result.soilItems.firstWhere((i) => i.nameEn.contains('Muriate of Potash'));
      expect(mop.totalKg, equals(12.0));
    });

    test('Tomato Late Blight: verifies AVRDC/IIHR recipe with Boron and Nitrogen suspension', () {
      final recipe = AgriCalculatorService.diseaseRecoveryRecipes['Tomato___Late_Blight']!;
      expect(recipe.crop, CropType.tomato);
      expect(recipe.haltNitrogen, isTrue);

      final result = AgriCalculatorService.calculateDiseaseRecovery(
        recipe: recipe,
        area: 2.0,
        unit: LandUnit.acre,
      );

      // 2 Acres = 400 Liters water -> 25 tanks
      expect(result.totalWaterLiters, equals(400.0));
      expect(result.totalKnapsackTanks, equals(25));

      // Boron @ 0.5 g/L -> 200g total for 400L, 8g per tank
      final boron = result.foliarItems.firstWhere((i) => i.nameEn.contains('Boron'));
      expect(boron.amountTotal, equals(200.0));
      expect(boron.amountPerTank, equals(8.0));
    });

    test('Rice Leaf Blast: verifies IRRI/NRRI Silica double-layer cuticle defense and MOP', () {
      final recipe = AgriCalculatorService.diseaseRecoveryRecipes['Rice___Leaf_Blast']!;
      expect(recipe.crop, CropType.paddy);
      expect(recipe.haltNitrogen, isTrue);

      final result = AgriCalculatorService.calculateDiseaseRecovery(
        recipe: recipe,
        area: 1.0,
        unit: LandUnit.acre,
      );

      final silica = result.foliarItems.firstWhere((i) => i.nameEn.contains('Silicate'));
      expect(silica.isLiquid, isTrue);
      // 2.5 ml/L in 200L = 500 ml total, 40 ml per 16L tank
      expect(silica.amountTotal, equals(500.0));
      expect(silica.amountPerTank, equals(40.0));
    });

    test('Bigha Unit Scaling: accurately calculates 1 Bigha (0.3306 Acre)', () {
      final recipe = AgriCalculatorService.diseaseRecoveryRecipes['Potato___Late_Blight']!;
      final result = AgriCalculatorService.calculateDiseaseRecovery(
        recipe: recipe,
        area: 1.0,
        unit: LandUnit.bigha,
      );

      // 1 Bigha = 0.3306 Acre * 200L ≈ 66.12 Liters
      expect(result.totalWaterLiters, closeTo(66.12, 0.1));
      // 66.12 / 16 = 4.13 -> 5 tanks
      expect(result.totalKnapsackTanks, equals(5));
      // Soil MOP: 12 kg * 0.3306 ≈ 3.967 kg
      final mop = result.soilItems.firstWhere((i) => i.nameEn.contains('Muriate of Potash'));
      expect(mop.totalKg, closeTo(3.967, 0.05));
    });
  });
}
