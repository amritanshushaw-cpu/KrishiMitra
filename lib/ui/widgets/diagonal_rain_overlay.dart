import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Realistic diagonal rain droplet model
class _Raindrop {
  final double xFraction;
  final double length;
  final double speed;
  final double opacity;
  final double strokeWidth;
  final double phase;

  const _Raindrop({
    required this.xFraction,
    required this.length,
    required this.speed,
    required this.opacity,
    required this.strokeWidth,
    required this.phase,
  });
}

/// A high-performance, ambient diagonal rain droplet animation overlay.
/// Mimics real falling rain with wind slant, speed parallax depth,
/// and ground impact splashes.
class DiagonalRainOverlay extends StatefulWidget {
  final bool isRaining;
  final double borderRadius;
  final Widget? child;

  const DiagonalRainOverlay({
    super.key,
    required this.isRaining,
    this.borderRadius = 18.0,
    this.child,
  });

  @override
  State<DiagonalRainOverlay> createState() => _DiagonalRainOverlayState();
}

class _DiagonalRainOverlayState extends State<DiagonalRainOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Raindrop> _raindrops;

  @override
  void initState() {
    super.initState();
    // Deterministic generation of 26 rain droplets for rich visual density
    // without runtime allocations during paint.
    final rng = math.Random(101);
    _raindrops = List.generate(26, (i) {
      return _Raindrop(
        xFraction: rng.nextDouble() * 1.3 - 0.2, // Allow entry from left overflow
        length: 12.0 + rng.nextDouble() * 14.0, // 12px to 26px
        speed: 1.0 + rng.nextDouble() * 0.9, // 1.0x to 1.9x parallax
        opacity: 0.35 + rng.nextDouble() * 0.50, // 0.35 to 0.85 opacity
        strokeWidth: 1.2 + rng.nextDouble() * 0.8, // 1.2 to 2.0 width
        phase: rng.nextDouble(),
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    if (widget.isRaining) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant DiagonalRainOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRaining != oldWidget.isRaining) {
      if (widget.isRaining) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // If a child is provided, render it
          if (widget.child != null) widget.child!,

          // Atmospheric rain mist & diagonal droplet animation
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: widget.isRaining ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: widget.isRaining
                  ? AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _RainPainter(
                            progress: _controller.value,
                            raindrops: _raindrops,
                          ),
                        );
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RainPainter extends CustomPainter {
  final double progress;
  final List<_Raindrop> raindrops;

  // Diagonal slant angle (~20 degrees from vertical, falling top-left to bottom-right)
  static const double _angle = 0.35; // radians
  static final double _sinA = math.sin(_angle);
  static final double _cosA = math.cos(_angle);
  static final double _tanA = math.tan(_angle);

  _RainPainter({
    required this.progress,
    required this.raindrops,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rainPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final splashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Ambient ground mist gradient when precipitation is active
    final mistRect = Rect.fromLTWH(0, size.height * 0.55, size.width, size.height * 0.45);
    final mistPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.skyBlue.withValues(alpha: 0.0),
          AppTheme.skyBlue.withValues(alpha: 0.12),
        ],
      ).createShader(mistRect);
    canvas.drawRect(mistRect, mistPaint);

    for (final drop in raindrops) {
      final dropProgress = (progress * drop.speed + drop.phase) % 1.0;
      final totalTravel = size.height + drop.length * 2.5;

      final headY = dropProgress * totalTravel - drop.length;
      final diagonalShift = headY * _tanA;
      final headX = drop.xFraction * size.width + diagonalShift;

      final tailX = headX - _sinA * drop.length;
      final tailY = headY - _cosA * drop.length;

      // Draw diagonal raindrop streak
      rainPaint
        ..strokeWidth = drop.strokeWidth
        ..color = AppTheme.skyBlue.withValues(alpha: drop.opacity);

      canvas.drawLine(
        Offset(tailX, tailY),
        Offset(headX, headY),
        rainPaint,
      );

      // Micro ground impact splash ripple near the bottom floor
      if (headY >= size.height - 10 && headY <= size.height + 4) {
        final splashFactor = ((headY - (size.height - 10)) / 14.0).clamp(0.0, 1.0);
        final splashWidth = 2.0 + splashFactor * 6.0;
        final splashHeight = 1.0 + splashFactor * 2.2;
        final splashAlpha = (1.0 - splashFactor) * drop.opacity * 0.6;

        splashPaint.color = AppTheme.skyBlue.withValues(alpha: splashAlpha);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(headX, size.height - 2),
            width: splashWidth,
            height: splashHeight,
          ),
          splashPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
