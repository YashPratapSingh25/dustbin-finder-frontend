import 'package:cached_network_image/cached_network_image.dart';
import 'package:dustbin_finder/framework/controller/dustbin_listing_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedDustbinCard extends ConsumerWidget {
  const SelectedDustbinCard({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(dustbinListingControllerProvider);
    return Card(
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            if (controller.selectedDustbin?.photoUrls.isNotEmpty ?? false)
              ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: controller.selectedDustbin?.photoUrls.first ?? '',
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    imageBuilder: (context, imageProvider) {
                      return Image(
                        image: imageProvider,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        frameBuilder: (context, child, frame, sync) {
                          if (sync) return child;

                          return AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOut,
                            child: child,
                          );
                        },
                      );
                    },
                    placeholder: (context, url) => const SizedBox(
                      width: 76,
                      height: 76,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => const SizedBox(
                      width: 76,
                      height: 76,
                      child: Icon(Icons.delete, size: 40),
                    ),
                  ))
            else
              const Icon(Icons.delete_outline, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.selectedDustbin?.name ?? "",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(controller.selectedDustbin?.address ?? ""),
                  const SizedBox(height: 4),
                  Text(
                    '${controller.selectedDustbin?.distanceInM.toStringAsFixed(0) ?? ''} m away',
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Navigate',
              onPressed: () => controller.openNavigation(
                  context,
                  controller.selectedDustbin?.latitude ?? 0,
                  controller.selectedDustbin?.longitude ?? 0),
              icon: const Icon(Icons.directions),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: () => controller.changeSelectedDustbin(null),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
