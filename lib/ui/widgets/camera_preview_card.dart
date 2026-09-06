import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/inference_result.dart';

class CameraPreviewCard extends StatelessWidget {
  final Uint8List? imageBytes;
  final bool isCapturing;
  final bool isInferenceRunning;
  final InferenceResult? inferenceResult;
  final VoidCallback onCapture;

  const CameraPreviewCard({
    super.key,
    required this.imageBytes,
    required this.isCapturing,
    required this.isInferenceRunning,
    required this.inferenceResult,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Image or Placeholder
              AspectRatio(
                aspectRatio: 16 / 10,
                child: imageBytes != null
                    ? Image.memory(
                        imageBytes!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppTheme.canvas,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.crop_free, size: 36, color: AppTheme.cardBorderStrong),
                            const SizedBox(height: 8),
                            Text(
                              'ESP32_SOFTAP // 192.168.4.1:80/capture',
                              style: AppTheme.monoLabel(context),
                            ),
                          ],
                        ),
                      ),
              ),

              // Viewfinder Framing Reticle
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildReticleCorner(true, true),
                          _buildReticleCorner(true, false),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildReticleCorner(false, true),
                          _buildReticleCorner(false, false),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Overlay when loading
              if (isCapturing || isInferenceRunning)
                Container(
                  color: Colors.black.withValues(alpha: 0.75),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: AppTheme.accent,
                            strokeWidth: 2.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isCapturing ? 'DOWNLOADING_STREAM // 800x600' : 'EDGE_INFERENCE // 224x224 TENSOR',
                          style: GoogleFonts.jetBrainsMono(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Top Left Badge: Pipeline Resolution
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.cardBorder, width: 1.0),
                  ),
                  child: Text(
                    '224x224 FP32 // NORM [0,1]',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),

              // Top Right Badge: Edge Latency
              if (inferenceResult != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: AppTheme.accentSoft,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.accent.withValues(alpha: 0.4), width: 1.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                          '${inferenceResult!.inferenceLatency.inMilliseconds}ms EDGE LATENCY',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Action Toolbar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (isCapturing || isInferenceRunning) ? null : onCapture,
                    icon: const Icon(Icons.camera_alt_outlined, size: 16),
                    label: const Text('CAPTURE FROM ESP32'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.textPrimary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReticleCorner(bool isTop, bool isLeft) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: AppTheme.cardBorderStrong, width: 1.5) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: AppTheme.cardBorderStrong, width: 1.5) : BorderSide.none,
          left: isLeft ? const BorderSide(color: AppTheme.cardBorderStrong, width: 1.5) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: AppTheme.cardBorderStrong, width: 1.5) : BorderSide.none,
        ),
      ),
    );
  }
}
