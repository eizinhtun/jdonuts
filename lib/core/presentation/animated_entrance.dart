import 'dart:async';

import 'package:flutter/material.dart';

import '../motion/motion.dart';

/// A one-shot fade and rise used by the onboarding, welcome, and Home screens.
/// It settles immediately when the platform requests reduced motion.
class AnimatedEntrance extends StatefulWidget {
  const AnimatedEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = Motion.entrance,
    this.beginOffset = const Offset(0, Motion.entranceDistance),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset beginOffset;

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _delayTimer;
  bool _started = false;
  bool _settled = false;
  bool? _reduceMotion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (reduceMotion) {
      _delayTimer?.cancel();
      _controller.stop();
      _controller.value = 1;
      _settled = true;
      return;
    }
    if (!_started && !_settled) {
      _started = true;
      if (widget.delay == Duration.zero) {
        _controller.forward();
      } else {
        _delayTimer = Timer(widget.delay, () {
          if (mounted && !_settled) _controller.forward();
        });
      }
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) {
      final progress = Motion.curve.transform(_controller.value);
      return Opacity(
        opacity: progress,
        child: Transform.translate(
          offset: widget.beginOffset * (1 - progress),
          child: child,
        ),
      );
    },
  );
}
