import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// A subtle, ambient liquid wave animation representing soil moisture hydration depth.
/// Features dual undulating sine waves with smooth parallax movement.
class SoilHydrationOverlay extends StatefulWidget {
  final double moisturePercent; // 0.0 to 1.0
  final bool isCriticallyDry;
  final bool isSaturated;
  final double borderRadius;

  const SoilHydrationOverlay({
    super.key,
    required this.moisturePercent,
    this.isCriticallyDry = false,
    this.isSaturated = false,
    this.borderRadius = 18.0,
  });

  @override
  State<SoilHydrationOverlay> createState() => _SoilHydrationOverlayState();
}

class _SoilHydrationOverlayState extends State<SoilHydrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color waveColor = widget.isCriticallyDry
        ? AppTheme.amberWarning
        : (widget.isSaturated ? const Color(0xFF0284C7) : AppTheme.skyBlue);

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _SoilWavePainter(
              progress: _controller.value,
              moisturePercent: widget.moisturePercent,
              waveColor: waveColor,
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }
}

class _SoilWavePainter extends CustomPainter {
  final double progress;
  final double moisturePercent;
  final Color waveColor;
  final bool isDark;

  _SoilWavePainter({
    required this.progress,
    required this.moisturePercent,
    required this.waveColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Target water height based on moisture percentage (clamped between 15% and 55% of card height)
    final double targetHeightRatio = (moisturePercent * 0.40 + 0.12).clamp(0.12, 0.50);
    final double baseWaterY = size.height * (1.0 - targetHeightRatio);

    // 1. Back wave (slower, offset phase, lower opacity)
    final backWavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          waveColor.withValues(alpha: isDark ? 0.08 : 0.05),
          waveColor.withValues(alpha: isDark ? 0.16 : 0.09),
        ],
      ).createShader(Rect.fromLTWH(0, baseWaterY - 8, size.width, size.height - baseWaterY + 8));

    final backPath = Path();
    backPath.moveTo(0, size.height);
    backPath.lineTo(0, baseWaterY);

    const int steps = 30;
    for (int i = 0; i <= steps; i++) {
      final double x = (i / steps) * size.width;
      final double angle = (i / steps) * 2 * math.pi - progress * 2 * math.pi;
      final double y = baseWaterY + math.sin(angle) * 4.0;
      backPath.lineTo(x, y);
    }
    backPath.lineTo(size.width, size.height);
    backPath.close();
    canvas.drawPath(backPath, backWavePaint);

    // 2. Front wave (faster, primary wave)
    final frontWavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          waveColor.withValues(alpha: isDark ? 0.12 : 0.08),
          waveColor.withValues(alpha: isDark ? 0.22 : 0.14),
        ],
      ).createShader(Rect.fromLTWH(0, baseWaterY - 6, size.width, size.height - baseWaterY + 6));

    final frontPath = Path();
    frontPath.moveTo(0, size.height);
    frontPath.lineTo(0, baseWaterY);

    for (int i = 0; i <= steps; i++) {
      final double x = (i / steps) * size.width;
      final double angle = (i / steps) * 2 * math.pi + progress * 2 * math.pi + math.pi / 2;
      final double y = baseWaterY + math.cos(angle) * 3.5;
      frontPath.lineTo(x, y);
    }
    frontPath.lineTo(size.width, size.height);
    frontPath.close();
    canvas.drawPath(frontPath, frontWavePaint);

    // 3. Subtle crest specular hairline on the front wave surface
    final crestPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = waveColor.withValues(alpha: isDark ? 0.35 : 0.25);

    final crestPath = Path();
    for (int i = 0; i <= steps; i++) {
      final double x = (i / steps) * size.width;
      final double angle = (i / steps) * 2 * math.pi + progress * 2 * math.pi + math.pi / 2;
      final double y = baseWaterY + math.cos(angle) * 3.5;
      if (i == 0) {
        crestPath.moveTo(x, y);
      } else {
        crestPath.lineTo(x, y);
      }
    }
    canvas.drawPath(crestPath, crestPaint);
  }

  @override
  bool shouldRepaint(covariant _SoilWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.moisturePercent != moisturePercent ||
        oldDelegate.waveColor != waveColor;
  }
}
