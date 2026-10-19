import 'package:dustbin_finder/framework/controller/dustbin_listing_controller.dart';
import 'package:dustbin_finder/ui/dustbin/helper/dustbin_animations.dart';
import 'package:dustbin_finder/ui/dustbin/helper/dustbin_list_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DustbinBottomSheet extends ConsumerWidget {
  const DustbinBottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(dustbinListingControllerProvider);
    final state = controller.fetchDustbinsState;
    final dustbins = state.success?.result ?? [];
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final isLoading = state.isLoading;
    final hasError = state.errorMessage != null && dustbins.isEmpty;
    final isEmpty = !isLoading && state.errorMessage == null && dustbins.isEmpty;
    final subtitle = isLoading && dustbins.isEmpty
        ? 'Searching your area...'
        : 'Within your search area';

    return DraggableScrollableSheet(
      initialChildSize: 0.43,
      minChildSize: 0.30,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const [0.43, 0.72, 0.92],
      builder: (context, scrollController) {
        // The sheet glides up from the bottom once, when the screen opens.
        return FadeSlideIn(
          offset: const Offset(0, 0.25),
          scaleFrom: 1,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutQuart,
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 28,
                  color: Colors.black.withAlpha(34),
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
              children: [
                /// Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                /// Title row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dustbins near you',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 3),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            layoutBuilder: (current, previous) => Stack(
                              alignment: Alignment.centerLeft,
                              children: [...previous, if (current != null) current],
                            ),
                            child: Text(
                              subtitle,
                              key: ValueKey(subtitle),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// Count pill pops in, and the number counts up
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeOutBack,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(scale: anim, child: child),
                      ),
                      child: dustbins.isEmpty
                          ? const SizedBox.shrink(key: ValueKey('no-count'))
                          : Container(
                              key: const ValueKey('count'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${dustbins.length} found',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: scheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                /// Thin progress bar slides open while refreshing
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: (isLoading && dustbins.isNotEmpty)
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: const LinearProgressIndicator(minHeight: 4),
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),

                /// First load skeletons
                if (isLoading && dustbins.isEmpty) ...const [
                  _SkeletonCard(),
                  _SkeletonCard(),
                ],

                /// Error Message
                if (hasError)
                  _StatusMessage(
                    message: state.errorMessage!,
                    title: "Couldn't load dustbins",
                    icon: Icons.location_off_outlined,
                    onRetry: () => controller.initialize(),
                  ),

                /// Empty State
                if (isEmpty)
                  const _StatusMessage(
                    title: 'No dustbins nearby',
                    message: 'Be the first to add one and help others find it.',
                    icon: Icons.delete_outline_rounded,
                  ),

                for (var i = 0; i < dustbins.length; i++)
                  DustbinListItemCard(dustbin: dustbins[i]),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.title,
    required this.message,
    required this.icon,
    this.onRetry,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        child: Column(
          children: [
            /// Icon springs in, then keeps floating
            FadeSlideIn(
              offset: Offset.zero,
              scaleFrom: 0.4,
              curve: Curves.elasticOut,
              duration: const Duration(milliseconds: 900),
              child: Floating(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withAlpha(170),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 36, color: scheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              Pressable(
                child: FilledButton.tonalIcon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Placeholder that mirrors the real card layout, with a light sweep.
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final block = scheme.onSurface.withAlpha(16);

    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: block,
            borderRadius: BorderRadius.circular(8),
          ),
        );

    return Shimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: scheme.outlineVariant.withAlpha(110)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 150, color: block),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bar(180, 18),
                  const SizedBox(height: 10),
                  bar(260, 12),
                  const SizedBox(height: 22),
                  bar(double.infinity, 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}