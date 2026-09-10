import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../state/farm_provider.dart';
import 'liquid_glass_container.dart';

/// Ultra-Modern Plant Vitality & Composite Crop Health Index (CCHI) Card
///
/// Designed with aerospace-grade precision dials, bioluminescent neon blooms,
/// fluid liquid glass refraction, animated countdown/countup dials, and multi-factor
/// agronomic telemetry breakdown.
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
    with TickerProviderStateMixin {
  late AnimationController _sweepController;
  late Animation<double> _scoreAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: widget.healthScore.toDouble(),
    ).animate(CurvedAnimation(
      parent: _sweepController,
      curve: Curves.easeOutCubic,
    ));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _sweepController.forward();
  }

  @override
  void didUpdateWidget(covariant FarmHealthRingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.healthScore != widget.healthScore) {
      _scoreAnimation = Tween<double>(
        begin: _scoreAnimation.value,
        end: widget.healthScore.toDouble(),
      ).animate(CurvedAnimation(
        parent: _sweepController,
        curve: Curves.easeOutCubic,
      ));
      _sweepController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FarmProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int score = widget.healthScore;
    final bool isOptimal = score >= 80;
    final bool isWarning = score >= 60 && score < 80;

    // Harmonious curated palette matching Vercel & OLED Agro guidelines
    final Color primaryAccent = isOptimal
        ? (isDark ? AppTheme.neonMint : const Color(0xFF10B981))
        : (isWarning ? AppTheme.amberWarning : AppTheme.alertRose);

    final Color secondaryAccent = isOptimal
        ? (isDark ? const Color(0xFF00E5FF) : const Color(0xFF059669))
        : (isWarning ? const Color(0xFFFB8500) : const Color(0xFFFF5470));

    final String statusBadgeText = isOptimal
        ? '🌿 THRIVING // OPTIMAL'
        : (isWarning ? '⚠️ MODERATE STRESS' : '🚨 CRITICAL ATTENTION');

    final String summaryVerdict = isOptimal
        ? 'Optimal canopy vigor, balanced root hydration, and low pathogen vulnerability.'
        : (isWarning
            ? 'Moisture or thermal variance detected. Review irrigation & foliar advisory.'
            : 'Immediate corrective action required. Check pump lock and treatment logs.');

    // Secondary Telemetry Values from live state
    final double temp = provider.sensorData.temperature;
    final String tempStatus = temp > 35.0 ? 'Heat Stress' : (temp < 15.0 ? 'Cold' : 'Optimal');
    final Color tempColor = temp > 35.0 || temp < 15.0 ? AppTheme.amberWarning : AppTheme.emeraldLight;

    final String pathogenStatus = provider.parsedDiagnosis != null
        ? provider.parsedDiagnosis!.disease.value
        : 'Nominal';
    final bool hasPathogenRisk = provider.parsedDiagnosis != null &&
        provider.parsedDiagnosis!.disease.value.toLowerCase() != 'healthy';
    final Color pathogenColor = hasPathogenRisk ? AppTheme.alertRose : AppTheme.emeraldLight;

    final Color soilColor = provider.sensorData.isSoilCriticallyDry || provider.sensorData.isSoilSaturated
        ? AppTheme.amberWarning
        : AppTheme.skyBlue;

    return AnimatedBuilder(
      animation: Listenable.merge([_scoreAnimation, _pulseAnimation]),
      builder: (context, _) {
        final double currentAnimatedScore = _scoreAnimation.value;

        return LiquidGlassContainer(
          radius: 26,
          onTap: widget.onTap,
          liquidColors: isOptimal
              ? [
                  primaryAccent.withValues(alpha: isDark ? 0.18 : 0.12),
                  secondaryAccent.withValues(alpha: isDark ? 0.12 : 0.08),
                  Colors.teal.withValues(alpha: isDark ? 0.08 : 0.04),
                ]
              : (isWarning
                  ? [
                      AppTheme.amberWarning.withValues(alpha: isDark ? 0.18 : 0.12),
                      Colors.orangeAccent.withValues(alpha: isDark ? 0.10 : 0.06),
                    ]
                  : [
                      AppTheme.alertRose.withValues(alpha: isDark ? 0.22 : 0.14),
                      Colors.pinkAccent.withValues(alpha: isDark ? 0.12 : 0.08),
                    ]),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Telemetry Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryAccent.withValues(alpha: isDark ? 0.18 : 0.14),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: primaryAccent.withValues(alpha: isDark ? 0.35 : 0.25),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.eco_rounded,
                          size: 14,
                          color: primaryAccent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ICAR CCHI // BIO-HEALTH INDEX',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),

                  // Live Pulsing Beacon Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.40 : 0.70),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (isDark ? AppTheme.darkBorder : AppTheme.softSage).withValues(alpha: 0.30),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: primaryAccent.withValues(alpha: _pulseAnimation.value),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryAccent.withValues(alpha: 0.60 * _pulseAnimation.value),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE SYNC',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 2. Center Dial & Diagnostic Overview Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Precision Aerospace-Grade Gauge Dial
                  SizedBox(
                    width: 114,
                    height: 114,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(114, 114),
                          painter: _HealthScoreDialPainter(
                            scorePercent: (currentAnimatedScore / 100.0).clamp(0.0, 1.0),
                            primaryColor: primaryAccent,
                            secondaryColor: secondaryAccent,
                            trackColor: isDark
                                ? const Color(0xFF262626)
                                : const Color(0xFFE2E8F0),
                            isDark: isDark,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${currentAnimatedScore.toInt()}',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    height: 1.0,
                                    color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF0F172A),
                                    letterSpacing: -1.2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    '%',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: primaryAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: primaryAccent.withValues(alpha: isDark ? 0.20 : 0.14),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isOptimal ? 'OPTIMAL' : (isWarning ? 'CAUTION' : 'ALERT'),
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: primaryAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),

                  // Status badge and verdict breakdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryAccent.withValues(alpha: isDark ? 0.16 : 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryAccent.withValues(alpha: 0.28),
                              width: 0.9,
                            ),
                          ),
                          child: Text(
                            statusBadgeText,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                              color: primaryAccent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.strings.overallHealth,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          summaryVerdict,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            height: 1.35,
                            color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF475569),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Multi-Factor Agronomic Telemetry Bento Row
              Row(
                children: [
                  Expanded(
                    child: _buildBentoPill(
                      context,
                      icon: Icons.water_drop_outlined,
                      label: 'Soil Hydration',
                      value: '${widget.moistureStatus} (${widget.soilStatus})',
                      accentColor: soilColor,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildBentoPill(
                      context,
                      icon: Icons.thermostat_outlined,
                      label: 'Thermal Status',
                      value: '${temp.toStringAsFixed(1)}°C ($tempStatus)',
                      accentColor: tempColor,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildBentoPill(
                      context,
                      icon: Icons.shield_outlined,
                      label: 'Canopy Health',
                      value: pathogenStatus,
                      accentColor: pathogenColor,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 4. Interactive Bottom Deep-Dive Action Prompt
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '360° DIAGNOSTIC & STRESS BREAKDOWN',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'EXPLORE',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: primaryAccent,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: primaryAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBentoPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF141414) : const Color(0xFFF8FAFC)).withValues(alpha: isDark ? 0.70 : 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (isDark ? const Color(0xFF262626) : const Color(0xFFE2E8F0)).withValues(alpha: 0.8),
          width: 0.9,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: accentColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextMuted : const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF0F172A),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Custom Precision Chronometer Dial with Outer Calibration Ticks & Gradient Sweep
class _HealthScoreDialPainter extends CustomPainter {
  final double scorePercent;
  final Color primaryColor;
  final Color secondaryColor;
  final Color trackColor;
  final bool isDark;

  _HealthScoreDialPainter({
    required this.scorePercent,
    required this.primaryColor,
    required this.secondaryColor,
    required this.trackColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    const double strokeWidth = 9.0;

    // 1. Soft Central Bioluminescent Bloom
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withValues(alpha: isDark ? 0.16 : 0.10),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.95));
    canvas.drawCircle(center, radius * 0.95, glowPaint);

    // 2. Precision Outer Calibration Ticks (40 tick marks)
    const int tickCount = 40;
    final double tickRadiusOuter = radius + 9.0;
    final int activeTicks = (tickCount * scorePercent).round();

    for (int i = 0; i < tickCount; i++) {
      final double angle = -math.pi / 2 + (2 * math.pi * i / tickCount);
      final bool isActive = i < activeTicks;
      final double tickLength = (i % 5 == 0) ? 4.5 : 2.5;

      final double r1 = tickRadiusOuter;
      final double r2 = tickRadiusOuter - tickLength;

      final p1 = Offset(center.dx + r1 * math.cos(angle), center.dy + r1 * math.sin(angle));
      final p2 = Offset(center.dx + r2 * math.cos(angle), center.dy + r2 * math.sin(angle));

      final tickPaint = Paint()
        ..color = isActive
            ? primaryColor.withValues(alpha: isDark ? 0.85 : 0.75)
            : trackColor.withValues(alpha: isDark ? 0.35 : 0.25)
        ..strokeWidth = (i % 5 == 0) ? 1.4 : 0.9
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(p1, p2, tickPaint);
    }

    // 3. Background Track Arc
    final trackPaint = Paint()
      ..color = trackColor.withValues(alpha: isDark ? 0.35 : 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // 4. Dynamic Multi-Stop Gradient Progress Arc
    if (scorePercent > 0.005) {
      const double startAngle = -math.pi / 2;
      final double sweepAngle = 2 * math.pi * scorePercent;

      final gradientPaint = Paint()
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweepAngle,
          colors: [
            secondaryColor,
            primaryColor,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        gradientPaint,
      );

      // 5. Glowing Neon Head Indicator (Leading Edge Bloom)
      final double tipAngle = startAngle + sweepAngle;
      final tipCenter = Offset(
        center.dx + radius * math.cos(tipAngle),
        center.dy + radius * math.sin(tipAngle),
      );

      // Outer Bloom
      final tipBloomPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(tipCenter, 6.0, tipBloomPaint);

      // Solid Core
      final tipCorePaint = Paint()..color = Colors.white;
      canvas.drawCircle(tipCenter, 2.5, tipCorePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HealthScoreDialPainter oldDelegate) {
    return oldDelegate.scorePercent != scorePercent ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.isDark != isDark;
  }
}
