import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sensor_data.dart';
import 'app_glass_container.dart';

/// Farm Environment Overview Widget
/// High-aesthetic 2x2 Bento Grid presentation of real IoT environmental telemetry,
/// inspired by premium modern agriculture app designs.
class WeatherStatusBar extends StatelessWidget {
  final SensorData sensorData;
  final String activeZone;

  const WeatherStatusBar({
    super.key,
    required this.sensorData,
    this.activeZone = 'Area 1: Rice & Tomato Field',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final moistureColor = sensorData.isSoilCriticallyDry
        ? AppTheme.alertRose
        : (sensorData.isSoilSaturated ? AppTheme.amberWarning : AppTheme.skyBlue);

    final moistureStatus = sensorData.isSoilCriticallyDry
        ? 'Dry Alert'
        : (sensorData.isSoilSaturated ? 'Saturated' : 'Optimal');

    final rainColor = sensorData.isRaining ? AppTheme.skyBlue : AppTheme.sproutGreen;
    final rainStatus = sensorData.isRaining ? 'Precipitation' : 'Clear Sky';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with Live Telemetry Pulse
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppTheme.neonMint,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonMint,
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'FARM ENVIRONMENT OVERVIEW',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.neonMint : AppTheme.forestGreen).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: (isDark ? AppTheme.neonMint : AppTheme.forestGreen).withValues(alpha: 0.25),
                  width: 0.8,
                ),
              ),
              child: Text(
                'LIVE TELEMETRY',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.neonMint : AppTheme.forestGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 2x2 Bento Grid of Environmental Metrics
        Row(
          children: [
            // 1. Soil Moisture Card
            Expanded(
              child: _buildMetricTile(
                context,
                title: 'Soil Moisture',
                value: '${sensorData.soilMoisture}%',
                status: moistureStatus,
                icon: Icons.water_drop_rounded,
                accentColor: moistureColor,
                progressPercent: (sensorData.soilMoisture / 100.0).clamp(0.0, 1.0),
              ),
            ),
            const SizedBox(width: 10),
            // 2. Air Temperature Card
            Expanded(
              child: _buildMetricTile(
                context,
                title: 'Air Temp',
                value: '${sensorData.temperature.toStringAsFixed(1)}°C',
                status: (DateTime.now().hour >= 5 && DateTime.now().hour < 18) ? 'Daytime' : 'Night Cycle',
                icon: (DateTime.now().hour >= 5 && DateTime.now().hour < 18)
                    ? Icons.wb_sunny_rounded
                    : Icons.nightlight_round,
                accentColor: AppTheme.ambientSunlight,
                progressPercent: (sensorData.temperature / 45.0).clamp(0.0, 1.0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // 3. Humidity Card
            Expanded(
              child: _buildMetricTile(
                context,
                title: 'Humidity',
                value: '${sensorData.humidity.toStringAsFixed(1)}%',
                status: 'Air Moisture',
                icon: Icons.air_rounded,
                accentColor: AppTheme.vibrantEmerald,
                progressPercent: (sensorData.humidity / 100.0).clamp(0.0, 1.0),
              ),
            ),
            const SizedBox(width: 10),
            // 4. Rain & Precipitation Card
            Expanded(
              child: _buildMetricTile(
                context,
                title: 'Rain / Sky',
                value: sensorData.isRaining ? 'RAINING' : '0.0 mm',
                status: rainStatus,
                icon: sensorData.isRaining ? Icons.thunderstorm_rounded : Icons.cloud_outlined,
                accentColor: rainColor,
                progressPercent: sensorData.isRaining ? 0.90 : 0.05,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required String status,
    required IconData icon,
    required Color accentColor,
    required double progressPercent,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassContainer(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withValues(alpha: 0.24),
                      accentColor.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.35),
                    width: 1.0,
                  ),
                ),
                child: Icon(icon, color: accentColor, size: 19),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
          ),
          const SizedBox(height: 10),

          // Mini Gradient Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  height: 4,
                  width: double.infinity,
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                ),
                FractionallySizedBox(
                  widthFactor: progressPercent,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withValues(alpha: 0.6),
                          accentColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
