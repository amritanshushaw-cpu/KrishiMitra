import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'app_glass_container.dart';

class FarmHealthRingCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = healthScore >= 80
        ? (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen)
        : (healthScore >= 60 ? AppTheme.amberWarning : AppTheme.alertRose);

    return AppGlassContainer(
      radius: 20,
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          // Circular Gradient Gauge
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(90, 90),
                  painter: _HealthScorePainter(
                    scorePercent: healthScore / 100.0,
                    trackColor: isDark ? AppTheme.deepPine : AppTheme.mintDew.withValues(alpha: 0.6),
                    progressColor: primaryColor,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$healthScore%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'CROP SCORE',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          // Metrics & Status Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusText.toUpperCase(),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Overall Farm Health Index',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildMetricPill(
                      context,
                      icon: Icons.eco_outlined,
                      label: 'Soil: $soilStatus',
                    ),
                    _buildMetricPill(
                      context,
                      icon: Icons.water_drop_outlined,
                      label: 'Moist: $moistureStatus',
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

  Widget _buildMetricPill(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slatePine.withValues(alpha: 0.45) : AppTheme.mintDew.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? AppTheme.softSage.withValues(alpha: 0.20) : AppTheme.softSage.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: isDark ? AppTheme.emeraldLight : AppTheme.sproutGreen,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
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
    final radius = (size.width - 10) / 2;
    const strokeWidth = 8.0;

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

    // Background track arc (full circle)
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * scorePercent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HealthScorePainter oldDelegate) {
    return oldDelegate.scorePercent != scorePercent ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor;
  }
}
