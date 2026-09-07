import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fresnel/fresnel.dart';
import '../../core/theme/app_theme.dart';
import '../../state/farm_provider.dart';
import '../widgets/app_glass_container.dart';
import '../widgets/farm_health_ring.dart';
import '../widgets/field_zone_card.dart';
import '../widgets/weather_status_bar.dart';

class HomeDashboardTab extends StatelessWidget {
  final VoidCallback onOpenSafetyNet;

  const HomeDashboardTab({super.key, required this.onOpenSafetyNet});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting & Subtitle
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
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          provider.strings.greetingSubtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.25),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getTimeIcon(),
                          color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatSystemTime(),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Farm Health Score Card
              FarmHealthRingCard(
                healthScore: provider.farmHealthScore,
                statusText: provider.farmHealthScore >= 80 ? 'Healthy Farm' : 'Attention Required',
                soilStatus: provider.sensorData.isSoilCriticallyDry
                    ? 'Dry'
                    : (provider.sensorData.isSoilSaturated ? 'Saturated' : 'Good'),
                moistureStatus: '${provider.sensorData.soilMoisture}%',
                onTap: () => provider.setTabIndex(3), // Jump to analytics
              ),
              const SizedBox(height: 14),

              // Ambient Weather & Environment Bar
              WeatherStatusBar(
                sensorData: provider.sensorData,
                activeZone: provider.activeFieldZone,
              ),
              const SizedBox(height: 16),

              // Quick Actions Grid
              Text(
                provider.strings.quickActions,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.camera_enhance_outlined,
                      label: provider.strings.navScan,
                      color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                      onTap: () => provider.setTabIndex(1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.sensors_outlined,
                      label: provider.strings.navSensors,
                      color: AppTheme.skyBlue,
                      onTap: () => provider.setTabIndex(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.analytics_outlined,
                      label: provider.strings.navAdvisory,
                      color: AppTheme.sproutGreen,
                      onTap: () => provider.setTabIndex(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.shield_outlined,
                      label: provider.strings.demoAsset,
                      color: AppTheme.amberWarning,
                      onTap: onOpenSafetyNet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Today's Action Plan
              _buildActionPlanCard(context, provider),
              const SizedBox(height: 14),

              // Data Meets Growth Cockpit Teaser Card (Research Hub)
              _buildCockpitTeaserCard(context, provider),
              const SizedBox(height: 14),

              // Field Zone Card (Area 1: Rice & Tomato Block)
              FieldZoneCard(
                zoneName: provider.activeFieldZone,
                healthScore: provider.farmHealthScore,
                onTap: () => provider.setTabIndex(1),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassContainer(
      radius: 14,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCockpitTeaserCard(BuildContext context, FarmProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassContainer(
      radius: 18,
      hasGoldGlow: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_graph,
                        size: 16,
                        color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.strings.cockpitTitle,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  provider.strings.interactive,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            provider.strings.cockpitDesc,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.4,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => provider.toggleCockpitMode(true),
            icon: const Icon(Icons.arrow_outward, size: 14),
            label: Text(
              provider.strings.openCockpit,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.forestMoss : AppTheme.forestGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPlanCard(BuildContext context, FarmProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRainOverride = provider.fusedAdvisory?.isSprayOverrideActive ?? false;

    return AppGlassContainer(
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.task_alt_outlined,
                      color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.strings.todaysActionPlan,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: (isRainOverride ? AppTheme.amberWarning : AppTheme.emeraldLight)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  isRainOverride ? provider.strings.weatherAlert : provider.strings.optimalCycle,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: isRainOverride ? AppTheme.amberWarning : AppTheme.forestGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            context,
            icon: Icons.check_circle,
            text: provider.sensorData.isSoilCriticallyDry
                ? 'Soil is critically dry — automated irrigation scheduled'
                : (DateTime.now().hour < 11
                    ? 'Morning irrigation scheduled today at 10:30 AM (Soil: ${provider.sensorData.soilMoisture}%)'
                    : 'Irrigate tomorrow at 6:00 AM (Soil moisture: ${provider.sensorData.soilMoisture}%)'),
            isWarning: provider.sensorData.isSoilCriticallyDry,
          ),
          const SizedBox(height: 6),
          _buildActionItem(
            context,
            icon: isRainOverride ? Icons.warning_amber_rounded : Icons.check_circle,
            text: isRainOverride
                ? 'Precipitation detected — Chemical spraying paused to avoid wash-off'
                : 'Weather conditions safe for foliar nutrient absorption',
            isWarning: isRainOverride,
          ),
          const SizedBox(height: 6),
          _buildActionItem(
            context,
            icon: Icons.check_circle,
            text: provider.parsedDiagnosis != null
                ? 'Diagnosis active: ${provider.parsedDiagnosis!.disease.value}'
                : 'Crop foliage healthy with nominal chlorophyll index (0.783 Chl)',
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    bool isWarning = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isWarning
        ? AppTheme.amberWarning
        : (isDark ? AppTheme.emeraldLight : AppTheme.sproutGreen);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getTimeIcon() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) return Icons.wb_sunny_outlined;
    if (hour >= 12 && hour < 17) return Icons.light_mode_outlined;
    if (hour >= 17 && hour < 21) return Icons.wb_twilight_outlined;
    return Icons.bedtime_outlined;
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
