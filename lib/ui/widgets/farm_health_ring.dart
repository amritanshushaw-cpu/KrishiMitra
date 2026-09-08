import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../state/farm_provider.dart';
import 'app_glass_container.dart';

/// Plant Vitality & Health Score Card
/// Organic, clean Plant Tracker UI design inspired by Viktoriia Push on Dribbble.
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
    final provider = Provider.of<FarmProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOptimal = healthScore >= 80;

    final primaryColor = isOptimal
        ? (isDark ? AppTheme.neonMint : const Color(0xFF2D6A4F))
        : (healthScore >= 60 ? AppTheme.amberWarning : AppTheme.alertRose);

    final trackColor = isDark
        ? const Color(0xFF262626)
        : const Color(0xFFE8F5EE);

    final friendlyStatus = isOptimal ? '🌿 Thriving & Healthy' : '⚠️ Attention Needed';

    return AppGlassContainer(
      radius: 24,
      isLiquid: true,
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Circular Organic Vitality Gauge
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(96, 96),
                  painter: _HealthScorePainter(
                    scorePercent: healthScore / 100.0,
                    trackColor: trackColor,
                    progressColor: primaryColor,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$healthScore%',
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
                      label: 'Soil: $soilStatus',
                      accentColor: isDark ? AppTheme.neonMint : const Color(0xFF40916C),
                    ),
                    _buildCarePill(
                      context,
                      icon: Icons.water_drop_rounded,
                      label: 'Moist: $moistureStatus',
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

    // Draw track
    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc
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
