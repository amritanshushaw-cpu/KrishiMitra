import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../state/farm_provider.dart';
import '../widgets/smooth_entrance_modal.dart';
import '../widgets/smooth_navigation_transition.dart';
import 'analytics_alerts_tab.dart';
import 'home_dashboard_tab.dart';
import 'profile_settings_tab.dart';
import 'scan_vision_tab.dart';
import 'sensors_iot_tab.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  void _showSafetyNetModal(BuildContext context, FarmProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showSmoothModalSheet(
      context: context,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.darkSurface : AppTheme.mintDew).withValues(alpha: isDark ? 0.96 : 0.94),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppTheme.darkBorder : AppTheme.softSage.withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.strings.safetyNetTitle,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  provider.strings.safetyNetSub,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                _buildDemoTile(
                  context: ctx,
                  code: 'SAMPLE_01',
                  title: 'Tomato // Late Blight (Fungus)',
                  subtitle: 'Triggers active rain spray suspension & pump interlock test',
                  accentColor: AppTheme.alertRose,
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.triggerSafetyNetDemo(assetPath: AppConstants.demoLateBlightAsset);
                    provider.setTabIndex(1); // switch to scan tab
                  },
                ),
                const SizedBox(height: 8),
                _buildDemoTile(
                  context: ctx,
                  code: 'SAMPLE_02',
                  title: 'Potato // Healthy Foliage',
                  subtitle: 'Nominal baseline condition — zero chemical intervention required',
                  accentColor: AppTheme.emeraldLight,
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.triggerSafetyNetDemo(assetPath: AppConstants.demoHealthyAsset);
                    provider.setTabIndex(1);
                  },
                ),
                const SizedBox(height: 8),
                _buildDemoTile(
                  context: ctx,
                  code: 'SAMPLE_03',
                  title: 'Paddy Rice // Leaf Blast',
                  subtitle: 'Magnaporthe oryzae pathogen analysis & bio-fungicide prescription',
                  accentColor: AppTheme.amberWarning,
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.triggerSafetyNetDemo(assetPath: AppConstants.demoRiceBlastAsset);
                    provider.setTabIndex(1);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
},
);
}

  static Widget _buildDemoTile({
    required BuildContext context,
    required String code,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.deepPine.withValues(alpha: 0.50)
              : AppTheme.pureWhite.withValues(alpha: 0.70),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppTheme.softSage.withValues(alpha: 0.20)
                : AppTheme.softSage.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                code,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> tabs = [
      HomeDashboardTab(onOpenSafetyNet: () => _showSafetyNetModal(context, provider)),
      ScanVisionTab(onOpenSafetyNet: () => _showSafetyNetModal(context, provider)),
      const SensorsIotTab(),
      const AnalyticsAlertsTab(),
      ProfileSettingsTab(onOpenSafetyNet: () => _showSafetyNetModal(context, provider)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          decoration: AppTheme.backgroundDecoration(isDark),
          child: Stack(
            children: [
              // Atmospheric Vibrant Backdrop Blooms for Authentic Glassmorphism Depth with Smooth Fade Transition
              AnimatedOpacity(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                opacity: isDark ? 1.0 : 0.0,
                child: Stack(
                  children: [
                    Positioned(
                      top: -60,
                      right: -50,
                      child: IgnorePointer(
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.darkAccentGreen.withValues(alpha: 0.14),
                                AppTheme.darkAccentGreen.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 360,
                      left: -60,
                      child: IgnorePointer(
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.darkAccentBlue.withValues(alpha: 0.10),
                                AppTheme.darkAccentBlue.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              titleSpacing: 16,
              title: Row(
                children: [
                  // User Avatar with Online Pulse Indicator
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppTheme.vibrantEmerald, AppTheme.forestMoss],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.8),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.vibrantEmerald.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppTheme.neonMint,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppTheme.midnightTeal : Colors.white,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neonMint.withValues(alpha: 0.8),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KrishiMitra Pro',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppTheme.neonMint.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'OFFLINE EDGE',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppTheme.neonMint : AppTheme.forestMoss,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                // Theme switch with smooth CSS-style rotate & scale transition
                IconButton(
                  tooltip: 'Toggle Theme Mode',
                  onPressed: () => provider.toggleTheme(),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return RotationTransition(
                        turns: Tween<double>(begin: 0.75, end: 1.0).animate(animation),
                        child: FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(scale: animation, child: child),
                        ),
                      );
                    },
                    child: Icon(
                      isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                      key: ValueKey<bool>(isDark),
                      size: 20,
                      color: isDark ? AppTheme.neonMint : AppTheme.forestGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: SmoothNavigationTransition(
              currentIndex: provider.activeTabIndex,
              duration: const Duration(milliseconds: 300),
              fadeDuration: const Duration(milliseconds: 200),
              maxBlur: 10.0,
              children: tabs,
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 18),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF141414) : Colors.white).withValues(alpha: isDark ? 0.76 : 0.88),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: (isDark ? const Color(0xFFFFFFFF).withValues(alpha: 0.12) : const Color(0x141A3E31)),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.black : AppTheme.midnightTeal).withValues(alpha: isDark ? 0.50 : 0.14),
                          blurRadius: 24,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(
                            context: context,
                            index: 0,
                            icon: Icons.home_outlined,
                            selectedIcon: Icons.home_rounded,
                            label: provider.strings.navHome,
                            isSelected: provider.activeTabIndex == 0,
                            onTap: () => provider.setTabIndex(0),
                          ),
                          _buildNavItem(
                            context: context,
                            index: 1,
                            icon: Icons.camera_enhance_outlined,
                            selectedIcon: Icons.camera_enhance_rounded,
                            label: provider.strings.navScan,
                            isSelected: provider.activeTabIndex == 1,
                            onTap: () => provider.setTabIndex(1),
                          ),
                          _buildNavItem(
                            context: context,
                            index: 2,
                            icon: Icons.sensors_outlined,
                            selectedIcon: Icons.sensors_rounded,
                            label: provider.strings.navSensors,
                            isSelected: provider.activeTabIndex == 2,
                            onTap: () => provider.setTabIndex(2),
                          ),
                          _buildNavItem(
                            context: context,
                            index: 3,
                            icon: Icons.psychology_outlined,
                            selectedIcon: Icons.psychology_rounded,
                            label: provider.strings.navAdvisory,
                            isSelected: provider.activeTabIndex == 3,
                            onTap: () => provider.setTabIndex(3),
                          ),
                          _buildNavItem(
                            context: context,
                            index: 4,
                            icon: Icons.person_outline,
                            selectedIcon: Icons.person_rounded,
                            label: provider.strings.navProfile,
                            isSelected: provider.activeTabIndex == 4,
                            onTap: () => provider.setTabIndex(4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  },
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isSelected) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? const [AppTheme.darkAccentGreen, Color(0xFF059669)]
                  : const [AppTheme.vibrantEmerald, AppTheme.forestMoss],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppTheme.darkAccentGreen : AppTheme.vibrantEmerald).withValues(alpha: 0.40),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selectedIcon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextMuted,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
