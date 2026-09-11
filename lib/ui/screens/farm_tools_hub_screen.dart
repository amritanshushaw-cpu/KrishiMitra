import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../state/farm_provider.dart';
import '../widgets/calculators/farming_economics_calculator_view.dart';
import '../widgets/calculators/fertilizer_calculator_view.dart';
import '../widgets/calculators/pesticide_calculator_view.dart';

class FarmToolsHubScreen extends StatefulWidget {
  final int initialTabIndex;
  final VoidCallback? onBack;

  const FarmToolsHubScreen({
    super.key,
    this.initialTabIndex = 0,
    this.onBack,
  });

  @override
  State<FarmToolsHubScreen> createState() => _FarmToolsHubScreenState();
}

class _FarmToolsHubScreenState extends State<FarmToolsHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<Map<String, dynamic>> _tabs = [
    {'title': 'Fertilizer', 'icon': Icons.spa_outlined},
    {'title': 'Spray Tank', 'icon': Icons.sanitizer_outlined},
    {'title': 'Economics', 'icon': Icons.trending_up_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, _tabs.length - 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleBack(BuildContext context) {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      final provider = context.read<FarmProvider>();
      if (!provider.popTab()) {
        provider.setTabIndex(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<FarmProvider>();

    if (provider.openCalculatorInRecoveryMode && _tabController.index != 0) {
      _tabController.index = 0;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack(context);
      },
      child: Container(
        color: Colors.transparent,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                size: 20,
              ),
              tooltip: 'Back to Farm Dashboard',
              onPressed: () => _handleBack(context),
            ),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agronomic Calculators',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'ICAR & FAO Standard Advisory Engine',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F),
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFF16201B) : Colors.white).withValues(alpha: isDark ? 0.68 : 0.78),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorder : const Color(0x331A3E31),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A1A3E31),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        indicator: BoxDecoration(
                          color: isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32)).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: isDark ? const Color(0xFF03120E) : Colors.white,
                        unselectedLabelColor: isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: _tabs.map((tab) {
                          return Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(tab['icon'] as IconData, size: 14),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    tab['title'] as String,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: TabBarView(
              controller: _tabController,
              children: const [
                FertilizerCalculatorView(),
                PesticideCalculatorView(),
                FarmingEconomicsCalculatorView(),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
