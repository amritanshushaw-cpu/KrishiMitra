import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/voice_tts_service.dart';
import '../../state/farm_provider.dart';
import '../widgets/app_glass_container.dart';

class DiagnosisDetailScreen extends StatelessWidget {
  const DiagnosisDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final fused = provider.fusedAdvisory;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (fused == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('DIAGNOSIS DETAILS'),
        ),
        body: const Center(child: Text('No active diagnosis available.')),
      );
    }

    final advisory = fused.advisory;
    final isRainOverride = fused.isSprayOverrideActive;

    return Container(
      decoration: AppTheme.backgroundDecoration(isDark),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'PRESCRIPTION // AGRONOMIC REMEDIES',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                provider.isTtsPlaying ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
                color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                size: 24,
              ),
              tooltip: provider.isTtsPlaying ? 'Stop Voice Agent' : 'Speak Advisory',
              onPressed: () {
                if (provider.isTtsPlaying) {
                  provider.stopVoiceAdvisory();
                } else {
                  provider.playVoiceAdvisory();
                }
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              children: [
                // Header Card - English Primary
                AppGlassContainer(
                  radius: 18,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              advisory.category.toUpperCase(),
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: AppTheme.amberWarningSoft,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'SEVERITY // ${advisory.severity.toUpperCase()}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.amberWarning,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Primary English Name
                      Text(
                        advisory.nameEn,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Secondary Regional Name
                      Text(
                        advisory.nameBn,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Audio Advisory Script Card
                AppGlassContainer(
                  radius: 16,
                  hasGoldGlow: true,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.record_voice_over_outlined,
                                color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'AUDIO ADVISORY SCRIPT',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                                ),
                              ),
                            ],
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              if (provider.isTtsPlaying) {
                                provider.stopVoiceAdvisory();
                              } else {
                                provider.playVoiceAdvisory();
                              }
                            },
                            icon: Icon(
                              provider.isTtsPlaying ? Icons.stop : Icons.volume_up,
                              size: 15,
                              color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                            ),
                            label: Text(
                              provider.isTtsPlaying ? 'STOP' : 'SPEAK',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: const Size(70, 32),
                              side: BorderSide(
                                color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // English script is primary
                      Text(
                        '"${fused.ttsScriptEn}"',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                          height: 1.5,
                        ),
                      ),
                      if (provider.ttsLanguage != TtsLanguage.english) ...[
                        const SizedBox(height: 8),
                        Text(
                          provider.ttsLanguage == TtsLanguage.bengali
                              ? fused.ttsScriptBn
                              : fused.ttsScriptHi,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Symptoms Card - English Primary
                _buildDetailCard(
                  context,
                  title: 'SYMPTOMATOLOGY',
                  icon: Icons.search_outlined,
                  color: AppTheme.amberWarning,
                  contentPrimary: advisory.symptomsEn,
                  contentSecondary: advisory.symptomsBn,
                ),
                const SizedBox(height: 12),

                // Organic Treatment Card - English Primary
                _buildDetailCard(
                  context,
                  title: 'ORGANIC INTERVENTION',
                  icon: Icons.eco_outlined,
                  color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                  contentPrimary: advisory.organicTreatmentEn,
                  contentSecondary: advisory.organicTreatmentBn,
                ),
                const SizedBox(height: 12),

                // Chemical Control Card (with Rain Override notice) - English Primary
                AppGlassContainer(
                  radius: 16,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isRainOverride ? Icons.umbrella_outlined : Icons.science_outlined,
                            color: isRainOverride ? AppTheme.amberWarning : AppTheme.alertRose,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isRainOverride
                                ? 'CHEMICAL CONTROL // RAIN INTERLOCK ACTIVE'
                                : 'CHEMICAL CONTROL',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: isRainOverride ? AppTheme.amberWarning : AppTheme.alertRose,
                            ),
                          ),
                        ],
                      ),
                      if (isRainOverride) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.amberWarningSoft,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppTheme.amberWarning.withValues(alpha: 0.3),
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fused.overrideReasonEn ?? fused.overrideReasonBn ?? '',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                  height: 1.4,
                                ),
                              ),
                              if (fused.overrideReasonBn != null && fused.overrideReasonEn != fused.overrideReasonBn) ...[
                                const SizedBox(height: 4),
                                Text(
                                  fused.overrideReasonBn!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Primary English
                      Text(
                        fused.effectiveChemicalTreatmentEn,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Secondary Regional
                      Text(
                        fused.effectiveChemicalTreatmentBn,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String contentPrimary,
    required String contentSecondary,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassContainer(
      radius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Primary English
          Text(
            contentPrimary,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
              height: 1.4,
            ),
          ),
          if (contentSecondary.isNotEmpty && contentSecondary != contentPrimary) ...[
            const SizedBox(height: 6),
            // Secondary Regional
            Text(
              contentSecondary,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
