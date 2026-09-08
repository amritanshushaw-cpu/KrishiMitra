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
              const SizedBox(height: 14),

              // Fused Advisory Banner (if active)
              if (fused != null) ...[
                _buildFusedAdvisoryCard(context, provider),
                const SizedBox(height: 16),
              ],

              // Active Farm Alerts
              Text(
                'ACTIVE FARM ALERTS (3 NOTIFICATIONS)',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                ),
              ),
              const SizedBox(height: 10),

              // Alert 1: Rain Override
              if (provider.sensorData.isRaining)
                _buildAlertCard(
                  context,
                  title: 'Heavy Rain Detected // Spraying Paused',
                  time: 'Just Now',
                  severity: 'WARNING',
                  severityColor: AppTheme.amberWarning,
                  action: 'Foliar pesticide & fungicide spray suspended to prevent chemical runoff.',
                  icon: Icons.thunderstorm_outlined,
                )
              else
                _buildAlertCard(
                  context,
                  title: 'Weather Nominal // Spraying Permitted',
                  time: '10m ago',
                  severity: 'OPTIMAL',
                  severityColor: AppTheme.sproutGreen,
                  action: 'Atmospheric conditions clear for standard nutrient application.',
                  icon: Icons.check_circle_outline,
                ),
              const SizedBox(height: 8),

              // Alert 2: Disease Status
              if (provider.parsedDiagnosis != null &&
                  provider.parsedDiagnosis!.disease.status == ParameterStatus.critical)
                _buildAlertCard(
                  context,
                  title: 'Pathogen Detected: Late Blight',
                  time: '2m ago',
                  severity: 'CRITICAL',
                  severityColor: AppTheme.alertRose,
                  action: 'Isolate affected plants immediately. Apply 1% Bordeaux mixture.',
                  icon: Icons.coronavirus_outlined,
                )
              else
                _buildAlertCard(
                  context,
                  title: 'Pathogen Surveillance: Safe',
                  time: '1h ago',
                  severity: 'LOW RISK',
                  severityColor: AppTheme.sproutGreen,
                  action: 'No fungal blight symptoms detected on current foliage sample.',
                  icon: Icons.verified_outlined,
                ),
              const SizedBox(height: 8),

              // Alert 3: Soil Moisture
              _buildAlertCard(
                context,
                title: 'Soil Hydration Monitoring',
                time: 'Continuous',
                severity: provider.sensorData.isSoilCriticallyDry ? 'WARNING' : 'STABLE',
                severityColor: provider.sensorData.isSoilCriticallyDry
                    ? AppTheme.amberWarning
                    : AppTheme.skyBlue,
                action: provider.sensorData.isSoilCriticallyDry
                    ? 'Soil moisture is below 20%. Trigger irrigation immediately.'
                    : 'Soil moisture at ${provider.sensorData.soilMoisture}% (within balanced root-zone range).',
                icon: Icons.water_drop_outlined,
              ),
              const SizedBox(height: 16),

              // Soil & Temperature Curves
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
                              'Field Intelligence & Trends',
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
                            '24H LOG',
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
                      label: 'Soil Moisture 24h Trend',
                      values: [30, 32, 35, 38, 42, 40, 38],
                      color: const Color(0xFF0288D1),
                      unit: '%',
                    ),
                    const SizedBox(height: 16),
                    _buildTrendBar(
                      context,
                      label: 'Temperature Variation',
                      values: [22, 24, 28, 32, 34, 31, 28],
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
              'Current: ${values.last}$unit',
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
