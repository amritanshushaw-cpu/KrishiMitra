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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                      ],
                    ),
                  ),
                ],
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

              // ESP32 Live Edge Node Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.2)
                          : const Color(0x0C1A3E31),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F5EE),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.developer_board_rounded,
                                color: Color(0xFF193E32),
                                size: 19,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.strings.liveEdgeNode,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                                  ),
                                ),
                                Text(
                                  'SoftAP Direct • 192.168.4.1',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 9.5,
                                    color: isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5EE),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF52B788).withValues(alpha: 0.3),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2E7D32),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'ESP32 LIVE',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF193E32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildDeviceRow(
                      context,
                      label: 'OV2640 Cam Stream',
                      value: '15 FPS (1600x1200 UXGA)',
                      icon: Icons.videocam_rounded,
                      bubbleColor: const Color(0xFFE8F5EE),
                      statusColor: const Color(0xFF2E7D32),
                    ),
                    const Divider(height: 20, color: Color(0xFFEEF4F0)),
                    _buildDeviceRow(
                      context,
                      label: 'SoftAP Telemetry Link',
                      value: '12ms Latency (Active)',
                      icon: Icons.wifi_tethering_rounded,
                      bubbleColor: const Color(0xFFE1F5FE),
                      statusColor: const Color(0xFF0288D1),
                    ),
                    const Divider(height: 20, color: Color(0xFFEEF4F0)),
                    _buildDeviceRow(
                      context,
                      label: 'Relay 1 (Irrigation Solenoid)',
                      value: provider.isPumpLocked ? 'Safety Locked (GPIO 16)' : 'Ready / Active',
                      icon: Icons.power_rounded,
                      bubbleColor: const Color(0xFFEDE7F6),
                      statusColor: const Color(0xFF5E35B1),
                    ),
                    const Divider(height: 20, color: Color(0xFFEEF4F0)),
                    _buildDeviceRow(
                      context,
                      label: 'Soil Capacitive ADC',
                      value: 'GPIO 36 • Calibrated',
                      icon: Icons.tune_rounded,
                      bubbleColor: const Color(0xFFFFF3E0),
                      statusColor: const Color(0xFFE65100),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('ESP32 SoftAP Ping: 12ms (Strong RSSI -48 dBm)'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.network_ping_rounded, size: 15),
                            label: Text(
                              provider.strings.pingNode,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                              side: BorderSide(color: isDark ? AppTheme.darkBorder : const Color(0xFFD4E5D9)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              provider.captureAndAnalyze();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Received fresh frame from ESP32 camera node'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.camera_alt_rounded, size: 15),
                            label: Text(
                              provider.strings.captureFrame,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? AppTheme.darkAccentGreen : const Color(0xFF193E32),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                            ),
                          ),
                        ),
                      ],
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
    required Color bubbleColor,
    required Color statusColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bubbleColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: statusColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
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
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
