import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sensor_data.dart';

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
          width: 1.0,
        ),
      ),
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
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.emeraldLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'FARM ENVIRONMENT OVERVIEW',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
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
                  color: (isDark ? AppTheme.emeraldLight : AppTheme.sproutGreen).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'CONDITIONS STABLE',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildWeatherMetric(
                context,
                icon: (DateTime.now().hour >= 5 && DateTime.now().hour < 18)
                    ? Icons.wb_sunny_outlined
                    : Icons.nightlight_round,
                label: 'AIR TEMP',
                value: '${sensorData.temperature.toStringAsFixed(1)}°C',
                sublabel: (DateTime.now().hour >= 5 && DateTime.now().hour < 18) ? 'Daytime' : 'Night Cycle',
              ),
              _buildDivider(context),
              _buildWeatherMetric(
                context,
                icon: Icons.water_drop_outlined,
                label: 'SOIL MOIST',
                value: '${sensorData.soilMoisture}%',
                sublabel: sensorData.isSoilCriticallyDry
                    ? 'Dry Alert'
                    : (sensorData.isSoilSaturated ? 'Saturated' : 'Optimal'),
              ),
              _buildDivider(context),
              _buildWeatherMetric(
                context,
                icon: sensorData.isRaining ? Icons.thunderstorm_outlined : Icons.air_outlined,
                label: 'PRECIPITATION',
                value: sensorData.isRaining ? 'RAINING' : '0.0 mm',
                sublabel: sensorData.isRaining ? 'Spray Alert' : 'Clear Sky',
                highlightColor: sensorData.isRaining ? AppTheme.skyBlue : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 32,
      width: 1,
      color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
      margin: const EdgeInsets.symmetric(horizontal: 10),
    );
  }

  Widget _buildWeatherMetric(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String sublabel,
    Color? highlightColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final valueColor = highlightColor ?? (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 13,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: valueColor,
            ),
          ),
          Text(
            sublabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
