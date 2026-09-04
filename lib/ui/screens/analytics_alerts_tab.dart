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

              // Active Farm Alerts (Screen 9 in README)
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

              // Soil & Temperature Curves (Screen 10 in README & Image 5)
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
                        Text(
                          'FIELD INTELLIGENCE // 24H TRENDS',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                          ),
                        ),
                        Text(
                          'AREA 1 LOG',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildTrendBar(
                      context,
                      label: 'Soil Moisture 24h Trend',
                      values: [30, 32, 35, 38, 42, 40, 38],
                      color: AppTheme.skyBlue,
                      unit: '%',
                    ),
                    const SizedBox(height: 14),
                    _buildTrendBar(
                      context,
                      label: 'Temperature Variation',
                      values: [22, 24, 28, 32, 34, 31, 28],
                      color: AppTheme.amberWarning,
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isRainOverride ? AppTheme.amberWarning : (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen),
          width: 1.2,
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
                    isRainOverride ? Icons.umbrella_outlined : Icons.psychology_outlined,
                    color: isRainOverride ? AppTheme.amberWarning : (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRainOverride ? 'INTERLOCK ACTIVE // SPRAY SUSPENDED' : 'ICAR AGRONOMIC ADVISORY',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: isRainOverride ? AppTheme.amberWarning : (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen),
                    ),
                  ),
                ],
              ),
              // Vernacular Audio Trigger
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  provider.isTtsPlaying ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
                  color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                  size: 22,
                ),
                onPressed: () {
                  if (provider.isTtsPlaying) {
                    provider.stopVoiceAdvisory();
                  } else {
                    provider.playVoiceAdvisory();
                  }
                },
              ),
            ],
          ),

          if (isRainOverride && fused.overrideReasonBn != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.amberWarningSoft,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.amberWarning.withValues(alpha: 0.3), width: 1.0),
              ),
              child: Text(
                fused.overrideReasonBn!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),
          Text(
            fused.advisory.nameBn,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
            ),
          ),
          Text(
            fused.advisory.nameEn,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
          ),
          const SizedBox(height: 10),

          // Remedy Preview
          Text(
            'ORGANIC SOLUTION (জৈব প্রতিকার):',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            fused.advisory.organicTreatmentBn,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // View Full Treatment Plan Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DiagnosisDetailScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.description_outlined, size: 14),
              label: const Text('VIEW PRESCRIPTION // সম্পূর্ণ চিকিৎসা ও প্রেসক্রিপশন'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: severityColor),
          ),
          const SizedBox(width: 12),
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
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        severity,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: severityColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  action,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
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
