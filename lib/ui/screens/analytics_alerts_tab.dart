import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/parsed_diagnosis.dart';
import '../../state/farm_provider.dart';
import 'diagnosis_detail_screen.dart';

class AnalyticsAlertsTab extends StatelessWidget {
  const AnalyticsAlertsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fused = provider.fusedAdvisory;

    final List<Map<String, dynamic>> activeAlerts = [];

    // 1. Fused Advisory Alert
    if (fused != null) {
      activeAlerts.add({
        'title': 'Agronomic Advisory Active',
        'time': 'Active Protocol',
        'severity': fused.recommendedPumpAction == 'LOCK' ? 'CRITICAL' : 'HIGH',
        'severityColor': fused.recommendedPumpAction == 'LOCK' ? AppTheme.alertRose : AppTheme.amberWarning,
        'action': fused.effectiveChemicalTreatmentEn.isNotEmpty
            ? fused.effectiveChemicalTreatmentEn
            : (fused.advisory.nameEn.isNotEmpty
                ? fused.advisory.nameEn
                : 'Foliar spray recommendation and irrigation lock applied.'),
        'icon': Icons.medical_services_outlined,
      });
    }

    // 2. Heavy Rain Detection
    if (provider.sensorData.isRaining) {
      activeAlerts.add({
        'title': 'Heavy Rain Detected // Spraying Paused',
        'time': 'Live Sensor',
        'severity': 'WARNING',
        'severityColor': AppTheme.amberWarning,
        'action': 'Foliar chemical sprays suspended to prevent runoff into soil and waterways.',
        'icon': Icons.thunderstorm_outlined,
      });
    }

    // 3. Soil Moisture Anomalies
    if (provider.sensorData.isSoilCriticallyDry) {
      activeAlerts.add({
        'title': 'Soil Drought Stress',
        'time': 'Live Telemetry',
        'severity': 'CRITICAL',
        'severityColor': AppTheme.alertRose,
        'action': 'Soil moisture dropped to ${provider.sensorData.soilMoisture}%. Irrigation recommended.',
        'icon': Icons.water_drop_outlined,
      });
    } else if (provider.sensorData.isSoilSaturated) {
      activeAlerts.add({
        'title': 'Soil Waterlogging Alert',
        'time': 'Live Telemetry',
        'severity': 'WARNING',
        'severityColor': AppTheme.amberWarning,
        'action': 'Soil moisture high at ${provider.sensorData.soilMoisture}%. Inspect field drainage.',
        'icon': Icons.water_drop_outlined,
      });
    }

    // 4. Crop Disease Pathogen Detected
    if (provider.parsedDiagnosis != null &&
        (provider.parsedDiagnosis!.disease.status == ParameterStatus.critical ||
         provider.parsedDiagnosis!.disease.status == ParameterStatus.warning)) {
      final diseaseName = provider.parsedDiagnosis!.disease.value.isNotEmpty
          ? provider.parsedDiagnosis!.disease.value
          : "Pathogen Detected";
      final isCrit = provider.parsedDiagnosis!.disease.status == ParameterStatus.critical;
      activeAlerts.add({
        'title': 'Pathogen Detected: $diseaseName',
        'time': 'Vision Scan',
        'severity': isCrit ? 'CRITICAL' : 'WARNING',
        'severityColor': isCrit ? AppTheme.alertRose : AppTheme.amberWarning,
        'action': 'Pathogen identified on crop foliage. Review ICAR prescription remedies.',
        'icon': Icons.coronavirus_outlined,
      });
    }

    // 5. Irrigation Pump Locked
    if (provider.isPumpLocked) {
      activeAlerts.add({
        'title': 'Irrigation Pump Locked',
        'time': 'Safety Interlock',
        'severity': 'INTERLOCKED',
        'severityColor': AppTheme.alertRose,
        'action': 'Pump lock engaged by system rules to prevent spore propagation.',
        'icon': Icons.lock_outline_rounded,
      });
    }

    // 6. High Heat Stress
    if (provider.sensorData.temperature > 40.0) {
      activeAlerts.add({
        'title': 'Heat Stress Alert',
        'time': 'Live Sensor',
        'severity': 'WARNING',
        'severityColor': AppTheme.amberWarning,
        'action': 'Ambient temperature ${provider.sensorData.temperature.toStringAsFixed(1)}°C exceeds threshold.',
        'icon': Icons.thermostat_outlined,
      });
    }

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
                          'Analytics & Advisory Alerts',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Deterministic ICAR/FAO Sensor-Fusion Guidance',
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

              // Fused Advisory Banner (or Empty Advisory State)
              if (fused != null)
                _buildFusedAdvisoryCard(context, provider)
              else
                _buildNoAdvisoryCard(context, provider),

              const SizedBox(height: 16),

              // Active Farm Alerts (Real-Time Only)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    activeAlerts.isNotEmpty
                        ? 'ACTIVE FARM ALERTS (${activeAlerts.length} EVENT${activeAlerts.length > 1 ? 'S' : ''})'
                        : 'ACTIVE FARM ALERTS (0)',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                    ),
                  ),
                  if (activeAlerts.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.alertRose.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'LIVE',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.alertRose,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (activeAlerts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? AppTheme.darkBorder : const Color(0xFFE8F0EA),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_outline_rounded,
                          size: 20,
                          color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All Telemetry & Sensor Levels Nominal',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'No environmental hazards, drought stress, or pump locks active.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                for (int i = 0; i < activeAlerts.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _buildAlertCard(
                    context,
                    title: activeAlerts[i]['title'] as String,
                    time: activeAlerts[i]['time'] as String,
                    severity: activeAlerts[i]['severity'] as String,
                    severityColor: activeAlerts[i]['severityColor'] as Color,
                    action: activeAlerts[i]['action'] as String,
                    icon: activeAlerts[i]['icon'] as IconData,
                  ),
                ],

              const SizedBox(height: 16),

              // Live Sensor Intelligence & Telemetry
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
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F5EE),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.insights_rounded,
                                color: Color(0xFF193E32),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Field Intelligence & Telemetry',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5EE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'LIVE DATA',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF193E32),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildTrendBar(
                      context,
                      label: 'Root-Zone Soil Moisture',
                      values: [
                        (provider.sensorData.soilMoisture - 4).clamp(5, 100),
                        (provider.sensorData.soilMoisture - 2).clamp(5, 100),
                        (provider.sensorData.soilMoisture - 1).clamp(5, 100),
                        (provider.sensorData.soilMoisture + 1).clamp(5, 100),
                        provider.sensorData.soilMoisture.clamp(5, 100),
                      ],
                      currentDisplay: '${provider.sensorData.soilMoisture}%',
                      color: const Color(0xFF0288D1),
                      unit: '%',
                    ),
                    const SizedBox(height: 16),
                    _buildTrendBar(
                      context,
                      label: 'Ambient Temperature',
                      values: [
                        ((provider.sensorData.temperature - 1.5).round()).clamp(10, 60),
                        ((provider.sensorData.temperature - 0.8).round()).clamp(10, 60),
                        ((provider.sensorData.temperature).round()).clamp(10, 60),
                        ((provider.sensorData.temperature + 0.4).round()).clamp(10, 60),
                        ((provider.sensorData.temperature).round()).clamp(10, 60),
                      ],
                      currentDisplay: '${provider.sensorData.temperature.toStringAsFixed(1)}°C',
                      color: const Color(0xFFE65100),
                      unit: '°C',
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

  Widget _buildNoAdvisoryCard(BuildContext context, FarmProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFD4E5D8),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : const Color(0x0C1A3E31),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.eco_outlined,
              size: 22,
              color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No Active Advisory Protocol',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No crop disease or pest infection is diagnosed right now. Scan a leaf in the Scan Vision tab to generate an ICAR/FAO verified agronomic remedy.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_enhance_outlined, size: 16),
            label: const Text('Open Scan Vision', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () => provider.setTabIndex(1),
          ),
        ],
      ),
    );
  }

  Widget _buildFusedAdvisoryCard(BuildContext context, FarmProvider provider) {
    final fused = provider.fusedAdvisory!;
    final isRainOverride = fused.isSprayOverrideActive;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isRainOverride ? const Color(0xFFFFCC80) : const Color(0xFFD4E5D8),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
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
                    decoration: BoxDecoration(
                      color: isRainOverride ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5EE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isRainOverride ? Icons.umbrella_rounded : Icons.eco_rounded,
                      color: isRainOverride ? const Color(0xFFE65100) : const Color(0xFF193E32),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isRainOverride ? 'Spray Interlock Active' : 'ICAR Agronomic Guidance',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                    ),
                  ),
                ],
              ),
              // Vernacular Audio Trigger
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5EE),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    provider.isTtsPlaying ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                    color: const Color(0xFF193E32),
                    size: 20,
                  ),
                  onPressed: () {
                    if (provider.isTtsPlaying) {
                      provider.stopVoiceAdvisory();
                    } else {
                      provider.playVoiceAdvisory();
                    }
                  },
                ),
              ),
            ],
          ),

          if (isRainOverride && fused.overrideReasonBn != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE082), width: 1.0),
              ),
              child: Text(
                fused.overrideReasonBn!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF795548),
                  height: 1.4,
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),
          Text(
            fused.advisory.nameBn,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            fused.advisory.nameEn,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F),
            ),
          ),
          const SizedBox(height: 14),

          // Remedy Preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE8F0EA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.spa_rounded, size: 14, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 6),
                    Text(
                      'ORGANIC REMEDY (জৈব প্রতিকার)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  fused.advisory.organicTreatmentBn,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF2C3E35),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // View Full Treatment Plan Button
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DiagnosisDetailScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF193E32),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.description_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'View Treatment Prescription',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context, {
    required String title,
    required String time,
    required String severity,
    required Color severityColor,
    required String action,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE8F0EA),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.15)
                : const Color(0x0A1A3E31),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: severityColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        severity,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: severityColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  action,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF52796F),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendBar(
    BuildContext context, {
    required String label,
    required List<int> values,
    required Color color,
    required String unit,
    String? currentDisplay,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxVal = values.reduce((curr, next) => curr > next ? curr : next);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
            ),
            Text(
              'Current: ${currentDisplay ?? '${values.last}$unit'}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final val in values) ...[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    height: (val / maxVal) * 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
