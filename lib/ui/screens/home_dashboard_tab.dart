import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fresnel/fresnel.dart';
import '../../core/theme/app_theme.dart';
import '../../state/farm_provider.dart';
import '../widgets/app_glass_container.dart';
import '../widgets/liquid_glass_container.dart';
import '../widgets/farm_health_ring.dart';
import '../widgets/weather_status_bar.dart';
import 'latest_scan_details_screen.dart';

class HomeDashboardTab extends StatelessWidget {
  const HomeDashboardTab({super.key});

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
                statusText: provider.farmHealthScore >= 80 ? provider.strings.healthyFarm : provider.strings.attentionRequired,
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
                onToggleRain: () {
                  final currentRain = provider.sensorData.rain;
                  provider.injectTelemetry(
                    temp: provider.sensorData.temperature,
                    soil: provider.sensorData.soilMoisture,
                    rain: currentRain == 1 ? 0 : 1,
                  );
                },
                onToggleTemp: () {
                  final currentTemp = provider.sensorData.temperature;
                  provider.injectTelemetry(
                    temp: currentTemp > 35.0 ? 28.5 : 38.5,
                    soil: provider.sensorData.soilMoisture,
                    rain: provider.sensorData.rain,
                  );
                },
                onToggleSoil: () {
                  final currentSoil = provider.sensorData.soilMoisture;
                  // Cycle: 45% (Optimal) -> 15% (Dry alert) -> 82% (Saturated) -> 45%
                  final nextSoil = currentSoil == 45 ? 15 : (currentSoil == 15 ? 82 : 45);
                  provider.injectTelemetry(
                    temp: provider.sensorData.temperature,
                    soil: nextSoil,
                    rain: provider.sensorData.rain,
                  );
                },
                onToggleHumidity: () {
                  final currentHum = provider.sensorData.humidity;
                  // Cycle: 65% (Optimal) -> 92% (High humid) -> 35% (Dry air) -> 65%
                  final nextHum = (currentHum - 65.0).abs() < 1.0
                      ? 92.0
                      : ((currentHum - 92.0).abs() < 1.0 ? 35.0 : 65.0);
                  provider.injectTelemetry(
                    temp: provider.sensorData.temperature,
                    soil: provider.sensorData.soilMoisture,
                    rain: provider.sensorData.rain,
                    humidity: nextHum,
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Pump Control Card
              _buildPumpCard(context, provider),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.sensors_outlined,
                      label: provider.strings.navSensors,
                      color: AppTheme.skyBlue,
                      onTap: () => provider.setTabIndex(2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.analytics_outlined,
                      label: provider.strings.navAdvisory,
                      color: AppTheme.sproutGreen,
                      onTap: () => provider.setTabIndex(3),
                    ),
                  ),
                ],
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

    return AspectRatio(
      aspectRatio: 1.0,
      child: AppGlassContainer(
        radius: 20,
        onTap: onTap,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: color.withValues(alpha: 0.22),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
              ),
            ),
          ],
        ),
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

  
  Widget _buildPumpCard(BuildContext context, FarmProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return LiquidGlassContainer(
      liquidColors: isDark ? [Colors.blueAccent.withValues(alpha: 0.1), Colors.cyan.withValues(alpha: 0.05)] : [Colors.blueAccent.withValues(alpha: 0.15), Colors.cyan.withValues(alpha: 0.05)],
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.strings.waterPumpControl,
                style: GoogleFonts.bricolageGrotesque(
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                provider.isPumpLocked ? provider.strings.pumpIsOn : provider.strings.pumpIsOff,
                style: GoogleFonts.bricolageGrotesque(
                  color: provider.isPumpLocked ? Colors.lightBlue : (isDark ? Colors.white : Colors.black),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => provider.togglePump(),
            style: ElevatedButton.styleFrom(
              backgroundColor: provider.isPumpLocked ? Colors.redAccent.withValues(alpha: 0.8) : Colors.blueAccent.withValues(alpha: 0.8),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(provider.isPumpLocked ? provider.strings.turnOff : provider.strings.turnOn, style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestScanCard(BuildContext context, FarmProvider provider) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LatestScanDetailsScreen()),
        );
      },
      child: LiquidGlassContainer(
        
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.darkAccentGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.document_scanner, color: AppTheme.darkAccentGreen),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.strings.latestAdvice,
                    style: GoogleFonts.bricolageGrotesque(
                      color: AppTheme.darkTextSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.fusedAdvisory?.advisory.nameEn ?? provider.strings.diagComplete,
                    style: GoogleFonts.bricolageGrotesque(
                      color: AppTheme.darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.darkTextSecondary),
          ],
        ),
      ),
    );
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
