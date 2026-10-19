import 'dart:io';

import 'package:dustbin_finder/ui/dustbin/helper/dustbin_animations.dart';
import 'package:flutter/material.dart';

class PhotoTile extends StatelessWidget {
  const PhotoTile({
    super.key, 
    required this.file,
    required this.isCover,
    required this.onRemove,
  });

  final File file;
  final bool isCover;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: ColoredBox(
              color: scheme.surfaceContainerHighest,
              child: Image.file(
                file,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, sync) => AnimatedOpacity(
                  opacity: (sync || frame != null) ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: child,
                ),
              ),
            ),
          ),
          if (isCover)
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(130),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Cover',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            top: 6,
            right: 6,
            child: Pressable(
              scale: 0.85,
              child: Tooltip(
                message: 'Remove photo',
                child: Material(
                  color: Colors.black.withAlpha(130),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onRemove,
                    child: const Padding(
                      padding: EdgeInsets.all(7),
                      child: Icon(Icons.close_rounded,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}