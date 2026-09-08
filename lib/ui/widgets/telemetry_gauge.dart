import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sensor_data.dart';
import '../../services/ble_service.dart';
import 'app_glass_container.dart';

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

    return AppGlassContainer(
      isLiquid: true,
      radius: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: bleState == BleConnectionState.connected
                          ? AppTheme.vibrantEmerald
                          : (bleState == BleConnectionState.simulated ? const Color(0xFF0284C7) : AppTheme.lightTextMuted),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LIVE SENSOR TELEMETRY',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F),
                    ),
                  ),
                ],
              ),
              _buildBleBadge(isDark),
            ],
          ),
          const SizedBox(height: 16),
          // Row 1: Air Temp & Air Humidity
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'Air Temp',
                  value: '${data.temperature.toStringAsFixed(1)}°C',
                  subtext: data.temperature > 35 ? 'High' : 'Optimal',
                  icon: Icons.thermostat_rounded,
                  bubbleColor: const Color(0xFFFFF3E0),
                  iconColor: const Color(0xFFE65100),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'Air Humidity',
                  value: '${data.humidity.toStringAsFixed(1)}%',
                  subtext: data.humidity > 80
                      ? 'Humid'
                      : (data.humidity < 40 ? 'Dry' : 'Optimal'),
                  icon: Icons.water_drop_outlined,
                  bubbleColor: const Color(0xFFE0F2F1),
                  iconColor: const Color(0xFF00897B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Row 2: Soil Moisture & Precipitation (Interactive)
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  label: 'Soil Moisture',
                  value: '${data.soilMoisture}%',
                  subtext: data.isSoilCriticallyDry
                      ? 'Dry'
                      : (data.isSoilSaturated ? 'High' : 'Optimal'),
                  icon: Icons.grass_rounded,
                  bubbleColor: const Color(0xFFE1F5FE),
                  iconColor: const Color(0xFF0288D1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onToggleRainMock,
                    borderRadius: BorderRadius.circular(16),
                    child: _buildMetricTile(
                      context,
                      label: 'Precipitation',
                      value: data.isRaining ? 'Rain' : 'Dry',
                      subtext: data.isRaining ? 'Active (Tap)' : 'Clear (Tap)',
                      icon: data.isRaining ? Icons.thunderstorm_rounded : Icons.wb_sunny_rounded,
                      bubbleColor: data.isRaining ? const Color(0xFFEDE7F6) : const Color(0xFFE8F5E9),
                      iconColor: data.isRaining ? const Color(0xFF5E35B1) : const Color(0xFF2E7D32),
                      isInteractive: true,
                    ),
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
        badgeColor = isDark ? AppTheme.neonMint : const Color(0xFF1B4D3E);
        label = 'BLE CONNECTED';
        break;
      case BleConnectionState.simulated:
        badgeColor = isDark ? AppTheme.skyBlue : const Color(0xFF0284C7);
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
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
    required Color bubbleColor,
    required Color iconColor,
    bool isInteractive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool isWarning = subtext.toLowerCase().contains('high') ||
        subtext.toLowerCase().contains('dry') ||
        subtext.toLowerCase().contains('active');

    final Color badgeColor = isDark
        ? (isWarning ? AppTheme.amberWarning : AppTheme.neonMint)
        : (isWarning ? const Color(0xFFB45309) : const Color(0xFF193E32));

    final Color badgeBg = isDark
        ? (isWarning
            ? AppTheme.amberWarning.withValues(alpha: 0.18)
            : AppTheme.neonMint.withValues(alpha: 0.18))
        : (isWarning ? const Color(0xFFFEF3C7) : const Color(0xFFE8F5EE));

    final Color badgeBorder = isDark
        ? (isWarning
            ? AppTheme.amberWarning.withValues(alpha: 0.35)
            : AppTheme.neonMint.withValues(alpha: 0.35))
        : Colors.transparent;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkSurfaceElevated.withValues(alpha: 0.85)
            : const Color(0xFFF9FBF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFFFFFFFF).withValues(alpha: 0.10)
              : const Color(0xFFE3EDE5),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isDark ? iconColor.withValues(alpha: 0.20) : bubbleColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (isDark ? iconColor : bubbleColor).withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: isDark ? (isWarning ? AppTheme.amberWarning : AppTheme.neonMint) : iconColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: badgeBorder,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  subtext,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.0,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.darkTextMuted : const Color(0xFF7A9E93),
            ),
          ),
        ],
      ),
    );
  }
}
