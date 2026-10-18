import 'package:dustbin_finder/framework/controller/dustbin_controller.dart';
import 'package:dustbin_finder/ui/dustbin/helper/dustbin_list_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DustbinBottomSheet extends ConsumerWidget {
  const DustbinBottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(dustbinControllerProvider);
    final dustbins = controller.fetchDustbinsState.success?.result ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.43,
      minChildSize: 0.30,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const [0.43, 0.72, 0.92],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(26),
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 18,
                color: Colors.black12,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Dustbins near you',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                '${dustbins.length} found within your search area',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 14),
              if (controller.fetchDustbinsState.isLoading && dustbins.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (controller.fetchDustbinsState.errorMessage != null &&
                  dustbins.isEmpty)
                /// Error Message
                _StatusMessage(
                  message: controller.fetchDustbinsState.errorMessage!,
                  icon: Icons.location_off_outlined,
                  onRetry: () => controller.initialize(),
                ),
              if (!controller.fetchDustbinsState.isLoading &&
                  controller.fetchDustbinsState.errorMessage == null &&
                  dustbins.isEmpty)
                /// Empty State
                const _StatusMessage(
                  message: 'No dustbins found nearby. Add one to help others!',
                  icon: Icons.delete_outline,
                ),
              ...dustbins.map(
                (dustbin) => DustbinListItemCard(
                  dustbin: dustbin,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.message,
    required this.icon,
    this.onRetry,
  });

  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Icon(icon, size: 42, color: Colors.grey),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ],
      ),
    );
  }
}
