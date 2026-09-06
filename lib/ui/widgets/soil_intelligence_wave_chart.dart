import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class SoilIntelligenceWaveChart extends StatefulWidget {
  const SoilIntelligenceWaveChart({super.key});

  @override
  State<SoilIntelligenceWaveChart> createState() =>
      _SoilIntelligenceWaveChartState();
}

class _SoilIntelligenceWaveChartState extends State<SoilIntelligenceWaveChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textMuted = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: AppTheme.glassCardDecoration(isDark: isDark, radius: 24),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                      'Soil Intelligence',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Predicted SOC increase 0.1-0.2% per year\npotential 3-10 tons CO2 eq/hectare/year',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        height: 1.4,
                        color: textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Metrics Pills
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _metricPill('• SOC 1.8%', isDark),
                  const SizedBox(height: 4),
                  _metricPill('• N2O -34.82%', isDark),
                  const SizedBox(height: 4),
                  _metricPill('• pH value 6.81', isDark),
                ],
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.slatePine.withValues(alpha: 0.6) : AppTheme.mintDew.withValues(alpha: 0.8),
                  border: Border.all(
                    color: isDark ? AppTheme.softSage.withValues(alpha: 0.25) : AppTheme.softSage.withValues(alpha: 0.4),
                    width: 1.0,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.north_east,
                  size: 14,
                  color: isDark ? AppTheme.mintDew : AppTheme.forestMoss,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Animated Wave Canvas
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight - 24),
                          painter: _WaveChartPainter(
                            progress: _animation.value,
                            isDark: isDark,
                          ),
                        ),
                        // Monthly Axis Labels
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: (constraints.maxWidth < 380
                                    ? ['Jan', 'Mar', 'May', 'Jul', 'Sep', 'Nov']
                                    : _months)
                                .map((m) {
                              return Text(
                                m,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  color: textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  ),
);
  }

  Widget _metricPill(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.slatePine.withValues(alpha: 0.60)
            : AppTheme.mintDew.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isDark ? AppTheme.softSage : AppTheme.forestMoss).withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isDark ? AppTheme.darkTextPrimary : AppTheme.forestMoss,
        ),
      ),
    );
  }
}

class _WaveChartPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _WaveChartPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final width = size.width;
    final height = size.height;

    // Background horizontal grid lines
    final gridPaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04)
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 3; i++) {
      final y = height * (i / 4.0);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Spline coordinates simulating the organic Soil Intelligence curve
    final points = [
      Offset(0, height * 0.85),
      Offset(width * 0.15, height * 0.82),
      Offset(width * 0.28, height * 0.70),
      Offset(width * 0.42, height * 0.25), // Crest
      Offset(width * 0.48, height * 0.20), // Peak
      Offset(width * 0.54, height * 0.35),
      Offset(width * 0.62, height * 0.75),
      Offset(width * 0.78, height * 0.65),
      Offset(width * 0.90, height * 0.62),
      Offset(width, height * 0.70),
    ];

    final path = Path();
    path.moveTo(points[0].dx, height - (height - points[0].dy) * progress);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cp1x = p0.dx + (p1.dx - p0.dx) / 2;
      final cp1y = height - (height - p0.dy) * progress;
      final cp2x = cp1x;
      final cp2y = height - (height - p1.dy) * progress;
      final endY = height - (height - p1.dy) * progress;
      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p1.dx, endY);
    }

    // Gradient fill path
    final fillPath = Path.from(path);
    fillPath.lineTo(width, height);
    fillPath.lineTo(0, height);
    fillPath.close();

    final fillGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFD3ECA7).withOpacity(0.75 * progress), // Lime/chartreuse
        const Color(0xFFA5E6BA).withOpacity(0.60 * progress), // Sprout
        const Color(0xFF7CE2DB).withOpacity(0.40 * progress), // Cyan/Teal
        const Color(0xFF7CE2DB).withOpacity(0.0),
      ],
      stops: const [0.0, 0.4, 0.75, 1.0],
    );

    final fillPaint = Paint()
      ..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Stroke line
    final strokePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFC0E27B),
          Color(0xFF6EDDB0),
          Color(0xFF50E3C2),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);

    if (progress > 0.7) {
      // Draw peak callout node 1: 2.3°C
      final peak1 = Offset(width * 0.48, height - (height - height * 0.20) * progress);
      _drawCalloutTag(
        canvas: canvas,
        pos: peak1,
        text: '2.3°C',
        color: const Color(0xFFF7B731),
        isDark: isDark,
      );

      // Draw secondary callout node 2: 15°C
      final peak2 = Offset(width * 0.62, height - (height - height * 0.75) * progress);
      _drawCalloutTag(
        canvas: canvas,
        pos: peak2,
        text: '15°C',
        color: const Color(0xFF45AAF2),
        isDark: isDark,
      );
    }
  }

  void _drawCalloutTag({
    required Canvas canvas,
    required Offset pos,
    required String text,
    required Color color,
    required bool isDark,
  }) {
    // Node point circle
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(pos, 5, pointPaint);
    canvas.drawCircle(pos, 5, ringPaint);

    // Text label
    final textSpan = TextSpan(
      text: '• $text',
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF19241B),
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final labelOffset = Offset(pos.dx + 8, pos.dy - 6);
    textPainter.paint(canvas, labelOffset);
  }

  @override
  bool shouldRepaint(covariant _WaveChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
