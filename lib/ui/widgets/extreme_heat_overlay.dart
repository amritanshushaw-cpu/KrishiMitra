import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Specification for vertical thermal shimmer streamline ribbons
class _HeatRibbon {
  final double xFraction;
  final double speed;
  final double amplitude;
  final double frequency;
  final double phase;
  final double strokeWidth;
  final Color baseColor;

  const _HeatRibbon({
    required this.xFraction,
    required this.speed,
    required this.amplitude,
    required this.frequency,
    required this.phase,
    required this.strokeWidth,
    required this.baseColor,
  });
}

/// A sophisticated, high-aesthetic extreme heat / thermal stress animation.
/// Replaces static red tint with organic rising thermal haze ribbons,
/// ascending convective heat ripples, and a breathing radiant solar glow.
/// Free of distracting floating bubbles or noisy dots.
class ExtremeHeatOverlay extends StatefulWidget {
  final double borderRadius;

  const ExtremeHeatOverlay({
    super.key,
    this.borderRadius = 18.0,
  });

  @override
  State<ExtremeHeatOverlay> createState() => _ExtremeHeatOverlayState();
}

class _ExtremeHeatOverlayState extends State<ExtremeHeatOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_HeatRibbon> _ribbons;

  @override
  void initState() {
    super.initState();
    _ribbons = const [
      _HeatRibbon(
        xFraction: 0.16,
        speed: 1.0,
        amplitude: 3.5,
        frequency: 2.2,
        phase: 0.0,
        strokeWidth: 1.3,
        baseColor: Color(0xFFFF453A),
      ),
      _HeatRibbon(
        xFraction: 0.34,
        speed: 1.25,
        amplitude: 4.5,
        frequency: 1.8,
        phase: 1.4,
        strokeWidth: 1.8,
        baseColor: Color(0xFFFF9F0A),
      ),
      _HeatRibbon(
        xFraction: 0.52,
        speed: 0.85,
        amplitude: 4.0,
        frequency: 2.4,
        phase: 2.7,
        strokeWidth: 1.5,
        baseColor: Color(0xFFFF375F),
      ),
      _HeatRibbon(
        xFraction: 0.70,
        speed: 1.15,
        amplitude: 3.8,
        frequency: 1.9,
        phase: 4.1,
        strokeWidth: 1.7,
        baseColor: Color(0xFFFF9F0A),
      ),
      _HeatRibbon(
        xFraction: 0.86,
        speed: 0.95,
        amplitude: 3.2,
        frequency: 2.6,
        phase: 5.3,
        strokeWidth: 1.2,
        baseColor: Color(0xFFFF453A),
      ),
    ];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _HeatPainter(
              progress: _controller.value,
              ribbons: _ribbons,
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }
}

class _HeatPainter extends CustomPainter {
  final double progress;
  final List<_HeatRibbon> ribbons;
  final bool isDark;

  _HeatPainter({
    required this.progress,
    required this.ribbons,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Radiant breathing thermal background aura
    final double pulse = 0.5 + 0.5 * math.sin(progress * 2 * math.pi);
    final double bgAlpha = isDark ? (0.35 + pulse * 0.15) : (0.12 + pulse * 0.08);

    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFF5A0C0C).withValues(alpha: bgAlpha * 1.3),
          const Color(0xFF380808).withValues(alpha: bgAlpha * 0.8),
          const Color(0xFF1F0404).withValues(alpha: bgAlpha * 0.3),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Warm radial core at bottom center to simulate rising furnace heat
    final corePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, 1.1),
        radius: 0.9,
        colors: [
          const Color(0xFFFF453A).withValues(alpha: isDark ? (0.28 + pulse * 0.10) : 0.14),
          const Color(0xFFFF9F0A).withValues(alpha: isDark ? (0.16 + pulse * 0.06) : 0.07),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), corePaint);

    // 2. Ascending Convective Heat Waves (subtle horizontal ripples lifting upward)
    _drawAscendingRipple(canvas, size, (progress) % 1.0, 0.22);
    _drawAscendingRipple(canvas, size, (progress + 0.5) % 1.0, 0.18);

    // 3. Vertical Heat Haze Shimmer Ribbons
    final ribbonPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const int steps = 28;
    for (final ribbon in ribbons) {
      final double baseX = ribbon.xFraction * size.width;
      final double cyclePhase = progress * 2 * math.pi * ribbon.speed + ribbon.phase;

      final path = Path();
      for (int i = 0; i <= steps; i++) {
        final double ratio = i / steps; // 0 = bottom, 1 = top
        final double y = size.height * (1.0 - ratio);
        
        // Sine displacement simulating thermal air mirage
        final double angle = ratio * ribbon.frequency * 2 * math.pi - cyclePhase;
        final double x = baseX + math.sin(angle) * ribbon.amplitude;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      // Vertical gradient: fades in near bottom, vibrant in middle, softly evaporates near top
      final Rect ribbonBounds = Rect.fromLTWH(baseX - 10, 0, 20, size.height);
      ribbonPaint
        ..strokeWidth = ribbon.strokeWidth
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            ribbon.baseColor.withValues(alpha: 0.0),
            ribbon.baseColor.withValues(alpha: isDark ? 0.32 : 0.22),
            ribbon.baseColor.withValues(alpha: isDark ? 0.25 : 0.16),
            ribbon.baseColor.withValues(alpha: 0.0),
          ],
          stops: const [0.05, 0.35, 0.70, 0.98],
        ).createShader(ribbonBounds);

      canvas.drawPath(path, ribbonPaint);
    }
  }

  void _drawAscendingRipple(Canvas canvas, Size size, double phaseProgress, double baseOpacity) {
    // Phase 0.0 is at bottom (height), Phase 1.0 is near top (height * 0.15)
    final double y = size.height * (1.0 - phaseProgress * 0.75);
    // Ripple fades as it reaches upper air
    final double opacity = math.sin(phaseProgress * math.pi) * (isDark ? baseOpacity : baseOpacity * 0.7);
    if (opacity <= 0.01) return;

    final ripplePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFF9F0A).withValues(alpha: 0.0),
          const Color(0xFFFF453A).withValues(alpha: opacity),
          const Color(0xFFFF9F0A).withValues(alpha: opacity * 0.8),
          const Color(0xFFFF453A).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, y - 6, size.width, 12));

    final path = Path();
    const int steps = 24;
    for (int i = 0; i <= steps; i++) {
      final double x = (i / steps) * size.width;
      final double waveOffset = math.sin((i / steps) * 2 * math.pi + progress * 2 * math.pi) * 3.0;
      final double curY = y + waveOffset;

      if (i == 0) {
        path.moveTo(x, curY);
      } else {
        path.lineTo(x, curY);
      }
    }

    canvas.drawPath(path, ripplePaint);
  }

  @override
  bool shouldRepaint(covariant _HeatPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
