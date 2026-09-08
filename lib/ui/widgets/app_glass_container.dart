import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'liquid_glass_container.dart';

/// Apple-Grade Glassmorphism & Liquid Glass Card Container
/// Features frosted backdrop blur, specular hairline border, translucent gradient fill,
/// and smooth organic shadow. Supports dynamic liquid glass mode.
class AppGlassContainer extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final bool isHovered;
  final bool hasGoldGlow;
  final bool isLiquid;
  final List<Color>? liquidColors;
  final bool hasShineBorder;
  final List<Color>? shineColors;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const AppGlassContainer({
    super.key,
    required this.child,
    this.radius = 24.0,
    this.padding,
    this.margin,
    this.blur = 10.0,
    this.isHovered = false,
    this.hasGoldGlow = false,
    this.isLiquid = false,
    this.liquidColors,
    this.hasShineBorder = false,
    this.shineColors,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLiquid) {
      return LiquidGlassContainer(
        radius: radius,
        padding: padding,
        margin: margin,
        blur: blur,
        width: width,
        height: height,
        onTap: onTap,
        liquidColors: liquidColors,
        child: child,
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget container = AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      width: width,
      height: height,
      padding: padding,
      decoration: AppTheme.glassCardDecoration(
        isDark: isDark,
        radius: radius,
        isHovered: isHovered,
        hasGoldGlow: hasGoldGlow,
      ),
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );

    Widget frosted = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: container,
      ),
    );

    if (onTap != null) {
      frosted = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: frosted,
      );
    }

    if (margin != null) {
      return Padding(padding: margin!, child: frosted);
    }

    return frosted;
  }
}
