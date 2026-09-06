import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class SigmoidGrowthCurveChart extends StatefulWidget {
  const SigmoidGrowthCurveChart({super.key});

  @override
  State<SigmoidGrowthCurveChart> createState() =>
      _SigmoidGrowthCurveChartState();
}

class _SigmoidGrowthCurveChartState extends State<SigmoidGrowthCurveChart>
    with TickerProviderStateMixin {
  late AnimationController _drawController;
  late Animation<double> _drawAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _drawAnimation = CurvedAnimation(
      parent: _drawController,
      curve: Curves.easeInOutCubic,
    );
    _drawController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _drawController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerAiDetect() {
    setState(() => _isDetecting = true);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() => _isDetecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Autonomous Edge Detection: Vegetative phase 94.2% optimal',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppTheme.forestMoss,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
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
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Data Meets Growth',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: -0.4,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
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

          const SizedBox(height: 16),

          // Main Chart + Side Stats Layout
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 540;

                if (isCompact) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: _buildCurveCanvas(isDark, textMuted),
                        ),
                        const SizedBox(height: 16),
                        _buildSideStats(isDark, textMuted),
                      ],
                    ),
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Curve Canvas
                    Expanded(
                      flex: 6,
                      child: _buildCurveCanvas(isDark, textMuted),
                    ),
                    const SizedBox(width: 20),
                    // Stats side column
                    SizedBox(
                      width: 210,
                      child: _buildSideStats(isDark, textMuted),
                    ),
                  ],
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

  Widget _buildCurveCanvas(bool isDark, Color textMuted) {
    return Column(
      children: [
        // Stage phase labels
        Wrap(
          alignment: WrapAlignment.spaceAround,
          spacing: 6,
          runSpacing: 4,
          children: [
            _stageLabel('Germination', textMuted),
            _stageLabel('Stem Elongation', textMuted, isActive: true),
            _stageLabel('Grain Formation', textMuted),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: AnimatedBuilder(
            animation: Listenable.merge([_drawAnimation, _pulseAnimation]),
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _SigmoidCurvesPainter(
                  progress: _drawAnimation.value,
                  pulse: _pulseAnimation.value,
                  isDark: isDark,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _stageLabel(String title, Color textMuted, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.softSage.withValues(alpha: 0.20)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: AppTheme.softSage.withValues(alpha: 0.40), width: 1.0)
            : null,
      ),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          color: isActive ? (textMuted) : textMuted,
        ),
      ),
    );
  }

  Widget _buildSideStats(bool isDark, Color textMuted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            _statTile('+2.3% / week', 'Growth Rate', isDark),
            _statTile('72 hrs / cycle', 'Photoperiod', isDark),
            _statTile('68% optimal', 'Moisture Level', isDark),
            _statTile('3.6 tons / ha', 'Expected Yield', isDark),
            _statTile('79% filling', 'Growth Stage', isDark),
            _statTile('2.5 tons / ha', 'AI Forecasted', isDark),
          ],
        ),
        const SizedBox(height: 8),
        // AI Detect Action Button
        GestureDetector(
          onTap: _isDetecting ? null : _triggerAiDetect,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.deepPine : AppTheme.forestMoss,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (isDark ? AppTheme.softSage : Colors.white).withValues(alpha: 0.35),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? AppTheme.midnightTeal : AppTheme.forestMoss).withValues(alpha: 0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 8 * _pulseAnimation.value,
                      height: 8 * _pulseAnimation.value,
                      decoration: const BoxDecoration(
                        color: AppTheme.softSage,
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  _isDetecting ? 'Scanning...' : 'AI Detect',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statTile(String value, String label, bool isDark) {
    return SizedBox(
      width: 92,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SigmoidCurvesPainter extends CustomPainter {
  final double progress;
  final double pulse;
  final bool isDark;

  _SigmoidCurvesPainter({
    required this.progress,
    required this.pulse,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final width = size.width;
    final height = size.height;

    // Grid lines
    final gridPaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04)
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 3; i++) {
      final y = height * (i / 4.0);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Sigmoid Curve 1: Descending baseline trajectory
    final p1 = Path();
    p1.moveTo(0, height * 0.70);
    p1.cubicTo(
      width * 0.40 * progress,
      height * 0.70,
      width * 0.45 * progress,
      height * 0.88,
      width * 0.85 * progress,
      height * 0.88,
    );

    final linePaint1 = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.20) : const Color(0xFFD4DAD0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(p1, linePaint1);

    // Sigmoid Curve 2: Mid-stage active vegetative trajectory
    final p2 = Path();
    p2.moveTo(0, height * 0.50);
    p2.cubicTo(
      width * 0.35 * progress,
      height * 0.50,
      width * 0.45 * progress,
      height * 0.40,
      width * 0.90 * progress,
      height * 0.40,
    );

    final linePaint2 = Paint()
      ..color = isDark ? const Color(0xFF6EDDB0).withOpacity(0.4) : const Color(0xFFB1D8C1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(p2, linePaint2);

    // Sigmoid Curve 3: High yield potential trajectory
    final p3 = Path();
    p3.moveTo(0, height * 0.40);
    p3.cubicTo(
      width * 0.40 * progress,
      height * 0.40,
      width * 0.60 * progress,
      height * 0.22,
      width * 0.95 * progress,
      height * 0.22,
    );

    final linePaint3 = Paint()
      ..color = const Color(0xFF52B788)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(p3, linePaint3);

    // Glowing green nodes along inflection points
    if (progress > 0.6) {
      _drawGlowingSphere(
        canvas: canvas,
        pos: Offset(width * 0.50, height * 0.86),
        radius: 6.5,
        pulse: pulse,
      );
      _drawGlowingSphere(
        canvas: canvas,
        pos: Offset(width * 0.58, height * 0.42),
        radius: 6.5,
        pulse: pulse,
      );
      _drawGlowingSphere(
        canvas: canvas,
        pos: Offset(width * 0.68, height * 0.24),
        radius: 7.0,
        pulse: pulse,
      );
    }
  }

  void _drawGlowingSphere({
    required Canvas canvas,
    required Offset pos,
    required double radius,
    required double pulse,
  }) {
    // Outer radial glow
    final glowPaint = Paint()
      ..color = const Color(0xFF52B788).withOpacity(0.35)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * pulse);
    canvas.drawCircle(pos, radius * 1.8 * pulse, glowPaint);

    // Mid sphere gradient
    final spherePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFD4ED71),
          const Color(0xFF52B788),
          const Color(0xFF2D7A54),
        ],
        stops: const [0.1, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: pos, radius: radius));
    canvas.drawCircle(pos, radius, spherePaint);

    // Specular highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(pos.dx - 2, pos.dy - 2), 2, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _SigmoidCurvesPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.pulse != pulse ||
        oldDelegate.isDark != isDark;
  }
}
