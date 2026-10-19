import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dustbin_finder/framework/controller/dustbin_listing_controller.dart';
import 'package:dustbin_finder/framework/repository/dustbin/model/dustbin_model.dart';
import 'package:dustbin_finder/ui/dustbin/helper/dustbin_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DustbinListItemCard extends ConsumerWidget {
  const DustbinListItemCard({
    super.key,
    required this.dustbin,
  });

  final Dustbin dustbin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasPhoto = dustbin.photoUrls.isNotEmpty;
    final confidence =
        (dustbin.confidenceScore / 100).clamp(0.0, 1.0).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: scheme.outlineVariant.withAlpha(110)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Photo area with overlaid badges
          SizedBox(
            height: hasPhoto ? 190 : 120,
            child: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _photoPlaceholder(scheme),
                  if (hasPhoto) ...[
                    CachedNetworkImage(
                      imageUrl: dustbin.photoUrls.first,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _photoPlaceholder(scheme),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x66000000),
                            Color(0x00000000),
                            Color(0x66000000),
                          ],
                          stops: [0, 0.45, 1],
                        ),
                      ),
                    ),
                  ],

                  /// Distance
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _GlassPill(
                      icon: Icons.near_me_rounded,
                      label: _formatDistance(dustbin.distanceInM),
                    ),
                  ),

                  /// Photo count
                  if (dustbin.photoUrls.length > 1)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: _GlassPill(
                        icon: Icons.photo_library_outlined,
                        label: '${dustbin.photoUrls.length}',
                      ),
                    ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Name
                Text(
                  dustbin.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),

                /// Address
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        dustbin.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                /// Confidence + reports
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _ConfidenceMeter(value: confidence)),
                    const SizedBox(width: 20),
                    _ReportsStat(count: dustbin.reportCount),
                  ],
                ),
                const SizedBox(height: 18),

                /// Navigate
                Pressable(
                  scale: 0.97,
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ref
                            .read(dustbinListingControllerProvider)
                            .openNavigation(
                              context,
                              dustbin.latitude,
                              dustbin.longitude,
                            );
                      },
                      icon: const Icon(Icons.directions_rounded),
                      label: const Text('Get directions'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDistance(num meters) {
  if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
  return '${meters.toStringAsFixed(0)} m';
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: Colors.black.withAlpha(105),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bar fills up and the percentage counts up when the card appears.
class _ConfidenceMeter extends StatelessWidget {
  const _ConfidenceMeter({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.verified_outlined, size: 15, color: scheme.primary),
            const SizedBox(width: 5),
            Text(
              'Confidence',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              '${(value * 100).round()}%',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 7,
            backgroundColor: scheme.primary.withAlpha(30),
            valueColor: AlwaysStoppedAnimation(scheme.primary),
          ),
        ),
      ],
    );
  }
}

class _ReportsStat extends StatelessWidget {
  const _ReportsStat({required this.count});

  final num count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withAlpha(150),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline_rounded,
              size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 7),
          Text(
            '$count',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            count == 1 ? 'report' : 'reports',
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _photoPlaceholder(ColorScheme scheme) {
  return Container(
    width: double.infinity,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          scheme.primaryContainer.withAlpha(170),
          scheme.secondaryContainer.withAlpha(120),
        ],
      ),
    ),
    child: Icon(
      Icons.delete_outline_rounded,
      size: 44,
      color: scheme.primary.withAlpha(150),
    ),
  );
}
