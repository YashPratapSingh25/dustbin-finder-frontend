import 'package:dustbin_finder/ui/dustbin/helper/dustbin_animations.dart';
import 'package:flutter/material.dart';

class SubmitBar extends StatelessWidget {
  const SubmitBar({
    super.key, 
    required this.done,
    required this.total,
    required this.isLoading,
    required this.onPressed,
  });

  final int done;
  final int total;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final complete = done == total;
    final left = total - done;
    final caption = complete
        ? 'All set, ready to add'
        : (left == 1 ? '1 detail left' : '$left details left');

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withAlpha(90)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(16),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
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
                    child: Row(
                      key: ValueKey(caption),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (complete) ...[
                          const Icon(Icons.check_circle_rounded,
                              size: 16, color: Color(0xFF1E9E63)),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          caption,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: complete
                                ? const Color(0xFF1E9E63)
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$done/$total',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(end: done / total),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: v,
                    minHeight: 6,
                    backgroundColor: scheme.primary.withAlpha(30),
                    valueColor: AlwaysStoppedAnimation(
                      Color.lerp(scheme.primary, const Color(0xFF1E9E63), v) ??
                          scheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Pressable(
                scale: 0.97,
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onPressed,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: isLoading
                          ? SizedBox(
                              key: const ValueKey('spinner'),
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: scheme.onPrimary,
                              ),
                            )
                          : const Icon(
                              Icons.add_location_alt_rounded,
                              key: ValueKey('icon'),
                            ),
                    ),
                    label: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        isLoading ? 'Adding Dustbin...' : 'Add Dustbin',
                        key: ValueKey(isLoading),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
