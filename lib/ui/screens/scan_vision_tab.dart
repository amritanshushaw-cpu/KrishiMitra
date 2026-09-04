import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/voice_tts_service.dart';
import '../../state/farm_provider.dart';
import '../widgets/leaf_inspection_viewfinder.dart';
import '../widgets/parameter_badge_card.dart';
import 'diagnosis_detail_screen.dart';

class ScanVisionTab extends StatelessWidget {
  final VoidCallback onOpenSafetyNet;

  const ScanVisionTab({super.key, required this.onOpenSafetyNet});

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.strings.cropDiagnostics,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          provider.strings.cropDiagSubtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (provider.lastInference != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${(provider.lastInference!.topConfidence * 100).toStringAsFixed(1)}% ${provider.strings.confidence}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Viewfinder with Pinpoint Nodes (inspired by AgricAI)
              LeafInspectionViewfinder(
                imageBytes: provider.currentLeafBytes,
                isCapturing: provider.isCapturing,
                isInferenceRunning: provider.isInferenceRunning,
                inferenceResult: provider.lastInference,
                onCapture: () => provider.captureAndAnalyze(),
                onOpenDemoModal: onOpenSafetyNet,
              ),
              const SizedBox(height: 14),

              // Text-to-Voice Audio Assistant Bar
              _buildTextToVoiceCard(context, provider, isDark),
              const SizedBox(height: 16),

              // 5-Parameter Diagnostic Breakdown Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.grid_view_outlined,
                        color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider.strings.diagnosticMatrix,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Parameters List
              if (provider.parsedDiagnosis != null) ...[
                for (final param in provider.parsedDiagnosis!.allParameters) ...[
                  ParameterBadgeCard(parameter: param),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 12),

                // View Full Prescription Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DiagnosisDetailScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.medication_outlined, size: 16),
                    label: Text(provider.strings.viewPrescription),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.crop_free,
                          color: isDark ? AppTheme.darkBorderStrong : AppTheme.sageBorderHover,
                          size: 32,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          provider.strings.awaitLeafScan,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.strings.awaitLeafScanSub,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextToVoiceCard(BuildContext context, FarmProvider provider, bool isDark) {
    final hasAdvisory = provider.fusedAdvisory != null;
    final isPlaying = provider.isTtsPlaying;
    final isEnabled = provider.isTtsEnabled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isEnabled
              ? (isDark ? AppTheme.emeraldLight.withValues(alpha: 0.35) : AppTheme.forestGreen.withValues(alpha: 0.35))
              : (isDark ? AppTheme.darkBorder : AppTheme.sageBorder),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isEnabled
                      ? (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.12)
                      : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPlaying
                      ? Icons.graphic_eq_rounded
                      : (isEnabled ? Icons.record_voice_over_rounded : Icons.voice_over_off_rounded),
                  size: 18,
                  color: isEnabled
                      ? (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen)
                      : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            provider.strings.ttsTitle,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: isEnabled
                                ? (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.15)
                                : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isPlaying
                                ? provider.strings.statusSpeaking
                                : (isEnabled ? provider.strings.statusAutoOn : provider.strings.statusMuted),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: isEnabled
                                  ? (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen)
                                  : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      provider.strings.ttsSubtitle,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: isEnabled,
                  onChanged: (val) => provider.toggleTtsEnabled(val),
                  activeColor: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                  activeTrackColor: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.35),
                  inactiveThumbColor: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  inactiveTrackColor: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Language selector chips + Quick Play / Stop button
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildLangChip(
                label: 'বাংলা',
                lang: TtsLanguage.bengali,
                currentLang: provider.ttsLanguage,
                isDark: isDark,
                onSelected: () => provider.setTtsLanguage(TtsLanguage.bengali),
              ),
              _buildLangChip(
                label: 'हिन्दी',
                lang: TtsLanguage.hindi,
                currentLang: provider.ttsLanguage,
                isDark: isDark,
                onSelected: () => provider.setTtsLanguage(TtsLanguage.hindi),
              ),
              _buildLangChip(
                label: 'English',
                lang: TtsLanguage.english,
                currentLang: provider.ttsLanguage,
                isDark: isDark,
                onSelected: () => provider.setTtsLanguage(TtsLanguage.english),
              ),
              const SizedBox(width: 4),
              // Play / Stop button
              InkWell(
                onTap: () {
                  if (!isEnabled) {
                    provider.toggleTtsEnabled(true);
                  }
                  provider.toggleVoicePlayback();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPlaying
                        ? Colors.red.withValues(alpha: 0.15)
                        : (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isPlaying
                          ? Colors.redAccent.withValues(alpha: 0.5)
                          : (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                        size: 14,
                        color: isPlaying
                            ? Colors.redAccent
                            : (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPlaying
                            ? provider.strings.stopVoice
                            : (hasAdvisory ? provider.strings.readAloud : provider.strings.testVoice),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: isPlaying
                              ? Colors.redAccent
                              : (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLangChip({
    required String label,
    required TtsLanguage lang,
    required TtsLanguage currentLang,
    required bool isDark,
    required VoidCallback onSelected,
  }) {
    final isSelected = lang == currentLang;
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen)
              : (isDark ? AppTheme.darkCanvas : AppTheme.ivoryCanvas),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? AppTheme.darkBorder : AppTheme.sageBorder),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
          ),
        ),
      ),
    );
  }
}
