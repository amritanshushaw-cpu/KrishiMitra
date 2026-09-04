import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
    'Research Hub',
    'AI Insights',
    'Field Intelligence',
    'Sustainability',
    'Reports',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final farm = Provider.of<FarmProvider>(context);

    // Warm organic cream canvas matching reference image (#F7F8F4)
    final canvasBg = isDark ? const Color(0xFF0D120E) : const Color(0xFFF7F8F4);
    final textDark = isDark ? Colors.white : const Color(0xFF141E16);
    final textMuted = isDark ? const Color(0xFF8FA395) : const Color(0xFF7A8B7E);

    return Scaffold(
      backgroundColor: canvasBg,
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
                    child: _buildHeader(isDark, textDark, textMuted, isDesktop),
                  ),
                ),

                // Responsive Bento Grid of Animated Visualizations
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  sliver: SliverToBoxAdapter(
                    child: isDesktop
                        ? _buildDesktopGrid()
                        : (isTablet ? _buildTabletGrid() : _buildMobileStack()),
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
    );
  }

  Widget _buildTopNav(bool isDark, FarmProvider farm, bool showCapsule) {
    return Row(
      children: [
        // Sprout Logo Mark
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFF19251B),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.spa,
              size: 20,
              color: Color(0xFF52B788),
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
              foregroundColor: isDark ? const Color(0xFFA6DEAE) : const Color(0xFF1B4D3E),
            ),
          ),

        // Center Capsule Pill Bar
        if (showCapsule)
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161E18) : const Color(0xFFECEFE8),
                    borderRadius: BorderRadius.circular(30),
                  ),
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
                                ? (isDark ? Colors.white : const Color(0xFF151E17))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            pill,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? (isDark ? const Color(0xFF151E17) : Colors.white)
                                  : (isDark ? Colors.white70 : const Color(0xFF5A695E)),
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
            Text(
              'Data Drives Growth',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF52B788),
                letterSpacing: 0.5,
              ),
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
                backgroundColor: isDark ? const Color(0xFF1E2922) : const Color(0xFF17241A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  color: isDark ? const Color(0xFF2E3D32) : const Color(0xFFD6DDD2),
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
