import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/agri_calculator_service.dart';

class FarmingEconomicsCalculatorView extends StatefulWidget {
  const FarmingEconomicsCalculatorView({super.key});

  @override
  State<FarmingEconomicsCalculatorView> createState() => _FarmingEconomicsCalculatorViewState();
}

class _FarmingEconomicsCalculatorViewState extends State<FarmingEconomicsCalculatorView> {
  CropType _selectedCrop = CropType.tomato;
  LandUnit _selectedUnit = LandUnit.acre;
  double _area = 1.0;

  late double _expectedYield;
  late double _marketPrice;

  // Itemized costs (defaults tailored for 1 acre)
  double _seedsCost = 4500.0;
  double _tillageCost = 3500.0;
  double _fertilizerCost = 6500.0;
  double _pesticideCost = 3500.0;
  double _irrigationCost = 2500.0;
  double _laborCost = 8000.0;

  bool _isCostBreakdownExpanded = false;

  @override
  void initState() {
    super.initState();
    _expectedYield = _selectedCrop.typicalYieldQuintalsPerAcre;
    _marketPrice = _selectedCrop.defaultMspPricePerQuintal;
  }

  void _onCropChanged(CropType crop) {
    setState(() {
      _selectedCrop = crop;
      _expectedYield = crop.typicalYieldQuintalsPerAcre;
      _marketPrice = crop.defaultMspPricePerQuintal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = AgriCalculatorService.calculateEconomics(
      area: _area,
      unit: _selectedUnit,
      expectedYieldPerUnit: _expectedYield,
      marketPricePerQuintal: _marketPrice,
      seedsCost: _seedsCost,
      tillageCost: _tillageCost,
      fertilizerCost: _fertilizerCost,
      pesticideCost: _pesticideCost,
      irrigationCost: _irrigationCost,
      laborHarvestCost: _laborCost,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Crop Selection Pills
          Text(
            'SELECT CROP ENTERPRISE',
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
              children: CropType.values.map((c) {
                final isSelected = c == _selectedCrop;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _onCropChanged(c),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32))
                            : (isDark ? const Color(0xFF16201B).withValues(alpha: 0.65) : Colors.white.withValues(alpha: 0.78)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32))
                              : (isDark ? AppTheme.darkBorder : const Color(0x281A3E31)),
                        ),
                      ),
                      child: Text(
                        '${c.nameEn} (${c.nameBn})',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32)),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // 2. Production Parameters Card (Yield, Land, Market Price)
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
                    Text(
                      'Expected Harvest Yield',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                      ),
                    ),
                    Text(
                      '${_expectedYield.toStringAsFixed(0)} Quintals / ${_selectedUnit.label}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF2E7D32),
                    inactiveTrackColor: const Color(0xFFE8F5EE),
                    thumbColor: const Color(0xFF2E7D32),
                  ),
                  child: Slider(
                    value: _expectedYield,
                    min: 5.0,
                    max: 300.0,
                    divisions: 59,
                    onChanged: (val) => setState(() => _expectedYield = val),
                  ),
                ),
                const Divider(height: 16, color: Color(0xFFEEF4F0)),

                // Market Selling Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Market Selling Price',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                      ),
                    ),
                    Text(
                      '₹${_marketPrice.toStringAsFixed(0)} / Quintal',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0288D1),
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF0288D1),
                    inactiveTrackColor: const Color(0xFFE1F5FE),
                    thumbColor: const Color(0xFF0288D1),
                  ),
                  child: Slider(
                    value: _marketPrice,
                    min: 500.0,
                    max: 8000.0,
                    divisions: 75,
                    onChanged: (val) => setState(() => _marketPrice = val),
                  ),
                ),
                const Divider(height: 16, color: Color(0xFFEEF4F0)),

                // Land Area
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cultivated Area',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${_area.toStringAsFixed(1)} ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _selectedUnit =
                              _selectedUnit == LandUnit.acre ? LandUnit.bigha : LandUnit.acre),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.darkSurfaceElevated : const Color(0xFFE8F5EE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _selectedUnit.label,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32),
                    inactiveTrackColor: isDark ? const Color(0xFF333333) : const Color(0xFFE8F5EE),
                    thumbColor: isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32),
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

          // 3. Collapsible Input Costs Breakdown
          Container(
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
              children: [
                ListTile(
                  title: Text(
                    'Input Costs Breakdown',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                    ),
                  ),
                  subtitle: Text(
                    'Total Budget: ₹${result.totalInputBudget.toStringAsFixed(0)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF52796F),
                    ),
                  ),
                  trailing: Icon(
                    _isCostBreakdownExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                  ),
                  onTap: () => setState(() => _isCostBreakdownExpanded = !_isCostBreakdownExpanded),
                ),
                if (_isCostBreakdownExpanded) ...[
                  Divider(height: 1, color: isDark ? AppTheme.darkBorder : const Color(0xFFEEF4F0)),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildCostRow('Seeds / Seedlings', _seedsCost, (v) => setState(() => _seedsCost = v)),
                        _buildCostRow('Tillage & Land Prep', _tillageCost, (v) => setState(() => _tillageCost = v)),
                        _buildCostRow('Fertilizers & Manure', _fertilizerCost, (v) => setState(() => _fertilizerCost = v)),
                        _buildCostRow('Crop Protection / Sprays', _pesticideCost, (v) => setState(() => _pesticideCost = v)),
                        _buildCostRow('Irrigation & Fuel/Power', _irrigationCost, (v) => setState(() => _irrigationCost = v)),
                        _buildCostRow('Labor & Harvesting', _laborCost, (v) => setState(() => _laborCost = v)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 4. KEY ECONOMIC METRICS
          Text(
            'PROFITABILITY & NO-LOSS ANALYSIS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F),
            ),
          ),
          const SizedBox(height: 8),

          // 2x2 Bento Metric Grid
          Row(
            children: [
              // No-Loss Price
              Expanded(
                child: _buildDecisionCard(
                  title: 'No-Loss Price',
                  value: '₹${result.noLossPricePerQuintal.toStringAsFixed(0)}',
                  subtitle: 'per quintal minimum',
                  icon: Icons.price_check_rounded,
                  bubbleColor: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFE65100),
                  badgeText: 'BREAK-EVEN',
                  badgeColor: const Color(0xFFFF9800),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              // Break-Even Yield
              Expanded(
                child: _buildDecisionCard(
                  title: 'Required Yield',
                  value: '${result.breakEvenYieldQuintals.toStringAsFixed(1)} Q',
                  subtitle: 'to recover costs',
                  icon: Icons.balance_rounded,
                  bubbleColor: const Color(0xFFE1F5FE),
                  iconColor: const Color(0xFF0288D1),
                  badgeText: 'MIN HARVEST',
                  badgeColor: const Color(0xFF0288D1),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              // Maximum Input Budget
              Expanded(
                child: _buildDecisionCard(
                  title: 'Input Budget',
                  value: '₹${result.totalInputBudget.toStringAsFixed(0)}',
                  subtitle: 'total expenditures',
                  icon: Icons.account_balance_wallet_rounded,
                  bubbleColor: const Color(0xFFEDE7F6),
                  iconColor: const Color(0xFF5E35B1),
                  badgeText: 'COSTS',
                  badgeColor: const Color(0xFF5E35B1),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              // Estimated Net Profit
              Expanded(
                child: _buildDecisionCard(
                  title: 'Estimated Profit',
                  value: '₹${result.estimatedNetProfit.toStringAsFixed(0)}',
                  subtitle: '${result.profitMarginPct.toStringAsFixed(1)}% margin',
                  icon: Icons.trending_up_rounded,
                  bubbleColor: result.isProfitable ? const Color(0xFFE8F5EE) : const Color(0xFFFFEBEE),
                  iconColor: result.isProfitable ? const Color(0xFF193E32) : const Color(0xFFD32F2F),
                  badgeText: '${result.returnOnInvestmentPct.toStringAsFixed(0)}% ROI',
                  badgeColor: result.isProfitable ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Net Revenue vs Investment Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark
                      ? AppTheme.darkSurfaceElevated
                      : (result.isProfitable ? const Color(0xFFE8F5EE) : const Color(0xFFFFEBEE)))
                  .withValues(alpha: isDark ? 0.72 : 0.85),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? (result.isProfitable ? AppTheme.darkAccentGreen.withValues(alpha: 0.3) : AppTheme.alertRed.withValues(alpha: 0.3))
                    : const Color(0x281A3E31),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  result.isProfitable ? Icons.check_circle_rounded : Icons.warning_rounded,
                  color: result.isProfitable ? (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32)) : const Color(0xFFD32F2F),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.isProfitable
                            ? 'Profitable Enterprise (${result.profitMarginPct.toStringAsFixed(1)}% Profit Margin)'
                            : 'Loss Alert: Current market price does not cover input costs!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: result.isProfitable ? (isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32)) : const Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Gross Output: ₹${result.grossRevenue.toStringAsFixed(0)} • Total Harvest: ${result.totalYieldQuintals.toStringAsFixed(1)} Quintals',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: isDark ? AppTheme.darkTextSecondary : (result.isProfitable ? const Color(0xFF52796F) : const Color(0xFF9E3D3D)),
                        ),
                      ),
                    ],
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

  Widget _buildDecisionCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color bubbleColor,
    required Color iconColor,
    required String badgeText,
    required Color badgeColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF16201B) : Colors.white).withValues(alpha: isDark ? 0.70 : 0.80),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0x281A3E31),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.15) : const Color(0x0A1A3E31),
            blurRadius: 12,
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: bubbleColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 17, color: iconColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF2C3E35),
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: isDark ? AppTheme.darkTextMuted : const Color(0xFF7A9E93),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String title, double cost, ValueChanged<double> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF52796F),
            ),
          ),
          Row(
            children: [
              Text(
                '₹${cost.toStringAsFixed(0)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (cost > 500) onChanged(cost - 500);
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurfaceElevated : const Color(0xFFF1F6F2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.remove, size: 14, color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32)),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => onChanged(cost + 500),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurfaceElevated : const Color(0xFFF1F6F2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.add, size: 14, color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
