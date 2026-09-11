import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Liquid Glass Container Widget
///
/// Implements state-of-the-art Liquid Glass aesthetics:
/// - **Fluid Shapes**: Procedurally generated multi-frequency morphing SVG-style Bezier blobs.
/// - **Blurred Transparency**: Real-time Gaussian `BackdropFilter` diffusion over translucent surfaces.
/// - **Organic Movement**: Phase-shifted harmonic oscillation creating living, fluid liquid motion.
/// - **Glossy Refraction**: Diagonal specular sheen gradient with dynamic light sweep and edge reflections.
/// - **Dynamic**: State-aware, hardware-accelerated via `RepaintBoundary` for silky 60/120 FPS.
class LiquidGlassContainer extends StatefulWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final List<Color>? liquidColors;
  final double glossIntensity;
  final bool animate;
  final bool enableBackdropFilter;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.radius = 24.0,
    this.padding,
    this.margin,
    this.blur = 14.0,
    this.width,
    this.height,
    this.onTap,
    this.liquidColors,
    this.glossIntensity = 0.85,
    this.animate = true,
    this.enableBackdropFilter = false,
  });

  @override
  State<LiquidGlassContainer> createState() => _LiquidGlassContainerState();
}

class _LiquidGlassContainerState extends State<LiquidGlassContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6500),
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant LiquidGlassContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Default liquid color harmonies: Bio-emerald & Electric cyan
    final List<Color> fluidPalette = widget.liquidColors ??
        (isDark
            ? [
                AppTheme.neonMint.withValues(alpha: 0.32),
                AppTheme.skyBlue.withValues(alpha: 0.26),
                const Color(0xFF34D399).withValues(alpha: 0.20),
              ]
            : [
                const Color(0xFF52B788).withValues(alpha: 0.28),
                const Color(0xFF38BDF8).withValues(alpha: 0.22),
                const Color(0xFF74C69D).withValues(alpha: 0.22),
              ]);

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: Stack(
        children: [
          // 1. Procedural Animated Fluid Blobs Layer (Isolated via RepaintBoundary)
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _LiquidBlobsPainter(
                      progress: _controller.value,
                      colors: fluidPalette,
                      isDark: isDark,
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. Real-time Translucent Glass Surface Layer (Hardware accelerated)
          Positioned.fill(
            child: widget.enableBackdropFilter && widget.blur > 0
                ? BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: widget.blur,
                      sigmaY: widget.blur,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOutCubic,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF141414).withValues(alpha: 0.60)
                            : Colors.white.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(widget.radius),
                      ),
                    ),
                  )
                : AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF141414).withValues(alpha: 0.60)
                          : Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(widget.radius),
                    ),
                  ),
          ),

          // 3. Static Diagonal Specular Sheen & Glass Refraction Gradients
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.radius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 0.30, 0.60, 1.0],
                    colors: [
                      Colors.white.withValues(alpha: 0.16 * widget.glossIntensity),
                      Colors.white.withValues(alpha: 0.04 * widget.glossIntensity),
                      Colors.transparent,
                      (isDark ? AppTheme.neonMint : const Color(0xFF52B788)).withValues(
                        alpha: 0.08 * widget.glossIntensity,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. Dynamic Animated Glossy Shimmer Sweep
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  // Shimmer sweep every full cycle
                  final sweepPos = (_controller.value * 2.5) - 0.75;
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 1.0,
                    child: Transform.translate(
                      offset: Offset(sweepPos * 300, 0),
                      child: Transform.rotate(
                        angle: -math.pi / 4,
                        child: Container(
                          width: 45,
                          height: 400,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(
                                  alpha: (isDark ? 0.06 : 0.10) * widget.glossIntensity,
                                ),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 5. Upper Meniscus Glossy Light Ridge
          Positioned(
            top: 0,
            left: widget.radius * 0.5,
            right: widget.radius * 0.5,
            height: 1.2,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: (isDark ? 0.38 : 0.75) * widget.glossIntensity),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 6. Hairline Specular Edge Border (Light Reflection on Rim with Smooth Transition)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.radius),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.14 * widget.glossIntensity)
                        : Colors.white.withValues(alpha: 0.85 * widget.glossIntensity),
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ),

          // 7. Forefront Child Content
          Container(
            width: widget.width,
            height: widget.height,
            padding: widget.padding,
            child: widget.child,
          ),
        ],
      ),
    );

    if (widget.onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(widget.radius),
          splashColor: (isDark ? AppTheme.neonMint : const Color(0xFF52B788))
              .withValues(alpha: 0.12),
          highlightColor: Colors.transparent,
          child: content,
        ),
      );
    }

    if (widget.margin != null) {
      return Padding(
        padding: widget.margin!,
        child: content,
      );
    }

    return content;
  }
}

/// Procedural Liquid SVG/Bezier Blob Painter
///
/// Uses harmonic trigonometric functions to create smooth, organic, continuously morphing
/// fluid shapes that drift, rotate, and pulse smoothly across the card canvas.
class _LiquidBlobsPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final bool isDark;

  _LiquidBlobsPainter({
    required this.progress,
    required this.colors,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final double phase = progress * 2 * math.pi;

    // Paint Blob 1: Primary Organic Fluid Blob (Top-Left / Center Drift)
    final paint1 = Paint()
      ..color = colors.isNotEmpty
          ? colors[0]
          : const Color(0xFF10B981).withValues(alpha: 0.30)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24)
      ..style = PaintingStyle.fill;

    final double cx1 = size.width * 0.26 + math.sin(phase) * (size.width * 0.14);
    final double cy1 = size.height * 0.35 + math.cos(phase * 0.85) * (size.height * 0.16);
    final double r1 = math.min(size.width, size.height) * 0.44;

    _drawMorphingBlob(
      canvas: canvas,
      center: Offset(cx1, cy1),
      baseRadius: r1,
      paint: paint1,
      phase: phase,
      harmonics: 5,
      amplitude: 0.25,
    );

    // Paint Blob 2: Secondary Fluid Blob (Bottom-Right Floating Counter-Phase)
    final paint2 = Paint()
      ..color = colors.length > 1
          ? colors[1]
          : const Color(0xFF06B6D4).withValues(alpha: 0.24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28)
      ..style = PaintingStyle.fill;

    final double cx2 = size.width * 0.74 + math.cos(phase * 0.95) * (size.width * 0.15);
    final double cy2 = size.height * 0.65 + math.sin(phase * 1.15) * (size.height * 0.15);
    final double r2 = math.min(size.width, size.height) * 0.40;

    _drawMorphingBlob(
      canvas: canvas,
      center: Offset(cx2, cy2),
      baseRadius: r2,
      paint: paint2,
      phase: phase + math.pi,
      harmonics: 6,
      amplitude: 0.28,
    );

    // Paint Blob 3: Accent Ambient Drop (Dynamic Drifter)
    if (colors.length > 2) {
      final paint3 = Paint()
        ..color = colors[2]
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20)
        ..style = PaintingStyle.fill;

      final double cx3 = size.width * 0.52 + math.sin(phase * 1.35) * (size.width * 0.22);
      final double cy3 = size.height * 0.72 + math.cos(phase * 1.25) * (size.height * 0.14);
      final double r3 = math.min(size.width, size.height) * 0.28;

      _drawMorphingBlob(
        canvas: canvas,
        center: Offset(cx3, cy3),
        baseRadius: r3,
        paint: paint3,
        phase: phase * 1.3,
        harmonics: 4,
        amplitude: 0.22,
      );
    }
  }

  /// Draws a smooth closed Bezier blob with harmonic radial variations
  void _drawMorphingBlob({
    required Canvas canvas,
    required Offset center,
    required double baseRadius,
    required Paint paint,
    required double phase,
    required int harmonics,
    required double amplitude,
  }) {
    final int pointsCount = math.max(6, harmonics * 2);
    final List<Offset> points = [];

    for (int i = 0; i < pointsCount; i++) {
      final double angle = (i / pointsCount) * 2 * math.pi;
      // Multi-frequency harmonic perturbation
      final double variation = math.sin(angle * harmonics + phase) * amplitude +
          math.cos(angle * (harmonics - 1) - phase * 0.7) * (amplitude * 0.5);
      final double r = baseRadius * (1.0 + variation);
      final double px = center.dx + r * math.cos(angle);
      final double py = center.dy + r * math.sin(angle);
      points.add(Offset(px, py));
    }

    // Build smooth cubic Bezier loop through points
    final path = Path();
    if (points.isEmpty) return;

    path.moveTo(
      (points[0].dx + points[pointsCount - 1].dx) / 2,
      (points[0].dy + points[pointsCount - 1].dy) / 2,
    );

    for (int i = 0; i < pointsCount; i++) {
      final pCurrent = points[i];
      final pNext = points[(i + 1) % pointsCount];
      final mid = Offset(
        (pCurrent.dx + pNext.dx) / 2,
        (pCurrent.dy + pNext.dy) / 2,
      );
      path.quadraticBezierTo(pCurrent.dx, pCurrent.dy, mid.dx, mid.dy);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LiquidBlobsPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDark != isDark ||
        oldDelegate.colors != colors;
  }
}
