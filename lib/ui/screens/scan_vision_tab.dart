import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../state/farm_provider.dart';
import '../widgets/leaf_inspection_viewfinder.dart';
import '../widgets/liquid_glass_button.dart';
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

              // Leaf Inspection Viewfinder
              LeafInspectionViewfinder(
                imageBytes: provider.currentLeafBytes,
                isCapturing: provider.isCapturing,
                isInferenceRunning: provider.isInferenceRunning,
                inferenceResult: provider.lastInference,
                onCapture: () => provider.captureAndAnalyze(),
                onOpenDemoModal: onOpenSafetyNet,
              ),
              const SizedBox(height: 14),

              // Prescription Action Button (When Diagnosed)
              if (provider.parsedDiagnosis != null) ...[
                LiquidGlassButton(
                  width: double.infinity,
                  size: LiquidButtonSize.lg,
                  borderRadius: 18,
                  icon: Icons.medication_rounded,
                  text: provider.strings.viewPrescription,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DiagnosisDetailScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
