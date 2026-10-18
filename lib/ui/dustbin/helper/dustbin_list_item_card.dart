import 'package:dustbin_finder/framework/controller/dustbin_controller.dart';
import 'package:dustbin_finder/framework/repository/dustbin/model/dustbin_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DustbinListItemCard extends ConsumerWidget {
  const DustbinListItemCard({
    super.key,
    required this.dustbin,
  });

  final Dustbin dustbin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Image
          if (dustbin.photoUrls.isNotEmpty)
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.network(
                dustbin.photoUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _photoPlaceholder()
              ),
            )
          else
            SizedBox(
              height: 100,
              child: _photoPlaceholder()
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Name
                          Text(
                            dustbin.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          /// Address
                          Text(
                            dustbin.address,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey.shade700,
                                ),
                          ),
                        ],
                      ),
                    ),
                    /// Open Map View
                    IconButton.filledTonal(
                      tooltip: 'Navigate',
                      onPressed: () => ref
                          .read(dustbinControllerProvider)
                          .openNavigation(
                              context, dustbin.latitude, dustbin.longitude),
                      icon: const Icon(Icons.directions),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    /// Fill Level
                    _infoChip(
                      icon: Icons.delete_outline,
                      label: dustbin.fillLevel,
                    ),
                    /// Distance in Meters
                    _infoChip(
                      icon: Icons.near_me_outlined,
                      label: '${dustbin.distanceInM.toStringAsFixed(0)} m away',
                    ),
                    /// Confidence Score
                    _infoChip(
                      icon: Icons.verified_outlined,
                      label: '${dustbin.confidenceScore}% confidence',
                    ),
                    /// Report Count
                    _infoChip(
                      icon: Icons.people_outline,
                      label: '${dustbin.reportCount} reports',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _infoChip({required IconData icon, required String label}) {
  return Chip(
    visualDensity: VisualDensity.compact,
    avatar: Icon(icon, size: 17),
    label: Text(label),
    padding: EdgeInsets.zero,
  );
}

Widget _photoPlaceholder() {
  return Container(
    color: Colors.grey.shade200,
    width: double.infinity,
    alignment: Alignment.center,
    child: Icon(
      Icons.delete_outline,
      size: 42,
      color: Colors.grey.shade500,
    ),
  );
}