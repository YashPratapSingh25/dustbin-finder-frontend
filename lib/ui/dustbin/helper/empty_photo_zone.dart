import 'package:dustbin_finder/ui/dustbin/helper/dustbin_animations.dart';
import 'package:flutter/material.dart';

class EmptyPhotoZone extends StatelessWidget {
  const EmptyPhotoZone({
    super.key,
    required this.enabled,
    required this.onCamera,
    required this.onGallery,
  });

  final bool enabled;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: scheme.primary.withAlpha(60), width: 1.4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer.withAlpha(150),
            scheme.secondaryContainer.withAlpha(90),
          ],
        ),
      ),
      child: Column(
        children: [
          Floating(
            distance: 5,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: scheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withAlpha(50),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.add_photo_alternate_rounded,
                size: 30,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Show the bin clearly',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add photos so others can find the right one.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Pressable(
                  child: FilledButton.icon(
                    onPressed: enabled ? onCamera : null,
                    icon: const Icon(Icons.camera_alt_rounded, size: 18),
                    label: const Text('Camera'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Pressable(
                  child: FilledButton.tonalIcon(
                    onPressed: enabled ? onGallery : null,
                    icon: const Icon(Icons.photo_library_rounded, size: 18),
                    label: const Text('Gallery'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}