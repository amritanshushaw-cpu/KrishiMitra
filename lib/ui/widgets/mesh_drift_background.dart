import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// An animated fluid WebGL-style "Mesh Drift" shader background.
/// Features floating, morphing organic botanical gradient orbs in dark mode
/// calibrated with KrishiMitra's Minimal Green palette (#051F20, #0B2B26, #163832, #235347, #8EB69B, #DAF1DE).
class MeshDriftBackground extends StatefulWidget {
  final Widget child;
  final bool isDark;
  final bool animated;

  const MeshDriftBackground({
    super.key,
    required this.child,
    required this.isDark,
    this.animated = true,
  });

  @override
  State<MeshDriftBackground> createState() => _MeshDriftBackgroundState();
}

class _MeshDriftBackgroundState extends State<MeshDriftBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    );

    if (widget.animated && widget.isDark) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant MeshDriftBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animated && widget.isDark) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      if (_controller.isAnimating) {
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
    if (!widget.isDark) {
      // Light mode: Clean organic Mint Dew background
      return Container(
        decoration: AppTheme.backgroundDecoration(false),
        child: widget.child,
      );
    }

    return Stack(
      children: [
        // Base canvas: Deepest Midnight Teal
        Positioned.fill(
          child: Container(
            color: const Color(0xFF041213),
          ),
        ),

        // Animated Mesh Drift canvas
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _MeshDriftPainter(progress: _controller.value),
                );
              },
            ),
          ),
        ),

        // Frosted atmospheric diffusion layer (melds nodes into continuous liquid mesh)
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // Subtle organic vignette & noise tint overlay
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.3,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF02090A).withValues(alpha: 0.42),
                    const Color(0xFF010607).withValues(alpha: 0.72),
                  ],
                  stops: const [0.45, 0.82, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Foreground application content (Scaffold, tabs, cards)
        widget.child,
      ],
    );
  }
}

/// Custom painter for the 5-node harmonic drifting gradient mesh
class _MeshDriftPainter extends CustomPainter {
  final double progress;

  _MeshDriftPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    if (w <= 0 || h <= 0) return;

    final double t = progress;
    final Paint paint = Paint()..blendMode = BlendMode.screen;

    // Node 0: Forest Moss & Emerald Glow (Upper Left / Center-left drift)
    _drawDriftingNode(
      canvas: canvas,
      center: Offset(
        w * (0.32 + 0.20 * math.sin(t * 2 * math.pi * 0.7 + 0.2)),
        h * (0.26 + 0.16 * math.cos(t * 2 * math.pi * 0.5 + 1.1)),
      ),
      radius: w * (0.58 + 0.08 * math.sin(t * 2 * math.pi * 0.3)),
      color: const Color(0xFF10B981),
      maxAlpha: 0.22,
      paint: paint,
    );

    // Node 1: Deep Pine & Ocean Slate (Lower Right / Mid-right drift)
    _drawDriftingNode(
      canvas: canvas,
      center: Offset(
        w * (0.76 + 0.18 * math.cos(t * 2 * math.pi * 0.6 + 2.3)),
        h * (0.58 + 0.20 * math.sin(t * 2 * math.pi * 0.8 + 0.7)),
      ),
      radius: w * (0.64 + 0.10 * math.cos(t * 2 * math.pi * 0.4)),
      color: const Color(0xFF164E43),
      maxAlpha: 0.30,
      paint: paint,
    );

    // Node 2: Luminous Soft Sage / Mint Dew (Top Right / Top Center drift)
    _drawDriftingNode(
      canvas: canvas,
      center: Offset(
        w * (0.68 + 0.22 * math.sin(t * 2 * math.pi * 0.4 + 3.4)),
        h * (0.16 + 0.14 * math.cos(t * 2 * math.pi * 0.7 + 2.1)),
      ),
      radius: w * (0.48 + 0.07 * math.sin(t * 2 * math.pi * 0.5)),
      color: const Color(0xFF8EB69B),
      maxAlpha: 0.18,
      paint: paint,
    );

    // Node 3: Warm Botanical Amber / Gold Glow (Bottom Left drift for chromatic depth)
    _drawDriftingNode(
      canvas: canvas,
      center: Offset(
        w * (0.20 + 0.16 * math.cos(t * 2 * math.pi * 0.3 + 4.5)),
        h * (0.82 + 0.12 * math.sin(t * 2 * math.pi * 0.4 + 1.8)),
      ),
      radius: w * (0.44 + 0.06 * math.cos(t * 2 * math.pi * 0.6)),
      color: const Color(0xFFD4AF37),
      maxAlpha: 0.11,
      paint: paint,
    );

    // Node 4: Midnight Teal Deep Pulse (Mid-screen anchor)
    _drawDriftingNode(
      canvas: canvas,
      center: Offset(
        w * (0.48 + 0.22 * math.sin(t * 2 * math.pi * 0.5 + 5.2)),
        h * (0.46 + 0.18 * math.cos(t * 2 * math.pi * 0.3 + 3.9)),
      ),
      radius: w * (0.56 + 0.08 * math.sin(t * 2 * math.pi * 0.4)),
      color: const Color(0xFF0F3E36),
      maxAlpha: 0.26,
      paint: paint,
    );
  }

  void _drawDriftingNode({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required Color color,
    required double maxAlpha,
    required Paint paint,
  }) {
    if (radius <= 0) return;

    paint.shader = RadialGradient(
      colors: [
        color.withValues(alpha: maxAlpha),
        color.withValues(alpha: maxAlpha * 0.65),
        color.withValues(alpha: maxAlpha * 0.20),
        color.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.35, 0.70, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _MeshDriftPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
