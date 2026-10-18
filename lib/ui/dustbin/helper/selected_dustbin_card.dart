import 'package:dustbin_finder/framework/controller/dustbin_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedDustbinCard extends ConsumerWidget {
  const SelectedDustbinCard({
    super.key,
  });


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(dustbinControllerProvider);
    return Card(
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            if (controller.selectedDustbin!.photoUrls.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  controller.selectedDustbin!.photoUrls.first,
                  width: 76,
                  height: 76,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.delete, size: 40),
                ),
              )
            else
              const Icon(Icons.delete_outline, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.selectedDustbin!.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(controller.selectedDustbin!.address),
                  const SizedBox(height: 4),
                  Text(
                    '${controller.selectedDustbin!.fillLevel} · '
                    '${controller.selectedDustbin!.distanceInM.toStringAsFixed(0)} m away',
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Navigate',
              onPressed: () => controller.openNavigation(context, controller.selectedDustbin!.latitude, controller.selectedDustbin!.longitude),
              icon: const Icon(Icons.directions),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: () => controller.changeSelectedDustbinId(null),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}