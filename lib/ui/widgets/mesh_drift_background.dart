import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
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

    if (kIsWeb) {
      // In Web mode: Pass through to the plain WebGL1 canvas mounted in web/index.html
      return Container(
        color: Colors.transparent,
        child: widget.child,
      );
    }

    return Stack(
      children: [
        // Base canvas: #03120E
        Positioned.fill(
          child: Container(
            color: const Color(0xFF03120E),
          ),
        ),

        // Animated Mesh Drift canvas (calibrated to exact colors: #03120E, #0E7C5A, #7CE577, #F4FFC7)
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
            filter: ImageFilter.blur(sigmaX: 38, sigmaY: 38),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // Foreground application content (Scaffold, tabs, cards)
        widget.child,
      ],
    );
  }
}

/// Custom painter for the 4-color drifting gradient mesh
/// Exact colours: #03120E, #0E7C5A, #7CE577, #F4FFC7
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

    // Node 0: #0E7C5A (Deep Emerald Moss)
    _drawDriftingNode(
      canvas: canvas,
      center: Offset(
        w * (0.32 + 0.20 * math.sin(t * 2 * math.pi * 0.7 + 0.2)),
        h * (0.28 + 0.16 * math.cos(t * 2 * math.pi * 0.5 + 1.1)),
      ),
      radius: w * (0.60 + 0.08 * math.sin(t * 2 * math.pi * 0.3)),
      color: const Color(0xFF0E7C5A),
      maxAlpha: 0.34,
      paint: paint,
    );

    // Node 1: #7CE577 (Vibrant Botanical Lime)
    _drawDriftingNode(
      canvas: canvas,
      center: Offset(
        w * (0.74 + 0.18 * math.cos(t * 2 * math.pi * 0.6 + 2.3)),
        h * (0.32 + 0.20 * math.sin(t * 2 * math.pi * 0.8 + 0.7)),
      ),
      radius: w * (0.54 + 0.08 * math.cos(t * 2 * math.pi * 0.4)),
      color: const Color(0xFF7CE577),
      maxAlpha: 0.28,
      paint: paint,
    );

    // Node 2: #F4FFC7 (Pale Sunlight Bloom)
    _drawDriftingNode(
      canvas: canvas,
      center: Offset(
        w * (0.28 + 0.22 * math.sin(t * 2 * math.pi * 0.4 + 3.4)),
        h * (0.64 + 0.16 * math.cos(t * 2 * math.pi * 0.7 + 2.1)),
      ),
      radius: w * (0.46 + 0.07 * math.sin(t * 2 * math.pi * 0.5)),
      color: const Color(0xFFF4FFC7),
      maxAlpha: 0.22,
      paint: paint,
    );

    // Node 3: Secondary #0E7C5A (Lower Depth Anchor)
    _drawDriftingNode(
      canvas: canvas,
      center: Offset(
        w * (0.68 + 0.18 * math.cos(t * 2 * math.pi * 0.3 + 4.5)),
        h * (0.78 + 0.14 * math.sin(t * 2 * math.pi * 0.4 + 1.8)),
      ),
      radius: w * (0.52 + 0.06 * math.cos(t * 2 * math.pi * 0.6)),
      color: const Color(0xFF0E7C5A),
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
