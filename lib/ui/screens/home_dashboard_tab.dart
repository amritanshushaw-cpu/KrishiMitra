import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../state/farm_provider.dart';
import '../widgets/app_glass_container.dart';
import '../widgets/farm_health_ring.dart';
import '../widgets/smooth_entrance_modal.dart';
import '../widgets/weather_status_bar.dart';
import 'farm_tools_hub_screen.dart';

/// Home Dashboard Tab
/// Faithful realization of the soothing Plant Tracker UI aesthetic (Viktoriia Push style).
class HomeDashboardTab extends StatelessWidget {
  final VoidCallback onOpenSafetyNet;

  const HomeDashboardTab({super.key, required this.onOpenSafetyNet});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      key: const PageStorageKey('home_dashboard_scroll_key'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Center(
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Greeting & System Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.strings.greetingFarmer,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            provider.strings.greetingSubtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              color: isDark ? AppTheme.darkTextMuted : const Color(0xFF5A937D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FarmToolsHubScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.neonMint.withValues(alpha: 0.12)
                              : const Color(0xFFE8F5EE),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.neonMint.withValues(alpha: 0.3)
                                : const Color(0xFF52B788).withValues(alpha: 0.3),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calculate_rounded,
                              color: isDark ? AppTheme.neonMint : const Color(0xFF2D6A4F),
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tools',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppTheme.neonMint : const Color(0xFF2D6A4F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.neonMint.withValues(alpha: 0.12)
                            : const Color(0xFFE8F5EE),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? AppTheme.neonMint.withValues(alpha: 0.3)
                              : const Color(0xFF52B788).withValues(alpha: 0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTimeIcon(),
                            color: isDark ? AppTheme.neonMint : const Color(0xFF2D6A4F),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatSystemTime(),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppTheme.neonMint : const Color(0xFF2D6A4F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 1. Plant Vitality Card (Viktoriia Push inspired circular score card)
                FarmHealthRingCard(
                  healthScore: provider.farmHealthScore,
                  statusText: provider.farmHealthScore >= 80 ? 'Healthy Farm' : 'Attention Required',
                  soilStatus: provider.sensorData.isSoilCriticallyDry
                      ? 'Dry'
                      : (provider.sensorData.isSoilSaturated ? 'Saturated' : 'Good'),
                  moistureStatus: '${provider.sensorData.soilMoisture}%',
                  onTap: () => provider.setTabIndex(3),
                ),
                const SizedBox(height: 16),

                // 2. Farm Environment Vital Signals (2x2 Bento Grid)
                WeatherStatusBar(
                  sensorData: provider.sensorData,
                  activeZone: provider.activeFieldZone,
                ),
                const SizedBox(height: 20),

                // 3. Quick Plant Actions
                Text(
                  provider.strings.quickActions,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: isDark ? AppTheme.darkTextMuted : const Color(0xFF5A937D),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.camera_enhance_rounded,
                        label: 'Scan Leaf',
                        bubbleColor: const Color(0xFFE2F3EA),
                        iconColor: const Color(0xFF1B4332),
                        onTap: () => provider.setTabIndex(1),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.sensors_rounded,
                        label: 'IoT Sensors',
                        bubbleColor: const Color(0xFFE0F2FE),
                        iconColor: const Color(0xFF0369A1),
                        onTap: () => provider.setTabIndex(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        icon: Icons.psychology_rounded,
                        label: 'AI Advisory',
                        bubbleColor: const Color(0xFFECFDF5),
                        iconColor: const Color(0xFF047857),
                        onTap: () => provider.setTabIndex(3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 4. Agronomic Calculators (Plantix-Inspired Suite)
                _buildCalculatorsSection(context, isDark),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color bubbleColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassContainer(
      radius: 20,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? iconColor.withValues(alpha: 0.18) : bubbleColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: (isDark ? iconColor : bubbleColor).withValues(alpha: 0.4),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: isDark ? AppTheme.neonMint : iconColor,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF1B4332),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'AGRONOMIC CALCULATORS',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: isDark ? AppTheme.darkTextMuted : const Color(0xFF5A937D),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5EE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'PLANTIX ENGINE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF193E32),
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.push(
                context,
                SmoothEntrancePageRoute(child: const FarmToolsHubScreen(initialTabIndex: 0)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  'OPEN ALL (3)',
                  style: GoogleFonts.plusJakartaSans(
                     fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.neonMint : const Color(0xFF193E32),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 3 Cards: NPK Fertilizer, Spray Tank, Farming Economics
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCalcCard(
                context,
                title: 'NPK Fertilizer',
                subtitle: 'Urea, DAP, MOP bag counts & ICAR split schedule',
                tag: 'NUTRIENTS',
                icon: Icons.spa_rounded,
                bubbleColor: const Color(0xFFE8F5EE),
                iconColor: const Color(0xFF193E32),
                tagColor: const Color(0xFF193E32),
                onTap: () => Navigator.push(
                  context,
                  SmoothEntrancePageRoute(child: const FarmToolsHubScreen(initialTabIndex: 0)),
                ),
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _buildCalcCard(
                context,
                title: 'Spray & Pesticide',
                subtitle: 'Knapsack tank dilution & PHI safety waiting days',
                tag: 'DILUTION',
                icon: Icons.sanitizer_rounded,
                bubbleColor: const Color(0xFFE1F5FE),
                iconColor: const Color(0xFF0288D1),
                tagColor: const Color(0xFF0288D1),
                onTap: () => Navigator.push(
                  context,
                  SmoothEntrancePageRoute(child: const FarmToolsHubScreen(initialTabIndex: 1)),
                ),
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _buildCalcCard(
                context,
                title: 'Farming Economics',
                subtitle: 'No-loss price, required yield & estimated profit ROI',
                tag: 'NO-LOSS ROI',
                icon: Icons.trending_up_rounded,
                bubbleColor: const Color(0xFFFFF3E0),
                iconColor: const Color(0xFFE65100),
                tagColor: const Color(0xFFE65100),
                onTap: () => Navigator.push(
                  context,
                  SmoothEntrancePageRoute(child: const FarmToolsHubScreen(initialTabIndex: 2)),
                ),
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalcCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String tag,
    required IconData icon,
    required Color bubbleColor,
    required Color iconColor,
    required Color tagColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return AppGlassContainer(
      width: 220,
      radius: 18,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: tagColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: tagColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F),
                height: 1.3,
              ),
            ),
          ],
        ),
      );
    }

  IconData _getTimeIcon() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) return Icons.wb_sunny_rounded;
    if (hour >= 12 && hour < 17) return Icons.light_mode_rounded;
    if (hour >= 17 && hour < 21) return Icons.wb_twilight_rounded;
    return Icons.bedtime_rounded;
  }

  String _formatSystemTime() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:$minute $period';
  }
}
