import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/agri_calculator_service.dart';

class PesticideCalculatorView extends StatefulWidget {
  const PesticideCalculatorView({super.key});

  @override
  State<PesticideCalculatorView> createState() => _PesticideCalculatorViewState();
}

class _PesticideCalculatorViewState extends State<PesticideCalculatorView> {
  SprayPreset _selectedPreset = SprayPreset.lateBlightFungicide;
  double _tankCapacity = 16.0; // 16L Knapsack default in India
  double _area = 1.0;
  LandUnit _selectedUnit = LandUnit.acre;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = AgriCalculatorService.calculateSpray(
      area: _area,
      unit: _selectedUnit,
      preset: _selectedPreset,
      tankCapacityLiters: _tankCapacity,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Target Problem & Formulation Picker
          Text(
            'SELECT PEST / PATHOGEN ISSUE',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F),
            ),
          ),
          const SizedBox(height: 8),

          Column(
            children: SprayPreset.values.map((preset) {
              final isSelected = preset == _selectedPreset;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _selectedPreset = preset),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF163828) : const Color(0xFFE8F5EE))
                            : (isDark ? const Color(0xFF16201B).withValues(alpha: 0.65) : Colors.white.withValues(alpha: 0.78)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32))
                              : (isDark ? AppTheme.darkBorder : const Color(0x281A3E31)),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withValues(alpha: 0.15) : const Color(0x0A1A3E31),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32))
                                  : (isDark ? Colors.white12 : const Color(0xFFE8F5EE)),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getPresetIcon(preset),
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32)),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        preset.targetIssue,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32))
                                            : (isDark ? Colors.white10 : const Color(0xFFE8F5EE)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'PHI: ${preset.phiDays}d',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${preset.chemicalName} • Dosage: ${preset.dosageLabel}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F),
                                  ),
                                ),
                              ],
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
          const SizedBox(height: 14),

          // 2. Sprayer Tank Capacity Selector
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
                            color: Color(0xFFE1F5FE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.sanitizer_rounded,
                            color: Color(0xFF0288D1),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Sprayer Tank Capacity',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_tankCapacity.toInt()} Liters',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0288D1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildTankOption(15.0, '15L Manual', isDark),
                    const SizedBox(width: 8),
                    _buildTankOption(16.0, '16L Knapsack', isDark),
                    const SizedBox(width: 8),
                    _buildTankOption(20.0, '20L Battery', isDark),
                  ],
                ),
                const SizedBox(height: 16),

                // Area Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Target Field Area: ${_area.toStringAsFixed(1)} ${_selectedUnit.label}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                      ),
                    ),
                    Row(
                      children: LandUnit.values.map((u) {
                        final isSel = u == _selectedUnit;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedUnit = u),
                          child: Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32))
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              u.label,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isSel ? Colors.white : const Color(0xFF52796F),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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
          const SizedBox(height: 18),

          // 3. RESULTS CARDS
          Text(
            'SPRAY SOLUTION & REFILL DOSAGE',
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
                child: _buildMetricBox(
                  label: 'Refill Tanks',
                  value: '${result.totalTanks} Tanks',
                  sub: '${result.totalWaterLiters.toStringAsFixed(0)} L solution',
                  bubbleColor: const Color(0xFFE1F5FE),
                  iconColor: const Color(0xFF0288D1),
                  icon: Icons.sync_rounded,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricBox(
                  label: 'Dose per Tank',
                  value: result.isPowder
                      ? '${result.chemicalPerTank.toStringAsFixed(1)} g'
                      : '${result.chemicalPerTank.toStringAsFixed(1)} ml',
                  sub: 'per ${_tankCapacity.toInt()}L water',
                  bubbleColor: const Color(0xFFE8F5EE),
                  iconColor: const Color(0xFF193E32),
                  icon: Icons.medication_liquid_rounded,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricBox(
                  label: 'Total Chemical',
                  value: result.isPowder
                      ? '${result.totalChemicalRequired.toStringAsFixed(0)} g'
                      : '${result.totalChemicalRequired.toStringAsFixed(0)} ml',
                  sub: 'whole plot',
                  bubbleColor: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFE65100),
                  icon: Icons.scale_rounded,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Safety & PHI Waiting Period Advisory Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF16201B) : Colors.white).withValues(alpha: isDark ? 0.70 : 0.80),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : const Color(0x281A3E31),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A1A3E31),
                  blurRadius: 12,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined, size: 13, color: Color(0xFFE65100)),
                          const SizedBox(width: 4),
                          Text(
                            'Pre-Harvest Interval (PHI): ${result.phiDays} Days',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE65100),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5EE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Rain Safe',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF193E32),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  result.safetyAdvisory,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF2C3E35),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTankOption(double cap, String title, bool isDark) {
    final isSelected = _tankCapacity == cap;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tankCapacity = cap),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32))
                : (isDark ? AppTheme.darkSurfaceElevated : const Color(0xFFF7FAF8)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32))
                  : (isDark ? AppTheme.darkBorder : const Color(0xFFE3EDE5)),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : (isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricBox({
    required String label,
    required String value,
    required String sub,
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
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
            ),
          ),
          Text(
            sub,
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

  IconData _getPresetIcon(SprayPreset preset) {
    switch (preset) {
      case SprayPreset.lateBlightFungicide:
        return Icons.coronavirus_rounded;
      case SprayPreset.suckingPestInsecticide:
        return Icons.pest_control_rounded;
      case SprayPreset.borerCaterpillar:
        return Icons.bug_report_rounded;
      case SprayPreset.bioNeemPreventive:
        return Icons.eco_rounded;
    }
  }
}
