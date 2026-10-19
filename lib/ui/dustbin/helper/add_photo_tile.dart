import 'package:dustbin_finder/ui/dustbin/helper/dustbin_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddPhotoTile extends StatelessWidget {
  const AddPhotoTile({super.key, required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Pressable(
      child: Material(
        color: scheme.primaryContainer.withAlpha(130),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  onTap();
                }
              : null,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: scheme.primary.withAlpha(90), width: 1.4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined,
                    size: 28, color: scheme.primary),
                const SizedBox(height: 6),
                Text(
                  'Add photo',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}