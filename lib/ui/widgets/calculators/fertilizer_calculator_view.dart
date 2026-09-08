import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/agri_calculator_service.dart';

class FertilizerCalculatorView extends StatefulWidget {
  const FertilizerCalculatorView({super.key});

  @override
  State<FertilizerCalculatorView> createState() => _FertilizerCalculatorViewState();
}

class _FertilizerCalculatorViewState extends State<FertilizerCalculatorView> {
  CropType _selectedCrop = CropType.tomato;
  LandUnit _selectedUnit = LandUnit.acre;
  double _area = 1.0;
  FertilizerCombination _selectedCombo = FertilizerCombination.ureaDapMop;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = AgriCalculatorService.calculateFertilizer(
      crop: _selectedCrop,
      area: _area,
      unit: _selectedUnit,
      combo: _selectedCombo,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Crop Selection
          Text(
            'SELECT TARGET CROP',
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
              children: CropType.values.map((crop) {
                final isSelected = crop == _selectedCrop;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _selectedCrop = crop),
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32))
                              : (isDark ? AppTheme.darkCard : Colors.white),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32))
                                : (isDark ? AppTheme.darkBorder : const Color(0xFFE3EDE5)),
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
          const SizedBox(height: 18),

          // 2. Land Area & Unit Selector Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : const Color(0xFFE3EDE5),
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
                          'Plot Surface Area',
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
                      'Area: ${_area.toStringAsFixed(1)} ${_selectedUnit.label}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                      ),
                    ),
                    Text(
                      'ICAR NPK: ${_selectedCrop.defaultN.toInt()}-${_selectedCrop.defaultP.toInt()}-${_selectedCrop.defaultK.toInt()} kg/ac',
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
          const SizedBox(height: 14),

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
                            ? const Color(0xFFE8F5EE)
                            : (isDark ? AppTheme.darkCard : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCombo ? const Color(0xFF193E32) : const Color(0xFFE3EDE5),
                          width: isCombo ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            combo == FertilizerCombination.ureaDapMop ? 'DAP + Urea + MOP' : 'SSP + Urea + MOP',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? (isCombo ? AppTheme.darkAccentGreen : AppTheme.darkTextPrimary) : const Color(0xFF193E32),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            combo == FertilizerCombination.ureaDapMop ? 'Common Standard' : 'Sulfur Fortified',
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

          // 4. RESULTS SECTION
          Text(
            'TOTAL FERTILIZER REQUIRED',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F),
            ),
          ),
          const SizedBox(height: 8),

          // Bags Grid
          Row(
            children: [
              // Urea
              Expanded(
                child: _buildFertilizerTile(
                  label: 'Urea (46% N)',
                  kg: result.ureaKg,
                  bags: result.ureaBags,
                  bagWeight: 45,
                  bubbleColor: const Color(0xFFE8F5EE),
                  iconColor: const Color(0xFF193E32),
                  icon: Icons.grain_rounded,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              // DAP or SSP
              Expanded(
                child: _selectedCombo == FertilizerCombination.ureaDapMop
                    ? _buildFertilizerTile(
                        label: 'DAP (P+N)',
                        kg: result.dapKg,
                        bags: result.dapBags,
                        bagWeight: 50,
                        bubbleColor: const Color(0xFFFFF3E0),
                        iconColor: const Color(0xFFE65100),
                        icon: Icons.science_rounded,
                        isDark: isDark,
                      )
                    : _buildFertilizerTile(
                        label: 'SSP (16% P)',
                        kg: result.sspKg,
                        bags: result.sspBags,
                        bagWeight: 50,
                        bubbleColor: const Color(0xFFFFF3E0),
                        iconColor: const Color(0xFFE65100),
                        icon: Icons.science_rounded,
                        isDark: isDark,
                      ),
              ),
              const SizedBox(width: 8),
              // MOP
              Expanded(
                child: _buildFertilizerTile(
                  label: 'MOP (60% K)',
                  kg: result.mopKg,
                  bags: result.mopBags,
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

          // Estimated Subsidized Cost Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurfaceElevated : const Color(0xFFE8F5EE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppTheme.darkBorder : Colors.transparent),
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
                      'Subsidized Fertilizer Budget:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${result.estimatedCostInr.toStringAsFixed(0)}',
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

          // 5. SPLIT APPLICATION SCHEDULE
          Text(
            'SPLIT APPLICATION TIMELINE (ICAR PROTOCOL)',
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
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : const Color(0xFFE3EDE5),
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
                  step: 'Stage 1 • Basal Application',
                  timing: 'At transplanting or final land tilling',
                  dose: result.basalDoseSummary,
                  icon: Icons.spa_rounded,
                  color: const Color(0xFF193E32),
                  isDark: isDark,
                ),
                const Divider(height: 24, color: Color(0xFFEEF4F0)),
                _buildScheduleStep(
                  step: 'Stage 2 • Vegetative Top-Dressing',
                  timing: '21 to 25 days after planting (Tillering)',
                  dose: result.vegetativeDoseSummary,
                  icon: Icons.eco_rounded,
                  color: const Color(0xFF2E7D32),
                  isDark: isDark,
                ),
                const Divider(height: 24, color: Color(0xFFEEF4F0)),
                _buildScheduleStep(
                  step: 'Stage 3 • Flowering / Panicle Stage',
                  timing: '45 to 50 days (Flower bud & grain fill)',
                  dose: result.floweringDoseSummary,
                  icon: Icons.local_florist_rounded,
                  color: const Color(0xFF0288D1),
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
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
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE3EDE5),
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
