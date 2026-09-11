import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// A refined, elegant solar thermal radiance and ambient heat shimmer overlay.
/// Replaces harsh fire/furnace animations with a gentle solar breathing glow,
/// delicate expanding solar corona pulses, and subtle horizontal thermal mirage waves.
/// Strictly designed to preserve UI legibility and match KrishiMitra's glassmorphic theme.
class ExtremeHeatOverlay extends StatefulWidget {
  final double borderRadius;
  final Color? accentColor;

  const ExtremeHeatOverlay({
    super.key,
    this.borderRadius = 18.0,
    this.accentColor,
  });

  @override
  State<ExtremeHeatOverlay> createState() => _ExtremeHeatOverlayState();
}

class _ExtremeHeatOverlayState extends State<ExtremeHeatOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
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
    final themeColor = widget.accentColor ?? AppTheme.amberWarning;

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _SolarThermalPainter(
                progress: _controller.value,
                color: themeColor,
                isDark: isDark,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SolarThermalPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isDark;

  _SolarThermalPainter({
    required this.progress,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final double pulse = 0.5 + 0.5 * math.sin(progress * 2 * math.pi);

    // 1. Soft Solar Breathing Warmth (Radial ambient aura from top-right / sun position)
    final Offset sunCenter = Offset(size.width * 0.80, size.height * 0.22);
    final double maxSunRadius = size.width * 0.95;

    final sunAuraPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.65, -0.55),
        radius: 0.95,
        colors: [
          color.withValues(alpha: isDark ? (0.16 + pulse * 0.08) : (0.10 + pulse * 0.05)),
          color.withValues(alpha: isDark ? (0.07 + pulse * 0.04) : (0.04 + pulse * 0.02)),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), sunAuraPaint);

    // 2. Expanding Solar Corona Pulses (Delicate, calm radiation rings)
    _drawCoronaRing(canvas, sunCenter, progress, maxSunRadius);
    _drawCoronaRing(canvas, sunCenter, (progress + 0.5) % 1.0, maxSunRadius);

    // 3. Gentle Horizontal Thermal Mirage Waves (Floating near card base, harmonizing with soil/vapor cards)
    _drawThermalWave(
      canvas: canvas,
      size: size,
      phaseProgress: progress,
      heightRatio: 0.22,
      amplitude: 2.5,
      frequency: 1.8,
      baseOpacity: isDark ? 0.09 : 0.05,
    );

    _drawThermalWave(
      canvas: canvas,
      size: size,
      phaseProgress: (progress + 0.4) % 1.0,
      heightRatio: 0.16,
      amplitude: 3.2,
      frequency: 2.2,
      baseOpacity: isDark ? 0.14 : 0.08,
    );
  }

  void _drawCoronaRing(Canvas canvas, Offset center, double phase, double maxRadius) {
    // Ring expands outward and smoothly fades
    final double radius = 10.0 + phase * (maxRadius - 10.0);
    final double opacity = math.sin(phase * math.pi) * (isDark ? 0.20 : 0.12);
    if (opacity <= 0.005) return;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = RadialGradient(
        center: Alignment(
          (center.dx / maxRadius) * 2 - 1,
          (center.dy / maxRadius) * 2 - 1,
        ),
        radius: 1.0,
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: opacity * 0.4),
          Colors.transparent,
        ],
        stops: const [0.85, 0.95, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, ringPaint);
  }

  void _drawThermalWave({
    required Canvas canvas,
    required Size size,
    required double phaseProgress,
    required double heightRatio,
    required double amplitude,
    required double frequency,
    required double baseOpacity,
  }) {
    final double baseY = size.height * (1.0 - heightRatio);
    final double wavePhase = phaseProgress * 2 * math.pi;

    final path = Path();
    const int segments = 32;

    path.moveTo(0, size.height);

    for (int i = 0; i <= segments; i++) {
      final double x = (i / segments) * size.width;
      final double normX = i / segments;
      final double y = baseY +
          math.sin(normX * frequency * 2 * math.pi + wavePhase) * amplitude;

      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    final wavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: baseOpacity * 0.4),
          color.withValues(alpha: baseOpacity),
        ],
      ).createShader(Rect.fromLTWH(0, baseY - amplitude, size.width, size.height - baseY + amplitude));

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant _SolarThermalPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isDark != isDark;
  }
}
