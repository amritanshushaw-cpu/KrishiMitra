import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/inference_result.dart';
import '../../state/farm_provider.dart';
import 'liquid_glass_button.dart';

enum CameraSource {
  esp32,
  phone,
  storage,
}

class LeafInspectionViewfinder extends StatefulWidget {
  final Uint8List? imageBytes;
  final bool isCapturing;
  final bool isInferenceRunning;
  final InferenceResult? inferenceResult;
  final VoidCallback onCapture;
  final VoidCallback? onCapturePhone;
  final VoidCallback? onPickGallery;

  const LeafInspectionViewfinder({
    super.key,
    required this.imageBytes,
    required this.isCapturing,
    required this.isInferenceRunning,
    required this.inferenceResult,
    required this.onCapture,
    this.onCapturePhone,
    this.onPickGallery,
  });

  @override
  State<LeafInspectionViewfinder> createState() => _LeafInspectionViewfinderState();
}

class _LeafInspectionViewfinderState extends State<LeafInspectionViewfinder>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  CameraSource _selectedSource = CameraSource.esp32;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isScanning = widget.isCapturing || widget.isInferenceRunning;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFF1B4D3E).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Viewfinder Camera Stream & Pinpoint Nodes
          Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 16 / 11,
                child: widget.imageBytes != null
                    ? Image.memory(
                        widget.imageBytes!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: isDark ? const Color(0xFF0A120D) : const Color(0xFFEFF5F0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedSource == CameraSource.storage
                                  ? Icons.photo_library_outlined
                                  : (_selectedSource == CameraSource.esp32
                                      ? Icons.wifi_tethering_rounded
                                      : Icons.photo_camera_rounded),
                              size: 40,
                              color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedSource == CameraSource.storage
                                  ? 'DEVICE STORAGE // SELECT LOCAL PHOTO'
                                  : (_selectedSource == CameraSource.esp32
                                      ? 'ESP32 CAM SOFTAP // 192.168.4.1/capture'
                                      : 'PHONE CAMERA // REAR SENSOR READY'),
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedSource == CameraSource.storage
                                  ? 'Tap "UPLOAD FROM PHONE STORAGE" below'
                                  : (_selectedSource == CameraSource.esp32
                                      ? 'Tap "ESP32 CAM" to download live frame'
                                      : 'Tap "PHONE CAMERA" to snap photo with device'),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              // Corner Reticle Framing
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCorner(true, true),
                          _buildCorner(true, false),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCorner(false, true),
                          _buildCorner(false, false),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Animated Scanning Line (when capturing or inferring)
              if (isScanning)
                AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, child) {
                    return Positioned(
                      top: 15 + _scanController.value * 180,
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppTheme.emeraldLight.withValues(alpha: 0.9),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.emeraldLight.withValues(alpha: 0.6),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              // Inspection Pinpoint Overlay Nodes
              if (widget.imageBytes != null && !isScanning) ...[
                Positioned(
                  top: 20,
                  left: 18,
                  child: _buildPinpointNode(
                    icon: _selectedSource == CameraSource.storage
                        ? Icons.photo_library_outlined
                        : (_selectedSource == CameraSource.esp32
                            ? Icons.wifi_tethering_rounded
                            : Icons.photo_camera_rounded),
                    title: 'Source',
                    value: _selectedSource == CameraSource.esp32
                        ? 'ESP32 Node'
                        : (_selectedSource == CameraSource.phone
                            ? 'Phone Cam'
                            : 'Storage'),
                    isDark: isDark,
                    accentColor: AppTheme.emeraldLight,
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 18,
                  child: _buildPinpointNode(
                    icon: Icons.biotech_outlined,
                    title: 'Leaf Tissue',
                    value: '0.783 Chl',
                    isDark: isDark,
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 18,
                  child: _buildPinpointNode(
                    icon: Icons.hub_outlined,
                    title: 'Pipeline Model',
                    value: '224x224 RGB',
                    isDark: isDark,
                  ),
                ),
                if (widget.inferenceResult != null)
                  Positioned(
                    bottom: 24,
                    right: 18,
                    child: _buildPinpointNode(
                      icon: Icons.speed_outlined,
                      title: 'Edge Latency',
                      value: '${widget.inferenceResult!.inferenceLatency.inMilliseconds}ms',
                      isDark: isDark,
                      accentColor: AppTheme.emeraldLight,
                    ),
                  ),
              ],

              // Loading / Processing Overlay
              if (isScanning)
                Container(
                  color: Colors.black.withValues(alpha: 0.6),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            color: AppTheme.emeraldLight,
                            strokeWidth: 2.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.isCapturing
                              ? (_selectedSource == CameraSource.storage
                                  ? 'OPENING DEVICE STORAGE...'
                                  : (_selectedSource == CameraSource.phone
                                      ? 'OPENING PHONE CAMERA...'
                                      : 'DOWNLOADING ESP32 SOFTAP STREAM...'))
                              : 'AI MODEL INFERENCE IN PROGRESS...',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Action Toolbar: Dual Option (ESP32 Cam & Phone Camera) + Phone Storage Upload
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: LiquidGlassButton(
                        height: 48,
                        size: LiquidButtonSize.sm,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        onPressed: isScanning
                            ? null
                            : () {
                                setState(() => _selectedSource = CameraSource.esp32);
                                widget.onCapture();
                              },
                        icon: Icons.wifi_tethering_rounded,
                        text: provider.strings.esp32Cam,
                        variant: _selectedSource == CameraSource.esp32
                            ? LiquidButtonVariant.primary
                            : LiquidButtonVariant.glass,
                        borderRadius: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: LiquidGlassButton(
                        height: 48,
                        size: LiquidButtonSize.sm,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        onPressed: isScanning
                            ? null
                            : () {
                                setState(() => _selectedSource = CameraSource.phone);
                                widget.onCapturePhone?.call();
                              },
                        icon: Icons.photo_camera_rounded,
                        text: provider.strings.phoneCamera,
                        variant: _selectedSource == CameraSource.phone
                            ? LiquidButtonVariant.primary
                            : LiquidButtonVariant.glass,
                        borderRadius: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LiquidGlassButton(
                  width: double.infinity,
                  height: 46,
                  size: LiquidButtonSize.sm,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  onPressed: isScanning
                      ? null
                      : () {
                          setState(() => _selectedSource = CameraSource.storage);
                          widget.onPickGallery?.call();
                        },
                  icon: Icons.photo_library_outlined,
                  text: provider.strings.uploadFromStorage,
                  variant: _selectedSource == CameraSource.storage
                      ? LiquidButtonVariant.primary
                      : LiquidButtonVariant.glass,
                  borderRadius: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinpointNode({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
    Color? accentColor,
  }) {
    final color = accentColor ?? (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: AppTheme.emeraldLight, width: 2) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: AppTheme.emeraldLight, width: 2) : BorderSide.none,
          left: isLeft ? const BorderSide(color: AppTheme.emeraldLight, width: 2) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: AppTheme.emeraldLight, width: 2) : BorderSide.none,
        ),
      ),
    );
  }
}
