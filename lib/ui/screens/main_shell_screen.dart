import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../state/farm_provider.dart';
import 'analytics_alerts_tab.dart';
import 'auth_screen.dart';
import 'home_dashboard_tab.dart';
import 'profile_settings_tab.dart';
import 'farm_tools_hub_screen.dart';
import 'history_log_tab.dart';
import 'scan_vision_tab.dart';
import 'sensors_iot_tab.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  void _showSafetyNetModal(BuildContext context, FarmProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.deepPine : AppTheme.mintDew).withValues(alpha: isDark ? 0.90 : 0.94),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppTheme.softSage.withValues(alpha: 0.3) : AppTheme.softSage.withValues(alpha: 0.45),
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
      const HistoryLogTab(),
      const FarmToolsHubScreen(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: AppTheme.backgroundDecoration(isDark),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.strings.authTitle,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
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
              // Logout
              IconButton(
                icon: Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
                tooltip: 'Logout',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext ctx) {
                      return AlertDialog(
                        backgroundColor: isDark ? AppTheme.deepPine : AppTheme.mintDew,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text(
                          'Confirm Logout',
                          style: GoogleFonts.jetBrainsMono(
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to logout?',
                          style: GoogleFonts.plusJakartaSans(
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            fontSize: 14,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.plusJakartaSans(
                                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
                            },
                            child: Text(
                              'Logout',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.amberWarning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: IndexedStack(
            index: provider.activeTabIndex,
            children: tabs,
          ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.deepPine : AppTheme.mintDew).withValues(alpha: isDark ? 0.78 : 0.88),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? AppTheme.softSage.withValues(alpha: 0.20)
                      : AppTheme.softSage.withValues(alpha: 0.32),
                  width: 1.0,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.35) : AppTheme.deepPine.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -3),
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
                  index: 6,
                  icon: Icons.calculate_outlined,
                  selectedIcon: Icons.calculate,
                  label: 'Calculators',
                  isSelected: provider.activeTabIndex == 6,
                  onTap: () => provider.setTabIndex(6),
                ),
                _buildNavItem(
                  context: context,
                  index: 5,
                  icon: Icons.history_outlined,
                  selectedIcon: Icons.history,
                  label: provider.strings.navHistory,
                  isSelected: provider.activeTabIndex == 5,
                  onTap: () => provider.setTabIndex(5),
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
