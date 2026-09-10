import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../state/farm_provider.dart';
import 'app_glass_container.dart';

/// Plant Vitality & Health Score Card
/// Organic, clean Plant Tracker UI design with fluid 0 -> 100% loading sweep animation.
class FarmHealthRingCard extends StatefulWidget {
  final int healthScore; // 0 - 100
  final String statusText;
  final String soilStatus;
  final String moistureStatus;
  final VoidCallback? onTap;

  const FarmHealthRingCard({
    super.key,
    required this.healthScore,
    required this.statusText,
    required this.soilStatus,
    required this.moistureStatus,
    this.onTap,
  });

  @override
  State<FarmHealthRingCard> createState() => _FarmHealthRingCardState();
}

class _FarmHealthRingCardState extends State<FarmHealthRingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;
  int? _lastTabIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.88, end: 1.03)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.03, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 35,
      ),
    ]).animate(_controller);

    _controller.forward(from: 0.0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<FarmProvider>(context, listen: true);
    if (_lastTabIndex != null && _lastTabIndex != 0 && provider.activeTabIndex == 0) {
      _controller.forward(from: 0.0);
    }
    _lastTabIndex = provider.activeTabIndex;
  }

  @override
  void didUpdateWidget(covariant FarmHealthRingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.healthScore != widget.healthScore) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FarmProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final targetScore = widget.healthScore;
    final isOptimal = targetScore >= 80;

    final primaryColor = isOptimal
        ? (isDark ? AppTheme.neonMint : const Color(0xFF2D6A4F))
        : (targetScore >= 60 ? AppTheme.amberWarning : AppTheme.alertRose);

    final trackColor = isDark
        ? const Color(0xFF262626)
        : const Color(0xFFE8F5EE);

    final friendlyStatus = isOptimal ? '🌿 Thriving & Healthy' : '⚠️ Attention Needed';

    return AppGlassContainer(
      radius: 24,
      isLiquid: true,
      onTap: () {
        _controller.forward(from: 0.0);
        widget.onTap?.call();
      },
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Circular Organic Vitality Gauge with 0 -> 100% animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final animatedValue = _progressAnimation.value;
              final currentScore = (animatedValue * targetScore).round();
              final currentPercent = animatedValue * (targetScore / 100.0);

              return SizedBox(
                width: 96,
                height: 96,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(96, 96),
                        painter: _HealthScorePainter(
                          scorePercent: currentPercent,
                          trackColor: trackColor,
                          progressColor: primaryColor,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$currentScore%',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF1B4332),
                              letterSpacing: -0.6,
                            ),
                          ),
                          Text(
                            provider.strings.cropScore,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppTheme.darkTextMuted : const Color(0xFF52B788),
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 20),

          // Metrics & Friendly Plant Tracker Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: isDark ? 0.16 : 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    friendlyStatus,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.strings.overallHealth,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF1B4332),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildCarePill(
                      context,
                      icon: Icons.eco_rounded,
                      label: 'Soil: ${widget.soilStatus}',
                      accentColor: isDark ? AppTheme.neonMint : const Color(0xFF40916C),
                    ),
                    _buildCarePill(
                      context,
                      icon: Icons.water_drop_rounded,
                      label: 'Moist: ${widget.moistureStatus}',
                      accentColor: AppTheme.skyBlue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarePill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color accentColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF242424)
            : const Color(0xFFF0F7F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.20),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: accentColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF2D6A4F),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthScorePainter extends CustomPainter {
  final double scorePercent;
  final Color trackColor;
  final Color progressColor;

  _HealthScorePainter({
    required this.scorePercent,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;
    const strokeWidth = 8.5;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background track ring
    canvas.drawCircle(center, radius, trackPaint);

    if (scorePercent > 0.001) {
      if (scorePercent >= 0.999) {
        // Complete 100% full circle
        canvas.drawCircle(center, radius, progressPaint);
      } else {
        // Draw progress arc from top (-pi/2) clockwise
        const startAngle = -math.pi / 2;
        final sweepAngle = 2 * math.pi * scorePercent.clamp(0.0, 1.0);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          progressPaint,
        );

        // Leading edge glow bead while animating
        final tipAngle = startAngle + sweepAngle;
        final tipX = center.dx + radius * math.cos(tipAngle);
        final tipY = center.dy + radius * math.sin(tipAngle);

        final glowPaint = Paint()
          ..color = progressColor.withValues(alpha: 0.45)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
        canvas.drawCircle(Offset(tipX, tipY), strokeWidth / 2 + 1.5, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HealthScorePainter oldDelegate) {
    return oldDelegate.scorePercent != scorePercent ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor;
  }
}
