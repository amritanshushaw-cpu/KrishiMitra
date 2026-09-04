import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../state/farm_provider.dart';
import 'analytics_alerts_tab.dart';
import 'data_meets_growth_cockpit_screen.dart';
import 'home_dashboard_tab.dart';
import 'profile_settings_tab.dart';
import 'scan_vision_tab.dart';
import 'sensors_iot_tab.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  void _showSafetyNetModal(BuildContext context, FarmProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
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
                          'HARDWARE BYPASS // PITCH SAFETY NET',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
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
                  'Instantly inject high-res leaf assets to test offline neural diagnosis without requiring live ESP32 camera Wi-Fi.',
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F1A13) : const Color(0xFFF7FAF7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
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
        final isWideScreen = constraints.maxWidth >= 920;

        // Auto-show Desktop/Tablet Cockpit on wide screens OR when user toggles it
        if (isWideScreen || provider.isCockpitMode) {
          return DataMeetsGrowthCockpitScreen(
            onBackToMobile: () => provider.toggleCockpitMode(false),
          );
        }

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            title: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.spa_outlined,
                    color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KRISHIMITRA // AI',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: AppTheme.emeraldLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          provider.strings.offlineTag,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              // Data Meets Growth Cockpit Trigger
              IconButton(
                icon: Icon(
                  Icons.auto_graph,
                  size: 20,
                  color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                ),
                tooltip: 'Research Hub / Cockpit Mode',
                onPressed: () => provider.toggleCockpitMode(true),
              ),
              // Theme switch
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  size: 20,
                  color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                ),
                tooltip: 'Toggle Theme Mode',
                onPressed: () => provider.toggleTheme(),
              ),
              // Pitch Safety Net
              IconButton(
                icon: Icon(
                  Icons.shield_outlined,
                  size: 20,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
                tooltip: 'Pitch Safety Net (Hardware Bypass)',
                onPressed: () => _showSafetyNetModal(context, provider),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: IndexedStack(
            index: provider.activeTabIndex,
            children: tabs,
          ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  index: 0,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: provider.strings.navHome,
                  isSelected: provider.activeTabIndex == 0,
                  onTap: () => provider.setTabIndex(0),
                ),
                _buildNavItem(
                  context: context,
                  index: 1,
                  icon: Icons.camera_enhance_outlined,
                  selectedIcon: Icons.camera_enhance,
                  label: provider.strings.navScan,
                  isSelected: provider.activeTabIndex == 1,
                  onTap: () => provider.setTabIndex(1),
                ),
                _buildNavItem(
                  context: context,
                  index: 2,
                  icon: Icons.sensors_outlined,
                  selectedIcon: Icons.sensors,
                  label: provider.strings.navSensors,
                  isSelected: provider.activeTabIndex == 2,
                  onTap: () => provider.setTabIndex(2),
                ),
                _buildNavItem(
                  context: context,
                  index: 3,
                  icon: Icons.psychology_outlined,
                  selectedIcon: Icons.psychology,
                  label: provider.strings.navAdvisory,
                  isSelected: provider.activeTabIndex == 3,
                  onTap: () => provider.setTabIndex(3),
                ),
                _buildNavItem(
                  context: context,
                  index: 4,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: provider.strings.navProfile,
                  isSelected: provider.activeTabIndex == 4,
                  onTap: () => provider.setTabIndex(4),
                ),
              ],
            ),
          ),
        ),
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
    final primaryColor = isDark ? AppTheme.emeraldLight : AppTheme.forestGreen;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected
                  ? primaryColor
                  : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? primaryColor
                    : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
