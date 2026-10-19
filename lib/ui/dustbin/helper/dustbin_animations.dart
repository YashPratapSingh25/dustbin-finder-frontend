import 'dart:async';

import 'package:flutter/material.dart';

/// Plays once: fades, slides and scales its child into place after [delay].
/// Respects the system "reduce motion" setting.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.offset = const Offset(0, 0.1),
    this.scaleFrom = 0.97,
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final double scaleFrom;
  final Curve curve;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _motion =
      CurvedAnimation(parent: _c, curve: widget.curve);
  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: const Interval(0, 0.6, curve: Curves.easeOut));
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position:
            Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(_motion),
        child: ScaleTransition(
          scale: Tween<double>(begin: widget.scaleFrom, end: 1).animate(_motion),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Springs down slightly while a finger is on it. Doesn't steal taps.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.scale = 0.96});

  final Widget child;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// A soft light sweep across placeholder blocks.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final highlight = Colors.white.withAlpha(dark ? 30 : 170);

    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = _c.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment(-2 + 4 * t, -0.3),
            end: Alignment(-1 + 4 * t, 0.3),
            colors: [Colors.transparent, highlight, Colors.transparent],
            stops: const [0, 0.5, 1],
          ).createShader(rect),
          child: child,
        );
      },
    );
  }
}

/// Gently bobs up and down forever.
class Floating extends StatefulWidget {
  const Floating({super.key, required this.child, this.distance = 6});

  final Widget child;
  final double distance;

  @override
  State<Floating> createState() => _FloatingState();
}

class _FloatingState extends State<Floating>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -widget.distance * Curves.easeInOut.transform(_c.value)),
        child: child,
      ),
    );
  }
}