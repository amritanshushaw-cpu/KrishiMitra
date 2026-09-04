import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClimateIqArcGauge extends StatefulWidget {
  final double temperature;
  const ClimateIqArcGauge({
    super.key,
    this.temperature = 28.0,
  });

  @override
  State<ClimateIqArcGauge> createState() => _ClimateIqArcGaugeState();
}

class _ClimateIqArcGaugeState extends State<ClimateIqArcGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
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
    final cardBg = isDark ? const Color(0xFF161C18) : Colors.white;
    final borderColor = isDark ? const Color(0xFF263229) : const Color(0xFFE8EBE3);
    final textMuted = isDark ? const Color(0xFF8FA395) : const Color(0xFF7A8B7E);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ClimateIQ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF19241B),
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Air Quality: AQI (Good/AQI 32)\nUV Index: 4 Low (2) • Solar: 14 High',
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF202A22) : const Color(0xFFF2F4ED),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.north_east,
                  size: 14,
                  color: isDark ? Colors.white70 : const Color(0xFF425648),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Arc Gauge Centerpiece
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final arcSize = math.min(constraints.maxWidth, constraints.maxHeight * 1.6);
                    return Center(
                      child: SizedBox(
                        width: arcSize,
                        height: constraints.maxHeight,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned(
                              top: 10,
                              child: CustomPaint(
                                size: Size(arcSize, arcSize / 2),
                                painter: _SemiArcPainter(
                                  progress: _animation.value,
                                  isDark: isDark,
                                ),
                              ),
                            ),
                            // Central Temperature readout
                            Positioned(
                              top: (arcSize / 4) - 8,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (widget.temperature * _animation.value).toStringAsFixed(0),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : const Color(0xFF19241B),
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      '°C',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? const Color(0xFF7CE2DB) : const Color(0xFF2D7A54),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Sub-metrics row
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _subMetric(
                                      icon: Icons.wb_sunny_outlined,
                                      color: const Color(0xFFE5B824),
                                      title: 'Sun',
                                      value: '25% Boost',
                                      isDark: isDark,
                                    ),
                                  ),
                                  Expanded(
                                    child: _subMetric(
                                      icon: Icons.air,
                                      color: const Color(0xFF45AAF2),
                                      title: 'Wind',
                                      value: 'Up to 40%',
                                      isDark: isDark,
                                    ),
                                  ),
                                  Expanded(
                                    child: _subMetric(
                                      icon: Icons.water_drop_outlined,
                                      color: const Color(0xFF2ED573),
                                      title: 'Rain',
                                      value: '30% Reduced',
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _subMetric({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: isDark ? Colors.white54 : const Color(0xFF7A8B7E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF19241B),
          ),
        ),
      ],
    );
  }
}

class _SemiArcPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _SemiArcPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 12;

    // Track Paint
    final trackPaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFEFF2EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // Background track (180 degrees from math.pi to 2 * math.pi)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      trackPaint,
    );

    // Rainbow gradient arc
    final sweepAngle = math.pi * progress;
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final sweepGradient = SweepGradient(
      center: Alignment.bottomCenter,
      startAngle: math.pi,
      endAngle: 2 * math.pi,
      colors: const [
        Color(0xFFE2F069), // Chartreuse
        Color(0xFF86E39C), // Sprout
        Color(0xFF48DFD6), // Neon Teal
        Color(0xFF45AAF2), // Soft Blue
      ],
      stops: const [0.0, 0.4, 0.75, 1.0],
    );

    final arcPaint = Paint()
      ..shader = sweepGradient.createShader(arcRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      arcRect,
      math.pi,
      sweepAngle,
      false,
      arcPaint,
    );

    // Glowing tip indicator
    final tipAngle = math.pi + sweepAngle;
    final tipX = center.dx + radius * math.cos(tipAngle);
    final tipY = center.dy + radius * math.sin(tipAngle);

    final glowPaint = Paint()
      ..color = const Color(0xFF48DFD6).withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(tipX, tipY), 8, glowPaint);

    final tipPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(tipX, tipY), 5, tipPaint);
  }

  @override
  bool shouldRepaint(covariant _SemiArcPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
