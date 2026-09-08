import 'dart:ui';
import 'package:flutter/material.dart';

/// SmoothEntranceModal
/// Implements modal and dialog entrance & exit animation specs:
/// 
/// /* Entrance */
/// - Backdrop: opacity 0 → 1 (200ms)
/// - Content: scale(0.95 → 1) + opacity 0 → 1 (300ms)
/// - Stagger: Backdrop first, then content
/// 
/// /* Exit */
/// - Reverse animation
/// - Faster duration (200ms)
class SmoothEntranceModal extends StatefulWidget {
  final Widget child;
  final VoidCallback? onDismiss;
  final bool isDismissible;
  final Alignment contentAlignment;
  final Color? backdropColor;

  const SmoothEntranceModal({
    super.key,
    required this.child,
    this.onDismiss,
    this.isDismissible = true,
    this.contentAlignment = Alignment.bottomCenter,
    this.backdropColor,
  });

  @override
  State<SmoothEntranceModal> createState() => _SmoothEntranceModalState();
}

class _SmoothEntranceModalState extends State<SmoothEntranceModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Staggered timing constants:
  // Backdrop: 0ms -> 200ms
  // Content: 80ms -> 380ms (300ms duration)
  // Total Entrance = 380ms
  // Exit: 200ms reverse
  static const int _entranceDurationMs = 380;
  static const int _backdropDurationMs = 200;
  static const int _contentDelayMs = 80;
  static const int _exitDurationMs = 200;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _entranceDurationMs),
      reverseDuration: const Duration(milliseconds: _exitDurationMs),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> dismiss() async {
    await _controller.reverse();
    if (mounted && widget.onDismiss != null) {
      widget.onDismiss!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBackdrop = (isDark ? Colors.black : const Color(0xFF051F20)).withValues(alpha: 0.60);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final double t = _controller.value; // 0.0 -> 1.0

        // 1. Backdrop: opacity 0 -> 1 (200ms)
        // 200ms of 380ms = ~0.526
        final double backdropT = (t / (_backdropDurationMs / _entranceDurationMs)).clamp(0.0, 1.0);
        final double backdropOpacity = Curves.easeOut.transform(backdropT);

        // 2. Content: scale(0.95 -> 1) + opacity 0 -> 1 (300ms)
        // Stagger: starts at 80ms (80 / 380 = ~0.211) and finishes at 380ms
        const double contentStart = _contentDelayMs / _entranceDurationMs;
        final double contentT = ((t - contentStart) / (1.0 - contentStart)).clamp(0.0, 1.0);
        final double contentOpacity = Curves.easeOut.transform(contentT);
        final double contentScale = lerpDouble(0.95, 1.0, Curves.easeOutCubic.transform(contentT))!;

        return Stack(
          alignment: widget.contentAlignment,
          children: [
            // Backdrop with tap-to-dismiss
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.isDismissible
                    ? () {
                        if (widget.onDismiss != null) {
                          widget.onDismiss!();
                        } else {
                          Navigator.of(context).maybePop();
                        }
                      }
                    : null,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: (10.0 * backdropOpacity).clamp(0.001, 10.0),
                    sigmaY: (10.0 * backdropOpacity).clamp(0.001, 10.0),
                  ),
                  child: Opacity(
                    opacity: backdropOpacity,
                    child: Container(
                      color: widget.backdropColor ?? defaultBackdrop,
                    ),
                  ),
                ),
              ),
            ),

            // Content with scale(0.95 -> 1) and opacity 0 -> 1
            Transform.scale(
              scale: contentScale,
              alignment: widget.contentAlignment == Alignment.bottomCenter
                  ? Alignment.bottomCenter
                  : Alignment.center,
              child: Opacity(
                opacity: contentOpacity,
                child: Material(
                  type: MaterialType.transparency,
                  child: widget.child,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Helper function to display any modal bottom sheet with the exact smooth entrance & exit
Future<T?> showSmoothModalSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  Alignment contentAlignment = Alignment.bottomCenter,
  Color? backdropColor,
}) {
  return Navigator.of(context).push<T>(
    _SmoothModalRoute<T>(
      builder: builder,
      isDismissible: isDismissible,
      contentAlignment: contentAlignment,
      backdropColor: backdropColor,
    ),
  );
}

/// Helper function to display any centered dialog with the exact smooth entrance & exit
Future<T?> showSmoothDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  Color? backdropColor,
}) {
  return Navigator.of(context).push<T>(
    _SmoothModalRoute<T>(
      builder: builder,
      isDismissible: isDismissible,
      contentAlignment: Alignment.center,
      backdropColor: backdropColor,
    ),
  );
}

class _SmoothModalRoute<T> extends PopupRoute<T> {
  final WidgetBuilder builder;
  final Alignment contentAlignment;
  final Color? backdropColor;
  final bool isDismissible;

  _SmoothModalRoute({
    required this.builder,
    this.contentAlignment = Alignment.bottomCenter,
    this.backdropColor,
    this.isDismissible = true,
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 380);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return const SizedBox.shrink();
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final double t = animation.value;

    // Backdrop: opacity 0 -> 1 (200ms)
    final double backdropT = (t / (200 / 380)).clamp(0.0, 1.0);
    final double backdropOpacity = Curves.easeOut.transform(backdropT);

    // Content: scale(0.95 -> 1) + opacity 0 -> 1 (300ms, staggered after 80ms)
    const double contentStart = 80 / 380;
    final double contentT = ((t - contentStart) / (1.0 - contentStart)).clamp(0.0, 1.0);
    final double contentOpacity = Curves.easeOut.transform(contentT);
    final double contentScale = lerpDouble(0.95, 1.0, Curves.easeOutCubic.transform(contentT))!;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBackdrop = (isDark ? Colors.black : const Color(0xFF051F20)).withValues(alpha: 0.60);

    return Stack(
      alignment: contentAlignment,
      children: [
        // Animated Backdrop
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isDismissible ? () => Navigator.of(context).pop() : null,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: (10.0 * backdropOpacity).clamp(0.001, 10.0),
                sigmaY: (10.0 * backdropOpacity).clamp(0.001, 10.0),
              ),
              child: Opacity(
                opacity: backdropOpacity,
                child: Container(
                  color: backdropColor ?? defaultBackdrop,
                ),
              ),
            ),
          ),
        ),

        // Animated Content (Scale 0.95 -> 1 + Opacity 0 -> 1)
        Transform.scale(
          scale: contentScale,
          alignment: contentAlignment == Alignment.bottomCenter
              ? Alignment.bottomCenter
              : Alignment.center,
          child: Opacity(
            opacity: contentOpacity,
            child: Material(
              type: MaterialType.transparency,
              child: builder(context),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom PageRoute with the exact Entrance and Exit animation specs
class SmoothEntrancePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  SmoothEntrancePageRoute({
    required this.child,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final double t = animation.value;

            // Staggered backdrop and content
            final double backdropT = (t / (200 / 380)).clamp(0.0, 1.0);
            final double backdropOpacity = Curves.easeOut.transform(backdropT);

            const double contentStart = 80 / 380;
            final double contentT = ((t - contentStart) / (1.0 - contentStart)).clamp(0.0, 1.0);
            final double contentOpacity = Curves.easeOut.transform(contentT);
            final double contentScale = lerpDouble(0.95, 1.0, Curves.easeOutCubic.transform(contentT))!;

            return Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: backdropOpacity,
                    child: Container(color: Colors.black.withValues(alpha: 0.4)),
                  ),
                ),
                Transform.scale(
                  scale: contentScale,
                  child: Opacity(
                    opacity: contentOpacity,
                    child: child,
                  ),
                ),
              ],
            );
          },
        );
}
