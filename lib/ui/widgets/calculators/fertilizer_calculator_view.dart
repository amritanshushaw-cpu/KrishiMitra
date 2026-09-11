import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/agri_calculator_service.dart';
import '../../../state/farm_provider.dart';

class FertilizerCalculatorView extends StatefulWidget {
  const FertilizerCalculatorView({super.key});

  @override
  State<FertilizerCalculatorView> createState() => _FertilizerCalculatorViewState();
}

class _FertilizerCalculatorViewState extends State<FertilizerCalculatorView> {
  bool _isRecoveryMode = false;
  CropType _selectedCrop = CropType.tomato;
  String _selectedDiseaseId = 'Tomato___Late_Blight';
  LandUnit _selectedUnit = LandUnit.acre;
  double _area = 1.0;
  FertilizerCombination _selectedCombo = FertilizerCombination.ureaDapMop;
  bool _initializedFromProvider = false;

  static const List<CropType> _recoveryCrops = [
    CropType.potato,
    CropType.tomato,
    CropType.paddy,
  ];

  // Cleaned didChangeDependencies; reactive handling now lives in build()

  String _getDefaultDiseaseForCrop(CropType crop) {
    switch (crop) {
      case CropType.potato:
        return 'Potato___Late_Blight';
      case CropType.tomato:
        return 'Tomato___Late_Blight';
      case CropType.paddy:
        return 'Rice___Leaf_Blast';
      default:
        return 'Tomato___Late_Blight';
    }
  }

  List<DiseaseRecoveryRecipe> _getAvailableRecipesForCrop(CropType crop) {
    return AgriCalculatorService.diseaseRecoveryRecipes.values
        .where((recipe) => recipe.crop == crop)
        .toList();
  }

  void _onCropSelected(CropType crop) {
    setState(() {
      _selectedCrop = crop;
      if (_isRecoveryMode) {
        final available = _getAvailableRecipesForCrop(crop);
        if (available.isNotEmpty && !available.any((r) => r.id == _selectedDiseaseId)) {
          _selectedDiseaseId = available.first.id;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<FarmProvider>();

    if (provider.openCalculatorInRecoveryMode) {
      _isRecoveryMode = true;
      if (provider.activeCalculatorCrop != null) {
        _selectedCrop = provider.activeCalculatorCrop!;
      }
      if (provider.activeCalculatorDiseaseId != null &&
          AgriCalculatorService.getRecoveryRecipe(provider.activeCalculatorDiseaseId) != null) {
        _selectedDiseaseId = AgriCalculatorService.getRecoveryRecipe(provider.activeCalculatorDiseaseId)!.id;
      } else {
        _selectedDiseaseId = _getDefaultDiseaseForCrop(_selectedCrop);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.clearRecoveryCalculator();
      });
    }

    final standardResult = AgriCalculatorService.calculateFertilizer(
      crop: _selectedCrop,
      area: _area,
      unit: _selectedUnit,
      combo: _selectedCombo,
    );

    final activeRecipe = AgriCalculatorService.getRecoveryRecipe(_selectedDiseaseId) ??
        AgriCalculatorService.diseaseRecoveryRecipes['Tomato___Late_Blight']!;

    final recoveryResult = AgriCalculatorService.calculateDiseaseRecovery(
      recipe: activeRecipe,
      area: _area,
      unit: _selectedUnit,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 0. Mode Switcher (Standard NPK vs Therapeutic Recovery Rx)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF16201B) : const Color(0xFFE8F0EA)).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : const Color(0x331A3E31),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isRecoveryMode = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_isRecoveryMode
                            ? (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        provider.strings.translate('Standard Nutrition'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: !_isRecoveryMode
                              ? Colors.white
                              : (isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F)),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isRecoveryMode = true;
                        if (!_recoveryCrops.contains(_selectedCrop)) {
                          _selectedCrop = CropType.tomato;
                        }
                        _selectedDiseaseId = _getDefaultDiseaseForCrop(_selectedCrop);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _isRecoveryMode
                            ? (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.healing_rounded,
                            size: 14,
                            color: _isRecoveryMode
                                ? (isDark ? const Color(0xFF03120E) : Colors.white)
                                : (isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F)),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            provider.strings.calcRecoveryPlan,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _isRecoveryMode
                                  ? (isDark ? const Color(0xFF03120E) : Colors.white)
                                  : (isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1. Crop Selection
          Text(
            provider.strings.calcSelectCrop,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: (_isRecoveryMode ? _recoveryCrops : CropType.values).map((crop) {
                final isSelected = crop == _selectedCrop;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _onCropSelected(crop),
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32))
                              : (isDark ? const Color(0xFF16201B).withValues(alpha: 0.65) : Colors.white.withValues(alpha: 0.78)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32))
                                : (isDark ? AppTheme.darkBorder : const Color(0x281A3E31)),
                            width: 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32)).withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Text(
                              _getCropEmoji(crop),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  crop.nameEn,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32)),
                                  ),
                                ),
                                Text(
                                  crop.nameBn,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    color: isSelected
                                        ? Colors.white70
                                        : (isDark ? AppTheme.darkTextMuted : const Color(0xFF7A9E93)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // In Recovery Mode: Disease Selector
          if (_isRecoveryMode) ...[
            Text(
              provider.strings.translate('DIAGNOSED DISEASE TARGET'),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F),
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _getAvailableRecipesForCrop(_selectedCrop).map((recipe) {
                  final isSelected = recipe.id == _selectedDiseaseId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDiseaseId = recipe.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? AppTheme.emeraldLight.withValues(alpha: 0.20) : const Color(0xFFE8F5EE))
                              : (isDark ? const Color(0xFF16201B).withValues(alpha: 0.65) : Colors.white.withValues(alpha: 0.75)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen)
                                : (isDark ? AppTheme.darkBorder : const Color(0x281A3E31)),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.coronavirus_outlined,
                              size: 14,
                              color: isSelected
                                  ? (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen)
                                  : (isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F)),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              recipe.diseaseNameEn.split('(').first.trim(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen)
                                    : (isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 2. Land Area & Unit Selector Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF16201B) : Colors.white).withValues(alpha: isDark ? 0.70 : 0.80),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : const Color(0x281A3E31),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0x0C1A3E31),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F5EE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.landscape_rounded,
                            color: Color(0xFF193E32),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          provider.strings.translate('Plot Surface Area'),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                          ),
                        ),
                      ],
                    ),
                    // Unit Switcher
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : const Color(0xFFF1F6F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: LandUnit.values.map((unit) {
                          final isUnitSelected = unit == _selectedUnit;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedUnit = unit),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isUnitSelected
                                    ? (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32))
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                unit.label,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isUnitSelected
                                      ? Colors.white
                                      : (isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F)),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '''${provider.strings.calcAreaLabel} ${_area.toStringAsFixed(1)} ${_selectedUnit.label}''',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                      ),
                    ),
                    Text(
                      _isRecoveryMode
                          ? 'Water: ${recoveryResult.totalWaterLiters.toStringAsFixed(0)}L (${recoveryResult.totalKnapsackTanks} Tanks)'
                          : '''${provider.strings.calcIcarNpk} ${_selectedCrop.defaultN.toInt()}-${_selectedCrop.defaultP.toInt()}-${_selectedCrop.defaultK.toInt()} kg/ac''',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF52796F),
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32),
                    inactiveTrackColor: isDark ? const Color(0xFF333333) : const Color(0xFFE8F5EE),
                    thumbColor: isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32),
                    overlayColor: (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32)).withValues(alpha: 0.15),
                  ),
                  child: Slider(
                    value: _area,
                    min: 0.25,
                    max: 10.0,
                    divisions: 39,
                    onChanged: (val) => setState(() => _area = val),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // IF RECOVERY MODE: Render Scientific Disease Recovery Section
          if (_isRecoveryMode) ...[
            _buildRecoverySection(isDark, recoveryResult),
          ] else ...[
            // STANDARD MODE: Formulation Switcher & Results
            // 3. Formulation Switcher
            Row(
              children: FertilizerCombination.values.map((combo) {
                final isCombo = combo == _selectedCombo;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCombo = combo),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isCombo
                              ? (isDark ? AppTheme.darkAccentGreen.withValues(alpha: 0.18) : const Color(0xFFE8F5EE))
                              : (isDark ? const Color(0xFF16201B).withValues(alpha: 0.65) : Colors.white.withValues(alpha: 0.78)),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCombo ? (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32)) : (isDark ? AppTheme.darkBorder : const Color(0x281A3E31)),
                            width: isCombo ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              combo == FertilizerCombination.ureaDapMop ? provider.strings.calcDapUreaMop : provider.strings.calcSspUreaMop,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? (isCombo ? AppTheme.darkAccentGreen : AppTheme.darkTextPrimary) : const Color(0xFF193E32),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              combo == FertilizerCombination.ureaDapMop ? provider.strings.calcCommonStd : provider.strings.calcSulfurFort,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF52796F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // 4. Standard Results Section
            Text(
              provider.strings.translate('TOTAL FERTILIZER REQUIRED'),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F),
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildFertilizerTile(
                    label: provider.strings.calcUreaL,
                    kg: standardResult.ureaKg,
                    bags: standardResult.ureaBags,
                    bagWeight: 45,
                    bubbleColor: const Color(0xFFE8F5EE),
                    iconColor: const Color(0xFF193E32),
                    icon: Icons.grain_rounded,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _selectedCombo == FertilizerCombination.ureaDapMop
                      ? _buildFertilizerTile(
                          label: provider.strings.calcDapL,
                          kg: standardResult.dapKg,
                          bags: standardResult.dapBags,
                          bagWeight: 50,
                          bubbleColor: const Color(0xFFFFF3E0),
                          iconColor: const Color(0xFFE65100),
                          icon: Icons.science_rounded,
                          isDark: isDark,
                        )
                      : _buildFertilizerTile(
                          label: provider.strings.calcSspL,
                          kg: standardResult.sspKg,
                          bags: standardResult.sspBags,
                          bagWeight: 50,
                          bubbleColor: const Color(0xFFFFF3E0),
                          iconColor: const Color(0xFFE65100),
                          icon: Icons.science_rounded,
                          isDark: isDark,
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFertilizerTile(
                    label: provider.strings.calcMopL,
                    kg: standardResult.mopKg,
                    bags: standardResult.mopBags,
                    bagWeight: 50,
                    bubbleColor: const Color(0xFFEDE7F6),
                    iconColor: const Color(0xFF5E35B1),
                    icon: Icons.filter_vintage_rounded,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.darkSurfaceElevated : const Color(0xFFE8F5EE)).withValues(alpha: isDark ? 0.72 : 0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppTheme.darkBorder : const Color(0x281A3E31)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.currency_rupee_rounded,
                        size: 18,
                        color: isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        provider.strings.calcSubBudget,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '₹${standardResult.estimatedCostInr.toStringAsFixed(0)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Text(
              provider.strings.translate('SPLIT APPLICATION TIMELINE (ICAR PROTOCOL)'),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F),
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF16201B) : Colors.white).withValues(alpha: isDark ? 0.70 : 0.80),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : const Color(0x281A3E31),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0x0C1A3E31),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildScheduleStep(
                    step: provider.strings.translate('Stage 1 • Basal Application'),
                    timing: provider.strings.calcTiming1,
                    dose: standardResult.basalDoseSummary,
                    icon: Icons.spa_rounded,
                    color: const Color(0xFF193E32),
                    isDark: isDark,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  _buildScheduleStep(
                    step: provider.strings.translate('Stage 2 • Vegetative Top-Dress'),
                    timing: '25-30 days after transplanting (active tillering/branching)',
                    dose: standardResult.vegetativeDoseSummary,
                    icon: Icons.eco_rounded,
                    color: const Color(0xFF2E7D32),
                    isDark: isDark,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  _buildScheduleStep(
                    step: provider.strings.translate('Stage 3 • Reproductive Booster'),
                    timing: 'Panicle initiation or early flowering phase',
                    dose: standardResult.floweringDoseSummary,
                    icon: Icons.local_florist_rounded,
                    color: const Color(0xFFF57F17),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRecoverySection(bool isDark, RecoveryCalculationResult recovery) {
    final provider = context.watch<FarmProvider>();
    final recipe = recovery.recipe;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Farmer Action & Cure Guide Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF16201B) : Colors.white).withValues(alpha: isDark ? 0.70 : 0.85),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppTheme.emeraldLight.withValues(alpha: 0.25) : const Color(0x331A3E31),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.healing_rounded,
                          color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider.strings.calcCureGuide,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      provider.strings.calcStepPlan,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                recipe.farmerActionGuide,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              // Step-by-step practical guide
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F1814) : const Color(0xFFF1F8F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildGuideStepRow(
                      icon: Icons.water_drop_rounded,
                      step: provider.strings.translate('Step 1: Knapsack Tank Mix'),
                      desc: provider.strings.translate('Fill each 16L spray tank with clean water and dissolve the exact grams/ml shown below.'),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildGuideStepRow(
                      icon: Icons.wb_sunny_rounded,
                      step: provider.strings.translate('Step 2: Spray Timing'),
                      desc: provider.strings.translate('Spray in the early morning after dew dries. Thoroughly cover top and bottom of leaves.'),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildGuideStepRow(
                      icon: Icons.grass_rounded,
                      step: provider.strings.translate('Step 3: Soil Nutrition'),
                      desc: provider.strings.translate('Broadcast Potash at root zone to restore plant vigor and speed up tissue healing.'),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Critical Nitrogen / Urea Action Alert
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: recipe.haltNitrogen
                ? AppTheme.alertRose.withValues(alpha: 0.12)
                : AppTheme.amberWarningSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: recipe.haltNitrogen
                  ? AppTheme.alertRose.withValues(alpha: 0.3)
                  : AppTheme.amberWarning.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                recipe.haltNitrogen ? Icons.cancel_rounded : Icons.info_rounded,
                color: recipe.haltNitrogen ? AppTheme.alertRose : AppTheme.amberWarning,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.haltNitrogen ? 'UREA APPLICATION RESTRICTION' : 'BALANCED NITROGEN MANAGEMENT',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: recipe.haltNitrogen ? AppTheme.alertRose : AppTheme.amberWarning,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      recipe.nitrogenAdvisory,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: recipe.haltNitrogen ? AppTheme.alertRose : AppTheme.amberWarning,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Foliar Curative Tank Mixture Breakdown
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              provider.strings.translate('FOLIAR CURATIVE TANK COMBO'),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F),
              ),
            ),
            Text(
              '${recovery.totalKnapsackTanks} Tanks (@ 16L/tank)',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ...recovery.foliarItems.map((item) {
          final isGrams = !item.isLiquid;
          final totalFormatted = item.amountTotal >= 1000
              ? '${(item.amountTotal / 1000).toStringAsFixed(2)} kg'
              : '${item.amountTotal.toStringAsFixed(0)} ${isGrams ? 'g' : 'ml'}';
          final perTankFormatted = '${item.amountPerTank.toStringAsFixed(1)} ${isGrams ? 'g' : 'ml'} / tank';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF16201B) : Colors.white).withValues(alpha: isDark ? 0.70 : 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : const Color(0x281A3E31),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.nameEn,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32)).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        totalFormatted,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppTheme.emeraldLight : const Color(0xFF193E32),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        item.chemicalFormula,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF52796F),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• $perTankFormatted',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.emeraldLight : const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Role: ${item.role}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: isDark ? AppTheme.darkTextMuted : const Color(0xFF7A9E93),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Commercial Form: ${item.marketSource}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF52796F),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),

        // 4. Soil-Applied Recovery Supplement
        if (recovery.soilItems.isNotEmpty) ...[
          Text(
            provider.strings.translate('SOIL ROOT-ZONE RECOVERY BROADCAST'),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F),
            ),
          ),
          const SizedBox(height: 8),
          ...recovery.soilItems.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF16201B) : Colors.white).withValues(alpha: isDark ? 0.70 : 0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : const Color(0x281A3E31),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nameEn,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.role,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: isDark ? AppTheme.darkTextMuted : const Color(0xFF7A9E93),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${item.totalKg.toStringAsFixed(1)} kg',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
        const SizedBox(height: 10),

        // 5. Application Protocol & Schedule Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF16201B) : Colors.white).withValues(alpha: isDark ? 0.70 : 0.85),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : const Color(0x281A3E31),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.assignment_turned_in_rounded, size: 16, color: AppTheme.amberWarning),
                  const SizedBox(width: 8),
                  Text(
                    provider.strings.calcAppProtocol,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: AppTheme.amberWarning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Schedule: ${recipe.sprayInterval}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                recipe.practicalInstructions,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuideStepRow({
    required IconData icon,
    required String step,
    required String desc,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFertilizerTile({
    required String label,
    required double kg,
    required double bags,
    required int bagWeight,
    required Color bubbleColor,
    required Color iconColor,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF16201B) : Colors.white).withValues(alpha: isDark ? 0.70 : 0.80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0x281A3E31),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0x0A1A3E31),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: bubbleColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 15, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            '${bags.toStringAsFixed(1)} Bags',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
            ),
          ),
          Text(
            '${kg.toStringAsFixed(0)} kg total',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF52796F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: isDark ? AppTheme.darkTextMuted : const Color(0xFF7A9E93),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleStep({
    required String step,
    required String timing,
    required String dose,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                timing,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: isDark ? AppTheme.darkTextMuted : const Color(0xFF7A9E93),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurfaceElevated : const Color(0xFFF7FAF8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? AppTheme.darkBorder : const Color(0xFFE8F0EA)),
                ),
                child: Text(
                  dose,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF2C3E35),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getCropEmoji(CropType crop) {
    switch (crop) {
      case CropType.paddy:
        return '🌾';
      case CropType.tomato:
        return '🍅';
      case CropType.potato:
        return '🥔';
      case CropType.wheat:
        return '🌾';
      case CropType.maize:
        return '🌽';
    }
  }
}
