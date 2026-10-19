import 'dart:async';
import 'package:dustbin_finder/framework/controller/add_dustbin_controller.dart';
import 'package:dustbin_finder/framework/controller/dustbin_listing_controller.dart';
import 'package:dustbin_finder/ui/dustbin/helper/add_dustbin_map_card.dart';
import 'package:dustbin_finder/ui/dustbin/helper/dustbin_animations.dart';
import 'package:dustbin_finder/ui/dustbin/helper/photos_section.dart';
import 'package:dustbin_finder/ui/dustbin/helper/section_title.dart';
import 'package:dustbin_finder/ui/dustbin/helper/source_options.dart';
import 'package:dustbin_finder/ui/dustbin/helper/submit_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class AddDustbinPage extends ConsumerStatefulWidget {
  const AddDustbinPage({super.key});

  @override
  ConsumerState<AddDustbinPage> createState() => _AddDustbinPageState();
}

class _AddDustbinPageState extends ConsumerState<AddDustbinPage> {

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final controller = ref.read(addDustbinControllerProvider);
      controller.resetAddDustbinPage();

      final position = ref.read(dustbinListingControllerProvider).position;
      if (position != null) {
        controller.updateSelectedLatLng(position.latitude, position.longitude);
        // Delay map movement slightly to ensure layout/controller attachment
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            controller.addDustbinMapController.move(
              LatLng(position.latitude, position.longitude),
              18,
            );
          }
        });
      }
    });
  }
  
  void _showImageSourceDialog(AddDustbinController controller) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SourceOption(
                icon: Icons.camera_alt_rounded,
                title: 'Take a photo',
                subtitle: 'Open the camera',
                onTap: () {
                  Navigator.pop(sheetContext);
                  controller.pickImage(context, ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
              SourceOption(
                icon: Icons.photo_library_rounded,
                title: 'Choose from gallery',
                subtitle: 'Pick existing photos',
                onTap: () {
                  Navigator.pop(sheetContext);
                  controller.pickImage(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(addDustbinControllerProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLoading = controller.addDustbinState.isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Pressable(
            scale: 0.9,
            child: IconButton.filledTonal(
              tooltip: 'Back',
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              /// Hero
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(
                      Icons.add_location_alt_rounded,
                      size: 28,
                      color: scheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add a dustbin',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'A photo, a name and a pin is all it takes.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              /// Photos
              PhotosSection(
                controller: controller,
                isLoading: isLoading,
                onPickSource: () => _showImageSourceDialog(controller),
              ),
              const SizedBox(height: 28),

              /// Details
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    title: 'Details',
                    subtitle: 'What should people look for?',
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: controller.nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: _fieldDecoration(
                      context,
                      label: 'Dustbin name',
                      icon: Icons.delete_outline_rounded,
                    ),
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a dustbin name.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: controller.addressController,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 2,
                    decoration: _fieldDecoration(
                      context,
                      label: 'Address',
                      icon: Icons.place_outlined,
                    ),
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter the dustbin address.'
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              /// Map
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: SectionTitle(
                          title: 'Pin the exact spot',
                          subtitle: 'Drag the map under the pin.',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Pressable(
                        child: FilledButton.tonalIcon(
                          onPressed: isLoading
                              ? null
                              : () {
                                  final position = ref
                                      .read(dustbinListingControllerProvider)
                                      .position;
                                  if (position != null) {
                                    HapticFeedback.selectionClick();
                                    controller.updateSelectedLatLng(
                                      position.latitude,
                                      position.longitude,
                                    );
                                    controller.addDustbinMapController.move(
                                      LatLng(
                                        position.latitude,
                                        position.longitude,
                                      ),
                                      18,
                                    );
                                  }
                                },
                          icon: const Icon(Icons.my_location_rounded, size: 18),
                          label: const Text('My location'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AddDustbinMapCard(controller: controller),
                ],
              ),
            ],
          ),
        ),
      ),

      /// Sticky submit bar with a live completion meter
      bottomNavigationBar: ListenableBuilder(
        listenable: Listenable.merge([
          controller.nameController,
          controller.addressController,
        ]),
        builder: (context, _) {
          final done = [
            controller.images.isNotEmpty,
            controller.nameController.text.trim().isNotEmpty,
            controller.addressController.text.trim().isNotEmpty,
          ].where((e) => e).length;

          return SubmitBar(
            done: done,
            total: 3,
            isLoading: isLoading,
            onPressed: () async {
              if (isLoading) return;
              HapticFeedback.mediumImpact();
              if (controller.validateForm(context)) {
                await controller.addDustbin(context, ref);
              }
            },
          );
        },
      ),
    );
  }

}

InputDecoration _fieldDecoration(
  BuildContext context, {
  required String label,
  required IconData icon,
}) {
  final scheme = Theme.of(context).colorScheme;

  OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: scheme.surfaceContainerHighest.withAlpha(110),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    border: border(Colors.transparent, 0),
    enabledBorder: border(Colors.transparent, 0),
    focusedBorder: border(scheme.primary, 1.8),
    errorBorder: border(scheme.error, 1.2),
    focusedErrorBorder: border(scheme.error, 1.8),
  );
}

Widget addPhotoTile(BuildContext context,
    {required bool enabled, required VoidCallback onTap}) {
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
            border: Border.all(color: scheme.primary.withAlpha(90), width: 1.4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined, size: 28, color: scheme.primary),
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
