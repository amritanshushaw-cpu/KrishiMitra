import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fresnel/fresnel.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../services/voice_tts_service.dart';
import '../../state/farm_provider.dart';
import '../widgets/camera_preview_card.dart';
import '../widgets/parameter_badge_card.dart';
import '../widgets/pump_control_toggle.dart';
import '../widgets/telemetry_gauge.dart';
import 'diagnosis_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showSafetyNetModal(BuildContext context, FarmProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AppTheme.cardBorderStrong, width: 1.0),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: AppTheme.accent, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'HARDWARE BYPASS // PITCH SAFETY NET',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: AppTheme.textMuted),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Instantly inject bundled high-resolution agricultural leaf assets to test edge inference and vernacular audio without ESP32 Wi-Fi reliance.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDemoOption(
                  context: ctx,
                  code: 'SAMPLE_01',
                  title: 'Tomato // Late Blight (Fungus)',
                  subtitle: 'Triggers active rain spray suspension & pump interlock test',
                  accentColor: AppTheme.alertRed,
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.triggerSafetyNetDemo(assetPath: AppConstants.demoLateBlightAsset);
                  },
                ),
                const SizedBox(height: 8),
                _buildDemoOption(
                  context: ctx,
                  code: 'SAMPLE_02',
                  title: 'Potato // Healthy Foliage',
                  subtitle: 'Nominal baseline condition — zero chemical intervention required',
                  accentColor: AppTheme.accent,
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.triggerSafetyNetDemo(assetPath: AppConstants.demoHealthyAsset);
                  },
                ),
                const SizedBox(height: 8),
                _buildDemoOption(
                  context: ctx,
                  code: 'SAMPLE_03',
                  title: 'Paddy Rice // Leaf Blast',
                  subtitle: 'Magnaporthe oryzae pathogen analysis & bio-fungicide prescription',
                  accentColor: AppTheme.warningAmber,
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.triggerSafetyNetDemo(assetPath: AppConstants.demoRiceBlastAsset);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildDemoOption({
    required BuildContext context,
    required String code,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.canvas,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.cardBorder, width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.0),
              ),
              child: Text(
                code,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        titleSpacing: 16,
        title: GestureDetector(
          // Safety Net hidden trigger
          onLongPress: () => _showSafetyNetModal(context, provider),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.accentSoft,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3), width: 1.0),
                ),
                child: const Icon(Icons.hub_outlined, color: AppTheme.accent, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SMARTFARM // EDGE_CORE',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '100% OFFLINE // PHONE-AS-BRAIN',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          // Vernacular language toggle
          PopupMenuButton<TtsLanguage>(
            initialValue: provider.ttsLanguage,
            icon: const Icon(Icons.translate, color: AppTheme.textSecondary, size: 20),
            color: AppTheme.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: AppTheme.cardBorder, width: 1.0),
            ),
            onSelected: (lang) => provider.setTtsLanguage(lang),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: TtsLanguage.bengali,
                child: Text('বাংলা (BENGALI)', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.white)),
              ),
              PopupMenuItem(
                value: TtsLanguage.hindi,
                child: Text('हिन्दी (HINDI)', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.white)),
              ),
              PopupMenuItem(
                value: TtsLanguage.english,
                child: Text('ENGLISH (US)', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.white)),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.shield_outlined, color: AppTheme.textSecondary, size: 20),
            tooltip: 'Hardware Bypass (Safety Net)',
            onPressed: () => _showSafetyNetModal(context, provider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWideScreen = constraints.maxWidth >= 900;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: GlassContainer(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: isWideScreen
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column: Hardware & Vision Stream
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
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
                                const SizedBox(height: 12),
                                PumpControlToggle(
                                  isLocked: provider.isPumpLocked,
                                  autoReason: provider.fusedAdvisory?.recommendedPumpAction == 'LOCK'
                                      ? 'Interlocked: Spore propagation mitigation'
                                      : null,
                                  onToggle: () => provider.togglePump(),
                                ),
                                const SizedBox(height: 12),
                                CameraPreviewCard(
                                  imageBytes: provider.currentLeafBytes,
                                  isCapturing: provider.isCapturing,
                                  isInferenceRunning: provider.isInferenceRunning,
                                  inferenceResult: provider.lastInference,
                                  onCapture: () => provider.captureAndAnalyze(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Right Column: Diagnostic Matrix & Advisory Core
                          Expanded(
                            flex: 7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMatrixHeader(context, provider),
                                const SizedBox(height: 12),
                                _buildMatrixContent(provider),
                                const SizedBox(height: 16),
                                if (provider.fusedAdvisory != null) ...[
                                  _buildFusedAdvisoryCard(context, provider),
                                ],
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                          const SizedBox(height: 10),
                          PumpControlToggle(
                            isLocked: provider.isPumpLocked,
                            autoReason: provider.fusedAdvisory?.recommendedPumpAction == 'LOCK'
                                ? 'Interlocked: Spore propagation mitigation'
                                : null,
                            onToggle: () => provider.togglePump(),
                          ),
                          const SizedBox(height: 12),
                          CameraPreviewCard(
                            imageBytes: provider.currentLeafBytes,
                            isCapturing: provider.isCapturing,
                            isInferenceRunning: provider.isInferenceRunning,
                            inferenceResult: provider.lastInference,
                            onCapture: () => provider.captureAndAnalyze(),
                          ),
                          const SizedBox(height: 16),
                          _buildMatrixHeader(context, provider),
                          const SizedBox(height: 10),
                          _buildMatrixContent(provider),
                          const SizedBox(height: 16),
                          if (provider.fusedAdvisory != null) ...[
                            _buildFusedAdvisoryCard(context, provider),
                          ],
                        ],
                      ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMatrixHeader(BuildContext context, FarmProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.grid_view_outlined, color: AppTheme.accent, size: 16),
            const SizedBox(width: 8),
            Text(
              '5-PARAMETER DIAGNOSTIC MATRIX',
              style: AppTheme.monoLabel(context),
            ),
          ],
        ),
        if (provider.lastInference != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: AppTheme.accentSoft,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3), width: 1.0),
            ),
            child: Text(
              '${(provider.lastInference!.topConfidence * 100).toStringAsFixed(1)}% CONFIDENCE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.accent,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMatrixContent(FarmProvider provider) {
    if (provider.parsedDiagnosis != null) {
      return Column(
        children: [
          for (final param in provider.parsedDiagnosis!.allParameters) ...[
            ParameterBadgeCard(parameter: param),
            const SizedBox(height: 6),
          ],
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.cardBorder, width: 1.0),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.crop_free, color: AppTheme.cardBorderStrong, size: 28),
            const SizedBox(height: 8),
            Text(
              'Awaiting leaf image capture or safety net demo to populate diagnostic matrix.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFusedAdvisoryCard(BuildContext context, FarmProvider provider) {
    final fused = provider.fusedAdvisory!;
    final isRainOverride = fused.isSprayOverrideActive;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRainOverride ? AppTheme.warningAmber : AppTheme.accent.withValues(alpha: 0.4),
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
                    isRainOverride ? Icons.umbrella_outlined : Icons.psychology_outlined,
                    color: isRainOverride ? AppTheme.warningAmber : AppTheme.accent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isRainOverride ? 'INTERLOCK ACTIVE // SPRAY SUSPENDED' : 'ADVISORY DISPATCH // ICAR RULES',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: isRainOverride ? AppTheme.warningAmber : AppTheme.accent,
                    ),
                  ),
                ],
              ),
              // Vernacular Audio Trigger
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  provider.isTtsPlaying ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
                  color: AppTheme.accent,
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
            ],
          ),

          if (isRainOverride && fused.overrideReasonBn != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.warningAmberSoft,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.warningAmber.withValues(alpha: 0.3), width: 1.0),
              ),
              child: Text(
                fused.overrideReasonBn!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),
          Text(
            fused.advisory.nameBn,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            fused.advisory.nameEn,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 10),

          // Remedy Preview
          Text(
            'ORGANIC REMEDY (জৈব সমাধান):',
            style: AppTheme.monoLabel(context),
          ),
          const SizedBox(height: 3),
          Text(
            fused.advisory.organicTreatmentBn,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppTheme.textSecondary,
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
              label: const Text('VIEW FULL REMEDIES // সম্পূর্ণ চিকিৎসা ও প্রেসক্রিপশন'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textPrimary,
                side: const BorderSide(color: AppTheme.cardBorderStrong, width: 1.0),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
