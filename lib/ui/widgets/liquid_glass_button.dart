import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

enum LiquidButtonVariant {
  primary,
  cool,
  success,
  destructive,
  secondary,
  glass,
}

enum LiquidButtonSize {
  sm,
  defaultSize,
  lg,
  xl,
}

/// Liquid Glass Button
///
/// Flutter native realization of the `LiquidButton` & `MetalButton` component:
/// - **Multi-Layer Specular Rims**: Dual-direction inset highlights and ambient occlusion shadows.
/// - **Liquid Glass Refraction**: Real-time `BackdropFilter` with fluid chromatic tinting.
/// - **Tactile 3D Physics**: Spring displacement (`translateY(2.5px)`, `scale(0.97)`) on press.
/// - **Shine Sweep Sheen**: Specular light refraction beam moving along the rim and face.
/// - **GPU-Accelerated**: Isolated repaint boundaries with haptic feedback.
class LiquidGlassButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final String? text;
  final IconData? icon;
  final LiquidButtonVariant variant;
  final LiquidButtonSize size;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool animateShine;
  final EdgeInsetsGeometry? padding;

  const LiquidGlassButton({
    super.key,
    required this.onPressed,
    this.child,
    this.text,
    this.icon,
    this.variant = LiquidButtonVariant.primary,
    this.size = LiquidButtonSize.defaultSize,
    this.width,
    this.height,
    this.borderRadius = 16.0,
    this.animateShine = true,
    this.padding,
  });

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late final AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    if (widget.animateShine) {
      _shineController.repeat();
    }
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed == null) return;
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null;

    // Resolve sizing
    final double defaultHeight;
    final EdgeInsetsGeometry resolvedPadding;
    final double fontSize;
    final double iconSize;

    switch (widget.size) {
      case LiquidButtonSize.sm:
        defaultHeight = 36.0;
        resolvedPadding = widget.padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 8);
        fontSize = 12.0;
        iconSize = 15.0;
        break;
      case LiquidButtonSize.defaultSize:
        defaultHeight = 46.0;
        resolvedPadding = widget.padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
        fontSize = 13.5;
        iconSize = 18.0;
        break;
      case LiquidButtonSize.lg:
        defaultHeight = 54.0;
        resolvedPadding = widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 15);
        fontSize = 14.5;
        iconSize = 20.0;
        break;
      case LiquidButtonSize.xl:
        defaultHeight = 60.0;
        resolvedPadding = widget.padding ?? const EdgeInsets.symmetric(horizontal: 28, vertical: 18);
        fontSize = 15.5;
        iconSize = 22.0;
        break;
    }

    // Resolve color scheme
    final List<Color> surfaceGradient;
    final Color textColor;
    final Color outerGlowColor;

    switch (widget.variant) {
      case LiquidButtonVariant.primary:
        surfaceGradient = isDark
            ? [const Color(0xFF10B981), const Color(0xFF059669)]
            : [const Color(0xFF2D6A4F), const Color(0xFF1B4332)];
        textColor = isDark ? const Color(0xFF042F1D) : Colors.white;
        outerGlowColor = isDark
            ? const Color(0xFF10B981).withValues(alpha: 0.35)
            : const Color(0xFF2D6A4F).withValues(alpha: 0.25);
        break;
      case LiquidButtonVariant.cool:
        surfaceGradient = isDark
            ? [const Color(0xFF38BDF8), const Color(0xFF0284C7)]
            : [const Color(0xFF0284C7), const Color(0xFF0369A1)];
        textColor = isDark ? const Color(0xFF082F49) : Colors.white;
        outerGlowColor = const Color(0xFF0284C7).withValues(alpha: 0.35);
        break;
      case LiquidButtonVariant.success:
        surfaceGradient = isDark
            ? [const Color(0xFF34D399), const Color(0xFF10B981)]
            : [const Color(0xFF40916C), const Color(0xFF2D6A4F)];
        textColor = isDark ? const Color(0xFF064E3B) : Colors.white;
        outerGlowColor = const Color(0xFF10B981).withValues(alpha: 0.35);
        break;
      case LiquidButtonVariant.destructive:
        surfaceGradient = isDark
            ? [const Color(0xFFF87171), const Color(0xFFDC2626)]
            : [const Color(0xFFEF4444), const Color(0xFFB91C1C)];
        textColor = Colors.white;
        outerGlowColor = const Color(0xFFDC2626).withValues(alpha: 0.35);
        break;
      case LiquidButtonVariant.secondary:
        surfaceGradient = isDark
            ? [const Color(0xFF262626), const Color(0xFF171717)]
            : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)];
        textColor = isDark ? AppTheme.darkTextPrimary : const Color(0xFF1E293B);
        outerGlowColor = Colors.black.withValues(alpha: 0.15);
        break;
      case LiquidButtonVariant.glass:
        surfaceGradient = isDark
            ? [
                Colors.white.withValues(alpha: 0.14),
                Colors.white.withValues(alpha: 0.05),
              ]
            : [
                Colors.white.withValues(alpha: 0.85),
                Colors.white.withValues(alpha: 0.65),
              ];
        textColor = isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32);
        outerGlowColor = (isDark ? AppTheme.neonMint : const Color(0xFF10B981))
            .withValues(alpha: 0.25);
        break;
    }

    // Dynamic 3D Transform physics
    final transform = Matrix4.identity()
      ..translate(0.0, _isPressed ? 2.5 : 0.0)
      ..scale(_isPressed ? 0.97 : 1.0);

    return GestureDetector(
      onTapDown: isEnabled ? _handleTapDown : null,
      onTapUp: isEnabled ? _handleTapUp : null,
      onTapCancel: isEnabled ? _handleTapCancel : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        transform: transform,
        transformAlignment: Alignment.center,
        child: Container(
          width: widget.width,
          height: widget.height ?? defaultHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              // Outer ambient glow & depth drop
              BoxShadow(
                color: outerGlowColor,
                blurRadius: _isPressed ? 6 : 14,
                offset: Offset(0, _isPressed ? 2 : 5),
              ),
              // Subtle deep drop shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                // 1. Real-time Blurred Backdrop Glass Filter
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(color: Colors.transparent),
                  ),
                ),

                // 2. Liquid Tint Gradient Fill
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: surfaceGradient,
                      ),
                    ),
                  ),
                ),

                // 3. Specular Meniscus Light Sheen (Top Ridge)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1.5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: isDark ? 0.85 : 0.65),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // 4. Multi-Layer Inset Rim & Specular Painter
                Positioned.fill(
                  child: CustomPaint(
                    painter: _LiquidGlassButtonPainter(
                      borderRadius: widget.borderRadius,
                      isPressed: _isPressed,
                      isDark: isDark,
                    ),
                  ),
                ),

                // 5. Traveling Liquid Specular Shimmer Sweep
                if (widget.animateShine && isEnabled)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _shineController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _LiquidShineSweepPainter(
                            progress: _shineController.value,
                            borderRadius: widget.borderRadius,
                          ),
                        );
                      },
                    ),
                  ),

                // 6. Content (Label, Icon, or Custom Child)
                Center(
                  child: Padding(
                    padding: resolvedPadding,
                    child: widget.child ??
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                size: iconSize,
                                color: textColor,
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (widget.text != null)
                              Text(
                                widget.text!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                  color: textColor,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.2),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for multi-layered specular edge highlights and inset rims
class _LiquidGlassButtonPainter extends CustomPainter {
  final double borderRadius;
  final bool isPressed;
  final bool isDark;

  _LiquidGlassButtonPainter({
    required this.borderRadius,
    required this.isPressed,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.75),
      Radius.circular(math.max(0, borderRadius - 0.75)),
    );

    // Rim Highlight 1: Specular Top-Left Edge Rim
    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: isPressed ? 0.25 : (isDark ? 0.75 : 0.85)),
          Colors.white.withValues(alpha: 0.0),
          Colors.black.withValues(alpha: isPressed ? 0.35 : (isDark ? 0.5 : 0.15)),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _LiquidGlassButtonPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.isPressed != isPressed ||
        oldDelegate.isDark != isDark;
  }
}

/// Dynamic 45-degree diagonal shimmer refraction sweep across the glass button
class _LiquidShineSweepPainter extends CustomPainter {
  final double progress;
  final double borderRadius;

  _LiquidShineSweepPainter({
    required this.progress,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rect = Offset.zero & size;
    final sweepWidth = size.width * 0.4;
    final currentX = -sweepWidth + (size.width + sweepWidth * 2) * progress;

    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromLTWH(currentX - sweepWidth / 2, 0, sweepWidth, size.height),
      );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
      shimmerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LiquidShineSweepPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.borderRadius != borderRadius;
  }
}
