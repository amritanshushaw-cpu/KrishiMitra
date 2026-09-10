import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'web_shader_bridge.dart';

/// An animated fluid WebGL-style shader background for KrishiMitra.
///
/// Features:
/// - Light Mode: "Silk" harmonic flow shader (#03120E, #0E7C5A, #7CE577, #F4FFC7)
///   Faithful 4-octave harmonic flow rotated at 2.51 rad (144°) with pale sunlight bloom.
/// - Dark Mode: "Mesh Drift" organic blob shader (#03120E, #0E7C5A, #7CE577, #F4FFC7)
///   Multi-node Gaussian drifting botanic orbs with screen blend.
/// - WebGL1 Hardware interop on Flutter Web via index.html background canvas.
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

    if (widget.animated) {
      _controller.repeat();
    }

    if (kIsWeb) {
      syncWebShaderMode(widget.isDark);
    }
  }

  @override
  void didUpdateWidget(covariant MeshDriftBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animated) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    }

    if (oldWidget.isDark != widget.isDark && kIsWeb) {
      syncWebShaderMode(widget.isDark);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      syncWebShaderMode(widget.isDark);
    }

    return Stack(
      children: [
        // 1. Solid base foundation
        Positioned.fill(
          child: Container(
            color: widget.isDark ? const Color(0xFF03120E) : const Color(0xFFF4FFC7),
          ),
        ),

        // 2. Animated CustomPaint Shader (Silk in Light Mode, Mesh Drift in Dark Mode)
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: widget.isDark
                      ? _MeshDriftPainter(progress: _controller.value)
                      : _SilkPainter(progress: _controller.value),
                );
              },
            ),
          ),
        ),

        // 3. Frosted atmospheric diffusion layer (melds waves into liquid silk/mesh)
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // 4. Foreground application content (Scaffold, tabs, cards)
        widget.child,
      ],
    );
  }
}

/// Custom painter for Dark Mode: 4-color drifting gradient mesh (Mesh Drift)
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

/// Custom painter for Light Mode: "Silk" Flow Shader in Dart
/// Exact visual reproduction of the 21st.dev Silk shader:
/// - 4 Colors: #03120E, #0E7C5A, #7CE577, #F4FFC7
/// - Diagonal rotation: u_rotate = 2.51 rad (~143.8°)
/// - Speed: 39/100 (time * 0.84)
/// - Flow harmonics:
///   for i = 1..4:
///     q.x += amp / i * cos(i * 2.4 * q.y + t * 0.8 + seed)
///     q.y += amp / i * cos(i * 1.7 * q.x + t * 0.6)
class _SilkPainter extends CustomPainter {
  final double progress;

  _SilkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    if (w <= 0 || h <= 0) return;

    final double t = progress * 2 * math.pi;

    // 1. Base luminous sunlight canvas: #F4FFC7
    final Paint bgPaint = Paint()..color = const Color(0xFFF4FFC7);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // 2. Radiant ambient lime wash (#7CE577) across middle & bottom-left
    final Paint limeWash = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, 0.25),
        radius: 1.15,
        colors: [
          const Color(0xFF7CE577).withValues(alpha: 0.42),
          const Color(0xFFF4FFC7).withValues(alpha: 0.20),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), limeWash);

    // 3. Diagonal Silk Flow Field (rotated by u_rotate = 2.51 rad ~ 144 deg)
    // Deep emerald (#0E7C5A) and obsidian (#03120E) drape over the top-right
    const double angle = 2.51; // 143.8 degrees from shader u_transform.y
    final double cosA = math.cos(angle);
    final double sinA = math.sin(angle);

    // Layered flowing silk ridges matching the shader's harmonic amplitude & seed
    final List<Map<String, dynamic>> silkLayers = [
      {
        'color': const Color(0xFF03120E),
        'alpha': 0.94,
        'offset': 0.0,
        'amp': 32.0,
      },
      {
        'color': const Color(0xFF0E7C5A),
        'alpha': 0.88,
        'offset': 55.0,
        'amp': 40.0,
      },
      {
        'color': const Color(0xFF7CE577),
        'alpha': 0.72,
        'offset': 110.0,
        'amp': 46.0,
      },
      {
        'color': const Color(0xFFF4FFC7),
        'alpha': 0.55,
        'offset': 155.0,
        'amp': 36.0,
      },
    ];

    for (final layer in silkLayers) {
      final Color color = layer['color'] as Color;
      final double alpha = layer['alpha'] as double;
      final double offset = layer['offset'] as double;
      final double amp = layer['amp'] as double;

      final Path path = Path();
      const int steps = 48;
      final double startX = w * 0.38 - offset * sinA;
      final double startY = -h * 0.15 + offset * cosA;
      final double endX = w * 1.20 - offset * sinA;
      final double endY = h * 0.98 + offset * cosA;

      path.moveTo(w * 1.3, -h * 0.3); // Upper-right bound
      path.lineTo(w * 1.3, h * 1.3);  // Lower-right bound

      for (int i = steps; i >= 0; i--) {
        final double fraction = i / steps;
        final double baseX = startX + (endX - startX) * fraction;
        final double baseY = startY + (endY - startY) * fraction;

        // 4-octave harmonic cosine/sine flow formula matching Silk shader
        double wave = 0.0;
        for (double f = 1.0; f <= 4.0; f += 1.0) {
          wave += (amp / f) *
              math.cos(f * 2.4 * (fraction * 3.2) + t * 0.84 + (707.0 % 31.0)) *
              math.sin(f * 1.7 * (fraction * 2.4) + t * 0.60);
        }

        final double px = baseX + wave * cosA;
        final double py = baseY + wave * sinA;
        path.lineTo(px, py);
      }

      path.close();

      final Paint paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: alpha * 0.70),
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.68, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h));

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SilkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
