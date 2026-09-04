import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NdviSatelliteMapCard extends StatefulWidget {
  const NdviSatelliteMapCard({super.key});

  @override
  State<NdviSatelliteMapCard> createState() => _NdviSatelliteMapCardState();
}

class _NdviSatelliteMapCardState extends State<NdviSatelliteMapCard>
    with SingleTickerProviderStateMixin {
  double _zoomLevel = 1.0;
  bool _showThermalLayer = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF263229) : const Color(0xFFE8EBE3);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141A16) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Terraced Field Contour Canvas with NDVI Thermal Stress Zone
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _TerracedNdviPainter(
                    zoom: _zoomLevel,
                    pulse: _pulseController.value,
                    showThermal: _showThermalLayer,
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),

          // Map Control Floating Tools (Left Vertical)
          Positioned(
            left: 16,
            top: 16,
            child: Column(
              children: [
                _toolButton(
                  icon: Icons.add,
                  onTap: () => setState(() => _zoomLevel = math.min(1.6, _zoomLevel + 0.15)),
                  isDark: isDark,
                ),
                const SizedBox(height: 6),
                _toolButton(
                  icon: Icons.remove,
                  onTap: () => setState(() => _zoomLevel = math.max(0.8, _zoomLevel - 0.15)),
                  isDark: isDark,
                ),
                const SizedBox(height: 6),
                _toolButton(
                  icon: Icons.layers_outlined,
                  onTap: () => setState(() => _showThermalLayer = !_showThermalLayer),
                  isActive: _showThermalLayer,
                  isDark: isDark,
                ),
                const SizedBox(height: 6),
                _toolButton(
                  icon: Icons.my_location,
                  onTap: () => setState(() => _zoomLevel = 1.0),
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // Top Right Tag
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF52B788),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'NDVI LIVE: 0.81 (OPTIMAL)',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Glassmorphic Telemetry Bar
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF121915) : const Color(0xFF283A2E))
                    .withOpacity(0.88),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Golden Harvest',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Zone 3B • Irrigated',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9.5,
                          color: const Color(0xFFA6DEAE),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _metricInfo('Soil Elevation', '320 m'),
                      _metricInfo('Nitrogen (N)', '30 - 50 kg/ha'),
                      _metricInfo('Phosphorus (P)', '15 - 25 kg/ha'),
                      _metricInfo('Potassium (K)', '150 - 200 kg/ha'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF52B788)
              : (isDark ? const Color(0xFF1E2721) : Colors.white).withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.black.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: isActive ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF26332A)),
        ),
      ),
    );
  }

  Widget _metricInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            color: Colors.white.withOpacity(0.65),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _TerracedNdviPainter extends CustomPainter {
  final double zoom;
  final double pulse;
  final bool showThermal;
  final bool isDark;

  _TerracedNdviPainter({
    required this.zoom,
    required this.pulse,
    required this.showThermal,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final width = size.width;
    final height = size.height;

    // Base background: lush terraced green gradient
    final baseGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              const Color(0xFF182A1F),
              const Color(0xFF243B2C),
              const Color(0xFF1A3323),
            ]
          : [
              const Color(0xFF4A7C59),
              const Color(0xFF5D9B6E),
              const Color(0xFF3F694B),
            ],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..shader = baseGradient.createShader(Rect.fromLTWH(0, 0, width, height)),
    );

    // Draw concentric agricultural contour rings (terraces)
    final contourPaint = Paint()
      ..color = Colors.white.withOpacity(isDark ? 0.08 : 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(width * 0.45, height * 0.45);

    for (int r = 30; r < math.max(width, height) * 0.9 * zoom; r += 24) {
      final ringPath = Path();
      for (double theta = 0; theta < 2 * math.pi; theta += 0.2) {
        // Add subtle organic distortion to make it look like natural terrain
        final wobble = 6.0 * math.sin(theta * 4 + r * 0.05);
        final currentR = r * zoom + wobble;
        final x = center.dx + currentR * math.cos(theta);
        final y = center.dy + (currentR * 0.65) * math.sin(theta);
        if (theta == 0) {
          ringPath.moveTo(x, y);
        } else {
          ringPath.lineTo(x, y);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, contourPaint);
    }

    // Draw NDVI Thermal/Moisture Stress Gradient Zone (Golden Red/Yellow center hotspot)
    if (showThermal) {
      final hotspotCenter = Offset(width * 0.42, height * 0.42);
      final hotspotWidth = width * 0.45 * zoom;
      final hotspotHeight = height * 0.35 * zoom;

      final thermalGradient = RadialGradient(
        center: Alignment.center,
        radius: 0.65,
        colors: [
          const Color(0xFFEB4D4B).withOpacity(0.85), // Red hotspot (stressed)
          const Color(0xFFF0932B).withOpacity(0.75), // Orange transition
          const Color(0xFFF6E58D).withOpacity(0.60), // Yellow
          const Color(0xFF6AB04C).withOpacity(0.20), // Green margin
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.65, 0.85, 1.0],
      );

      final thermalRect = Rect.fromCenter(
        center: hotspotCenter,
        width: hotspotWidth * (0.95 + 0.08 * pulse),
        height: hotspotHeight * (0.95 + 0.08 * pulse),
      );

      final thermalPaint = Paint()
        ..shader = thermalGradient.createShader(thermalRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      canvas.drawOval(thermalRect, thermalPaint);

      // Add small animated indicator pin at stressed zone
      final pinPaint = Paint()..color = Colors.white;
      canvas.drawCircle(hotspotCenter, 3.5, pinPaint);
      final pulseRing = Paint()
        ..color = Colors.white.withOpacity(0.5 * (1 - pulse))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(hotspotCenter, 6.0 + 8.0 * pulse, pulseRing);
    }
  }

  @override
  bool shouldRepaint(covariant _TerracedNdviPainter oldDelegate) {
    return oldDelegate.zoom != zoom ||
        oldDelegate.pulse != pulse ||
        oldDelegate.showThermal != showThermal ||
        oldDelegate.isDark != isDark;
  }
}
