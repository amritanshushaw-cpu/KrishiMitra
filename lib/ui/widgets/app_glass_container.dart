import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Apple-Grade Glassmorphism Card Container
/// Features frosted backdrop blur, specular hairline border, translucent gradient fill,
/// and smooth organic shadow matching Apple design standards.
class AppGlassContainer extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final bool isHovered;
  final bool hasGoldGlow;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const AppGlassContainer({
    super.key,
    required this.child,
    this.radius = 24.0,
    this.padding,
    this.margin,
    this.blur = 16.0,
    this.isHovered = false,
    this.hasGoldGlow = false,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget container = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: AppTheme.glassCardDecoration(
        isDark: isDark,
        radius: radius,
        isHovered: isHovered,
        hasGoldGlow: hasGoldGlow,
      ),
      child: child,
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
