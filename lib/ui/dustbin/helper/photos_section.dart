import 'package:dustbin_finder/framework/controller/add_dustbin_controller.dart';
import 'package:dustbin_finder/ui/dustbin/helper/add_photo_tile.dart';
import 'package:dustbin_finder/ui/dustbin/helper/dustbin_animations.dart';
import 'package:dustbin_finder/ui/dustbin/helper/empty_photo_zone.dart';
import 'package:dustbin_finder/ui/dustbin/helper/photo_tile.dart';
import 'package:dustbin_finder/ui/dustbin/helper/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class PhotosSection extends StatelessWidget {
  const PhotosSection({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onPickSource,
  });

  final AddDustbinController controller;
  final bool isLoading;
  final VoidCallback onPickSource;

  @override
  Widget build(BuildContext context) {
    const int maxPhotos = 5;

    final scheme = Theme.of(context).colorScheme;
    final images = controller.images;
    final canAdd = images.length < maxPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Photos',
          subtitle: 'Clear photos help people spot the right bin.',
          trailing: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: images.isEmpty
                  ? scheme.surfaceContainerHighest.withAlpha(150)
                  : scheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => ScaleTransition(
                scale: anim,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Text(
                '${images.length}/$maxPhotos',
                key: ValueKey(images.length),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: images.isEmpty
                      ? scheme.onSurfaceVariant
                      : scheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, if (current != null) current],
            ),
            child: images.isEmpty
                ? EmptyPhotoZone(
                    key: const ValueKey('empty'),
                    enabled: !isLoading,
                    onCamera: () =>
                        controller.pickImage(context, ImageSource.camera),
                    onGallery: () =>
                        controller.pickImage(context, ImageSource.gallery),
                  )
                : SizedBox(
                    key: const ValueKey('strip'),
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (canAdd)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: AddPhotoTile(
                              enabled: !isLoading,
                              onTap: onPickSource,
                            ),
                          ),
                        for (var i = 0; i < images.length; i++)
                          Padding(
                            key: ValueKey(images[i].path),
                            padding: const EdgeInsets.only(right: 10),
                            child: FadeSlideIn(
                              offset: const Offset(0.25, 0),
                              scaleFrom: 0.8,
                              curve: Curves.easeOutBack,
                              child: PhotoTile(
                                file: images[i],
                                isCover: i == 0,
                                onRemove: isLoading
                                    ? null
                                    : () {
                                        HapticFeedback.selectionClick();
                                        controller.removeImage(i);
                                      },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ),

        /// Error slides open only when there is one
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topLeft,
          child: controller.imageError != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 16, color: scheme.error),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          controller.imageError!,
                          style: TextStyle(color: scheme.error, fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}