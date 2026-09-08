import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// SmoothNavigationTransition
/// Implements high-end organic tab & page transitions:
/// - Fade: opacity transition 200ms
/// - Slide: translateX(-100% → 0) 300ms
/// - Blur: filter: blur(0 → 10px → 0)
/// - Crossfade: Overlaps old and new content seamlessly in a Stack
class SmoothNavigationTransition extends StatefulWidget {
  final int currentIndex;
  final List<Widget> children;
  final Duration duration;
  final Duration fadeDuration;
  final double maxBlur;
  final bool directional;

  const SmoothNavigationTransition({
    super.key,
    required this.currentIndex,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
    this.fadeDuration = const Duration(milliseconds: 200),
    this.maxBlur = 10.0,
    this.directional = false,
  });

  @override
  State<SmoothNavigationTransition> createState() => _SmoothNavigationTransitionState();
}

class _SmoothNavigationTransitionState extends State<SmoothNavigationTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _previousIndex = 0;
  Widget? _oldChild;
  bool _isTransitioning = false;
  bool _slideFromLeft = true;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _isTransitioning = false;
            _oldChild = null;
          });
        }
      });
  }

  @override
  void didUpdateWidget(covariant SmoothNavigationTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _oldChild = oldWidget.children[_previousIndex];

      if (widget.directional) {
        _slideFromLeft = widget.currentIndex < _previousIndex;
      } else {
        // Strict adherence to translateX(-100% -> 0)
        _slideFromLeft = true;
      }

      _isTransitioning = true;
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
    final activeChild = widget.children[widget.currentIndex];

    if (!_isTransitioning || _oldChild == null) {
      return activeChild;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final double t = _controller.value; // 0.0 -> 1.0 over 300ms

        // 1. Fade: 200ms opacity transition
        final double fadeRatio = (widget.fadeDuration.inMilliseconds / widget.duration.inMilliseconds).clamp(0.1, 1.0);
        final double incomingFadeT = (t / fadeRatio).clamp(0.0, 1.0);
        final double outgoingFadeT = ((1.0 - t) / fadeRatio).clamp(0.0, 1.0);

        final double incomingOpacity = Curves.easeInOut.transform(incomingFadeT);
        final double outgoingOpacity = Curves.easeInOut.transform(outgoingFadeT);

        // 2. Slide: translateX(-100% -> 0) 300ms
        final double slideT = Curves.easeOutCubic.transform(t);
        final double startX = _slideFromLeft ? -1.0 : 1.0;
        final double currentX = lerpDouble(startX, 0.0, slideT)!;

        // 3. Blur: filter: blur(0 -> 10px -> 0)
        // Parabolic sin wave peaking at t=0.5 (150ms) with maxBlur = 10px
        final double blurSigma = widget.maxBlur * math.sin(t * math.pi);

        // 4. Crossfade: Overlap old/new content in Stack
        return Stack(
          fit: StackFit.expand,
          children: [
            // Outgoing Content (fading out smoothly in place)
            Opacity(
              opacity: outgoingOpacity,
              child: _oldChild!,
            ),

            // Incoming Content (translating in with blur and fade)
            FractionalTranslation(
              translation: Offset(currentX, 0.0),
              child: Opacity(
                opacity: incomingOpacity,
                child: blurSigma > 0.2
                    ? ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                        child: activeChild,
                      )
                    : activeChild,
              ),
            ),
          ],
        );
      },
    );
  }
}
