import 'dart:math' as math;

import 'package:dustbin_finder/framework/controller/dustbin_listing_controller.dart';
import 'package:dustbin_finder/ui/dustbin/helper/dustbin_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DustbinHeaderBar extends ConsumerWidget {
  const DustbinHeaderBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(dustbinListingControllerProvider);
    final isLoading = controller.fetchDustbinsState.isLoading;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final subtitle = isLoading ? 'Looking around...' : 'Find nearby dustbins';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        // Drops in from the top when the screen opens.
        child: FadeSlideIn(
          offset: const Offset(0, -0.6),
          scaleFrom: 0.96,
          duration: const Duration(milliseconds: 750),
          curve: Curves.easeOutBack,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.surface.withAlpha(240),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: scheme.outlineVariant.withAlpha(90)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                /// Brand mark: the recycle icon spins once on arrival
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1400),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, child) =>
                        Transform.rotate(angle: v * 2 * math.pi, child: child),
                    child: Image.asset("assets/images/recycle-bin.png"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Dustbin Finder',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.4),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        layoutBuilder: (current, previous) => Stack(
                          alignment: Alignment.centerLeft,
                          children: [...previous, if (current != null) current],
                        ),
                        child: Text(
                          subtitle,
                          key: ValueKey(subtitle),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _SpinningRefresh(
                  spinning: isLoading,
                  onRefresh: () => controller.initialize(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Refresh button whose icon turns once on tap and keeps turning while loading.
class _SpinningRefresh extends StatefulWidget {
  const _SpinningRefresh({required this.spinning, required this.onRefresh});

  final bool spinning;
  final VoidCallback onRefresh;

  @override
  State<_SpinningRefresh> createState() => _SpinningRefreshState();
}

class _SpinningRefreshState extends State<_SpinningRefresh>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.spinning) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant _SpinningRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spinning && !oldWidget.spinning) {
      _c.repeat();
    } else if (!widget.spinning && oldWidget.spinning) {
      // Finish the current turn smoothly instead of snapping to a stop.
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      scale: 0.88,
      child: IconButton.filledTonal(
        tooltip: 'Refresh nearby dustbins',
        onPressed: () {
          if (widget.spinning) return;
          HapticFeedback.selectionClick();
          _c.forward(from: 0);
          widget.onRefresh();
        },
        icon: RotationTransition(
          turns: _c,
          child: const Icon(Icons.refresh_rounded),
        ),
      ),
    );
  }
}