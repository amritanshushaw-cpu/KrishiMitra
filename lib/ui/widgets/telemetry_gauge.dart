import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sensor_data.dart';
import '../../services/ble_service.dart';

class TelemetryGauge extends StatelessWidget {
  final SensorData data;
  final BleConnectionState bleState;
  final VoidCallback onToggleRainMock;

  const TelemetryGauge({
    super.key,
    required this.data,
    required this.bleState,
    required this.onToggleRainMock,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : const Color(0xFF1B4D3E).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
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
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: bleState == BleConnectionState.connected
                            ? AppTheme.emeraldLight
                            : (bleState == BleConnectionState.simulated ? Colors.cyan : AppTheme.lightTextMuted),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'TELEMETRY // ESP32_STREAM',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              _buildBleBadge(isDark),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Temperature Metric Tile
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'TEMP',
                  value: '${data.temperature.toStringAsFixed(1)}°C',
                  subtext: data.temperature > 35 ? 'HIGH THERMAL' : 'NOMINAL',
                  icon: Icons.thermostat_outlined,
                  accentColor: data.temperature > 35
                      ? AppTheme.amberWarning
                      : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                ),
              ),
              const SizedBox(width: 8),
              // Soil Moisture Metric Tile
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'SOIL MOIST',
                  value: '${data.soilMoisture}%',
                  subtext: data.isSoilCriticallyDry
                      ? 'CRITICAL DRY'
                      : (data.isSoilSaturated ? 'SATURATED' : 'OPTIMAL'),
                  icon: Icons.water_drop_outlined,
                  accentColor: data.isSoilCriticallyDry
                      ? AppTheme.amberWarning
                      : (data.isSoilSaturated ? AppTheme.skyBlue : (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen)),
                ),
              ),
              const SizedBox(width: 8),
              // Rain State Metric Tile (Interactive Toggle)
              Expanded(
                child: InkWell(
                  onTap: onToggleRainMock,
                  borderRadius: BorderRadius.circular(10),
                  child: _buildMetricTile(
                    context,
                    label: 'RAIN STATE',
                    value: data.isRaining ? 'RAINING' : 'DRY',
                    subtext: 'TAP TO TOGGLE',
                    icon: data.isRaining ? Icons.thunderstorm_outlined : Icons.wb_sunny_outlined,
                    accentColor: data.isRaining
                        ? AppTheme.skyBlue
                        : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                    isInteractive: true,
                    isActive: data.isRaining,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBleBadge(bool isDark) {
    Color badgeColor;
    String label;

    switch (bleState) {
      case BleConnectionState.connected:
        badgeColor = isDark ? AppTheme.emeraldLight : AppTheme.forestGreen;
        label = 'BLE ACTIVE';
        break;
      case BleConnectionState.simulated:
        badgeColor = Colors.cyan;
        label = 'OFFLINE SIM';
        break;
      case BleConnectionState.scanning:
      case BleConnectionState.connecting:
        badgeColor = AppTheme.amberWarning;
        label = 'SEARCHING';
        break;
      case BleConnectionState.disconnected:
        badgeColor = isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted;
        label = 'STANDBY';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    required String subtext,
    required IconData icon,
    required Color accentColor,
    bool isInteractive = false,
    bool isActive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C140F) : const Color(0xFFF7FAF7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive
              ? AppTheme.skyBlue
              : (isDark ? AppTheme.darkBorder : AppTheme.sageBorder),
          width: isActive ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                icon,
                size: 13,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtext,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              color: isInteractive
                  ? (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen)
                  : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
            ),
          ),
        ],
      ),
    );
  }
}
