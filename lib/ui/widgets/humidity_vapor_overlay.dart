import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Model for an atmospheric vapor streamline / breeze flow
class _VaporStream {
  final double yFraction;
  final double speed;
  final double amplitude;
  final double frequency;
  final double phase;
  final double strokeWidth;
  final double opacity;

  const _VaporStream({
    required this.yFraction,
    required this.speed,
    required this.amplitude,
    required this.frequency,
    required this.phase,
    required this.strokeWidth,
    required this.opacity,
  });
}

/// A serene, ambient air breeze and atmospheric vapor wave overlay for humidity telemetry.
/// Simulates gentle morning farm air currents and moisture mist.
class HumidityVaporOverlay extends StatefulWidget {
  final double humidityPercent; // 0.0 to 1.0
  final double borderRadius;

  const HumidityVaporOverlay({
    super.key,
    required this.humidityPercent,
    this.borderRadius = 18.0,
  });

  @override
  State<HumidityVaporOverlay> createState() => _HumidityVaporOverlayState();
}

class _HumidityVaporOverlayState extends State<HumidityVaporOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_VaporStream> _streams;

  @override
  void initState() {
    super.initState();
    // Deterministic generation of 4 subtle breeze streamlines
    _streams = const [
      _VaporStream(
        yFraction: 0.38,
        speed: 1.0,
        amplitude: 3.5,
        frequency: 1.8,
        phase: 0.0,
        strokeWidth: 1.2,
        opacity: 0.18,
      ),
      _VaporStream(
        yFraction: 0.58,
        speed: 0.75,
        amplitude: 4.2,
        frequency: 1.4,
        phase: 1.5,
        strokeWidth: 1.6,
        opacity: 0.14,
      ),
      _VaporStream(
        yFraction: 0.78,
        speed: 1.2,
        amplitude: 3.0,
        frequency: 2.2,
        phase: 2.8,
        strokeWidth: 1.0,
        opacity: 0.22,
      ),
      _VaporStream(
        yFraction: 0.92,
        speed: 0.85,
        amplitude: 2.5,
        frequency: 1.6,
        phase: 4.0,
        strokeWidth: 1.4,
        opacity: 0.12,
      ),
    ];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
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
            painter: _VaporPainter(
              progress: _controller.value,
              humidityPercent: widget.humidityPercent,
              streams: _streams,
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }
}

class _VaporPainter extends CustomPainter {
  final double progress;
  final double humidityPercent;
  final List<_VaporStream> streams;
  final bool isDark;

  _VaporPainter({
    required this.progress,
    required this.humidityPercent,
    required this.streams,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Ambient background mist tint scaling with humidity level
    final mistAlpha = (0.04 + (humidityPercent * 0.10)).clamp(0.04, 0.15);
    final mistPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          AppTheme.vibrantEmerald.withValues(alpha: mistAlpha * 0.4),
          AppTheme.neonMint.withValues(alpha: mistAlpha),
          AppTheme.vibrantEmerald.withValues(alpha: mistAlpha * 0.3),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), mistPaint);

    final streamPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const int steps = 28;
    for (final stream in streams) {
      final double baseY = stream.yFraction * size.height;
      final double wavePhase = progress * 2 * math.pi * stream.speed + stream.phase;

      final path = Path();
      for (int i = 0; i <= steps; i++) {
        final double x = (i / steps) * size.width;
        final double angle = (i / steps) * stream.frequency * 2 * math.pi - wavePhase;
        final double y = baseY + math.sin(angle) * stream.amplitude;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      // Stream gradient: softly fades in at the edges and peaks in the center
      final streamRect = Rect.fromLTWH(0, baseY - 6, size.width, 12);
      final double effectiveOpacity = (stream.opacity * (0.8 + humidityPercent * 0.4)).clamp(0.08, 0.35);

      streamPaint
        ..strokeWidth = stream.strokeWidth
        ..shader = LinearGradient(
          colors: [
            AppTheme.vibrantEmerald.withValues(alpha: 0.0),
            (isDark ? AppTheme.neonMint : AppTheme.vibrantEmerald)
                .withValues(alpha: effectiveOpacity),
            AppTheme.vibrantEmerald.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(streamRect);

      canvas.drawPath(path, streamPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VaporPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.humidityPercent != humidityPercent;
  }
}
