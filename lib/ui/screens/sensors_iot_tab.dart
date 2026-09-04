import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../state/farm_provider.dart';
import '../widgets/pump_control_toggle.dart';
import '../widgets/telemetry_gauge.dart';

class SensorsIotTab extends StatelessWidget {
  const SensorsIotTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                provider.strings.sensorTelemetry,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                provider.strings.smartIrrigation,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                ),
              ),
              const SizedBox(height: 14),

              // Telemetry Gauge Card
              TelemetryGauge(
                data: provider.sensorData,
                bleState: provider.bleState,
                onToggleRainMock: () {
                  final currentRain = provider.sensorData.rain;
                  provider.injectTelemetry(
                    temp: provider.sensorData.temperature,
                    soil: provider.sensorData.soilMoisture,
                    rain: currentRain == 1 ? 0 : 1,
                  );
                },
              ),
              const SizedBox(height: 14),

              // Pump Control Relay Card
              PumpControlToggle(
                isLocked: provider.isPumpLocked,
                autoReason: provider.fusedAdvisory?.recommendedPumpAction == 'LOCK'
                    ? 'Interlocked: Blight spore propagation mitigation'
                    : null,
                onToggle: () => provider.togglePump(),
              ),
              const SizedBox(height: 16),

              // ESP32 Hardware Status Card (Screen 13 in README)
              Container(
                padding: const EdgeInsets.all(16),
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
                        Row(
                          children: [
                            Icon(
                              Icons.memory_outlined,
                              color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ESP32 HARDWARE NODE DIAGNOSTICS',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.emeraldLight.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ONLINE',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildDeviceRow(
                      context,
                      label: 'Node Power',
                      value: '94% Li-Ion (Nominal)',
                      icon: Icons.battery_charging_full_outlined,
                      statusColor: AppTheme.emeraldLight,
                    ),
                    const Divider(height: 16),
                    _buildDeviceRow(
                      context,
                      label: 'Bluetooth LE Telemetry',
                      value: 'UUID 4fafc201 (Active)',
                      icon: Icons.bluetooth_outlined,
                      statusColor: AppTheme.skyBlue,
                    ),
                    const Divider(height: 16),
                    _buildDeviceRow(
                      context,
                      label: 'Wi-Fi SoftAP Node',
                      value: '192.168.4.1 (OV2640)',
                      icon: Icons.wifi_outlined,
                      statusColor: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                    const Divider(height: 16),
                    _buildDeviceRow(
                      context,
                      label: 'Soil Capacitive Probe',
                      value: 'Calibrated (0-100%)',
                      icon: Icons.tune_outlined,
                      statusColor: AppTheme.sproutGreen,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color statusColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 16, color: statusColor),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
