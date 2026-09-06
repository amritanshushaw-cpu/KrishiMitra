import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fresnel/fresnel.dart';
import '../../core/theme/app_theme.dart';
import '../../state/farm_provider.dart';
import '../widgets/soil_intelligence_wave_chart.dart';
import '../widgets/climate_iq_arc_gauge.dart';
import '../widgets/sigmoid_growth_curve_chart.dart';
import '../widgets/ndvi_satellite_map_card.dart';
import '../widgets/research_hub_chat_panel.dart';

class DataMeetsGrowthCockpitScreen extends StatefulWidget {
  final VoidCallback? onBackToMobile;
  const DataMeetsGrowthCockpitScreen({super.key, this.onBackToMobile});

  @override
  State<DataMeetsGrowthCockpitScreen> createState() =>
      _DataMeetsGrowthCockpitScreenState();
}

class _DataMeetsGrowthCockpitScreenState
    extends State<DataMeetsGrowthCockpitScreen> {
  String _activeNavPill = 'Research Hub';

  final List<String> _navPills = [
    'Dashboard',
    'Field Pulse',
    'Research Hub',
    'Sustainability',
    'Reports',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final farm = Provider.of<FarmProvider>(context);

    final textDark = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textMuted = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Container(
      decoration: AppTheme.backgroundDecoration(isDark),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 1060;
              final isTablet = constraints.maxWidth >= 650 && constraints.maxWidth < 1060;

              return CustomScrollView(
                slivers: [
                  // Top Navigation Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      child: _buildTopNav(isDark, farm, isDesktop || isTablet),
                    ),
                  ),

                  // Cockpit Title & Action Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: _buildHeader(isDark, textDark, textMuted, isDesktop, farm),
                    ),
                  ),

                  // Responsive Bento Grid of Animated Visualizations wrapped in Fresnel GlassContainer
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    sliver: SliverToBoxAdapter(
                      child: GlassContainer(
                        child: isDesktop
                            ? _buildDesktopGrid()
                            : (isTablet ? _buildTabletGrid() : _buildMobileStack()),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 36),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopNav(bool isDark, FarmProvider farm, bool showCapsule) {
    return Row(
      children: [
        // Sprout Logo Mark
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.deepPine : AppTheme.mintDew,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.softSage.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.spa,
              size: 20,
              color: isDark ? AppTheme.softSage : AppTheme.forestMoss,
            ),
          ),
        ),
        const SizedBox(width: 14),

        if (widget.onBackToMobile != null)
          TextButton.icon(
            onPressed: widget.onBackToMobile,
            icon: const Icon(Icons.arrow_back, size: 16),
            label: Text(
              'Mobile Mode',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? AppTheme.softSage : AppTheme.forestMoss,
            ),
          ),

        // Center Capsule Pill Bar with Apple Glassmorphism
        if (showCapsule)
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: AppTheme.glassCardDecoration(isDark: isDark, radius: 30),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _navPills.map((pill) {
                      final isSelected = _activeNavPill == pill;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _activeNavPill = pill);
                          if (pill == 'Dashboard' && widget.onBackToMobile != null) {
                            widget.onBackToMobile!();
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppTheme.softSage : AppTheme.forestMoss)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            pill,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? (isDark ? AppTheme.midnightTeal : AppTheme.mintDew)
                                  : (isDark ? AppTheme.softSage : AppTheme.slatePine),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          )
        else
          const Spacer(),

        // Right Action Group
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode_outlined,
                size: 20,
              ),
              onPressed: () => farm.toggleTheme(),
              tooltip: 'Toggle Theme',
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 20),
              onPressed: () {},
            ),
            const SizedBox(width: 6),
            // User Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF52B788),
                  width: 2,
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/demo/potato_healthy.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(
    bool isDark,
    Color textDark,
    Color textMuted,
    bool isDesktop,
    FarmProvider farm,
  ) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 16,
      runSpacing: 12,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  'Data Drives Growth',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.softSage,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.softSage.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.softSage.withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: AppTheme.softSage),
                      const SizedBox(width: 3),
                      Text(
                        farm.farmerLocation,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.softSage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Data Meets Growth',
              style: GoogleFonts.plusJakartaSans(
                fontSize: isDesktop ? 34 : 24,
                fontWeight: FontWeight.w800,
                color: textDark,
                letterSpacing: -1.0,
              ),
            ),
          ],
        ),
        // Action buttons (Share, + Research, Wand)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share, size: 14),
              label: Text(
                'Share',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppTheme.deepPine : AppTheme.forestMoss,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: AppTheme.softSage.withValues(alpha: isDark ? 0.35 : 0.45),
                    width: 1.0,
                  ),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                side: BorderSide(
                  color: isDark ? AppTheme.darkBorderStrong : AppTheme.sageBorderHover,
                  width: 1.2,
                ),
              ),
              child: Text(
                '+ Research',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // DESKTOP: Asymmetric 3-Column Top + 2-Column Bottom Layout
  Widget _buildDesktopGrid() {
    return Column(
      children: [
        // Top Row
        SizedBox(
          height: 380,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Expanded(
                flex: 3,
                child: ResearchHubChatPanel(),
              ),
              SizedBox(width: 18),
              Expanded(
                flex: 5,
                child: SoilIntelligenceWaveChart(),
              ),
              SizedBox(width: 18),
              Expanded(
                flex: 4,
                child: ClimateIqArcGauge(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Bottom Row
        SizedBox(
          height: 380,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Expanded(
                flex: 5,
                child: NdviSatelliteMapCard(),
              ),
              SizedBox(width: 18),
              Expanded(
                flex: 7,
                child: SigmoidGrowthCurveChart(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // TABLET: 2-Column Balanced Adaptive Layout
  Widget _buildTabletGrid() {
    return Column(
      children: [
        SizedBox(
          height: 360,
          child: Row(
            children: const [
              Expanded(child: SoilIntelligenceWaveChart()),
              SizedBox(width: 16),
              Expanded(child: ClimateIqArcGauge()),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 360,
          child: Row(
            children: const [
              Expanded(child: NdviSatelliteMapCard()),
              SizedBox(width: 16),
              Expanded(child: SigmoidGrowthCurveChart()),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SizedBox(
          height: 320,
          child: ResearchHubChatPanel(),
        ),
      ],
    );
  }

  // MOBILE: Vertical Smooth Stack
  Widget _buildMobileStack() {
    return Column(
      children: const [
        SizedBox(
          height: 350,
          child: SoilIntelligenceWaveChart(),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 320,
          child: ClimateIqArcGauge(),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 420,
          child: SigmoidGrowthCurveChart(),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 350,
          child: NdviSatelliteMapCard(),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 340,
          child: ResearchHubChatPanel(),
        ),
      ],
    );
  }
}
