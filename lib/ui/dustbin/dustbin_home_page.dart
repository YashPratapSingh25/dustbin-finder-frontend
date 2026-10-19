import 'package:dustbin_finder/framework/controller/dustbin_listing_controller.dart';
import 'package:dustbin_finder/ui/dustbin/add_dustbin_page.dart';
import 'package:dustbin_finder/ui/dustbin/helper/dustbin_animations.dart';
import 'package:dustbin_finder/ui/dustbin/helper/dustbin_bottom_sheet.dart';
import 'package:dustbin_finder/ui/dustbin/helper/dustbin_header.dart';
import 'package:dustbin_finder/ui/dustbin/helper/dustbin_map.dart';
import 'package:dustbin_finder/ui/dustbin/helper/selected_dustbin_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DustbinHomePage extends ConsumerStatefulWidget {
  const DustbinHomePage({super.key});

  @override
  ConsumerState<DustbinHomePage> createState() => _DustbinHomePageState();
}

class _DustbinHomePageState extends ConsumerState<DustbinHomePage> {
  /// The FAB shrinks to just its icon when the list sheet is pulled up.
  bool _fabExtended = true;

  void _openAddPage() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, __, ___) => const AddDustbinPage(),
        transitionsBuilder: (_, anim, __, child) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(dustbinListingControllerProvider);
    final topInset = MediaQuery.paddingOf(context).top;
    final selected = controller.selectedDustbin;

    return Scaffold(
      body: Stack(
        children: [
          // Map Background View
          const DustbinMap(),

          // Selected Pin Preview Floating Card: springs in / out on selection
          Positioned(
            top: MediaQuery.heightOf(context) * 0.3,
            left: 16,
            right: 16,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.12),
                    end: Offset.zero,
                  ).animate(anim),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.94, end: 1).animate(anim),
                    child: child,
                  ),
                ),
              ),
              child: selected != null
                  ? KeyedSubtree(
                      key: ValueKey('${selected.latitude}_${selected.longitude}'),
                      child: const SelectedDustbinCard(),
                    )
                  : const SizedBox.shrink(key: ValueKey('no-selection')),
            ),
          ),

          // Floating App Header
          const DustbinHeaderBar(),

          /// Resets the map to user (slides in from the right)
          Positioned(
            top: topInset + 98,
            right: 16,
            child: FadeSlideIn(
              delay: const Duration(milliseconds: 500),
              offset: const Offset(0.8, 0),
              scaleFrom: 0.7,
              curve: Curves.easeOutBack,
              child: _RecenterButton(
                onPressed: () {
                  final pos = controller.position;
                  if (pos != null) {
                    controller.moveMap(pos.latitude, pos.longitude);
                  }
                },
              ),
            ),
          ),

          // Expandable Draggable Sheet Listing
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (n) {
              final extended = n.extent <= 0.6;
              if (extended != _fabExtended) {
                setState(() => _fabExtended = extended);
              }
              return false;
            },
            child: const DustbinBottomSheet(),
          ),
        ],
      ),
      floatingActionButton: FadeSlideIn(
        delay: const Duration(milliseconds: 900),
        offset: Offset.zero,
        scaleFrom: 0.3,
        curve: Curves.elasticOut,
        duration: const Duration(milliseconds: 900),
        child: _AddDustbinFab(
          extended: _fabExtended,
          onPressed: _openAddPage,
        ),
      ),
    );
  }
}

/// Map re-center button. The target icon does a full turn on every tap.
class _RecenterButton extends StatefulWidget {
  const _RecenterButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_RecenterButton> createState() => _RecenterButtonState();
}

class _RecenterButtonState extends State<_RecenterButton> {
  double _turns = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Pressable(
      scale: 0.9,
      child: Material(
        color: scheme.surface,
        shape: const CircleBorder(),
        elevation: 6,
        shadowColor: Colors.black45,
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          tooltip: 'Re-center map',
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() => _turns += 1);
            widget.onPressed();
          },
          icon: AnimatedRotation(
            turns: _turns,
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutBack,
            child: Icon(
              Icons.my_location_rounded,
              color: scheme.primary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

/// Extended FAB that smoothly collapses to an icon and expands back.
class _AddDustbinFab extends StatelessWidget {
  const _AddDustbinFab({required this.extended, required this.onPressed});

  final bool extended;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Pressable(
      scale: 0.94,
      child: Material(
        color: scheme.primary,
        elevation: 6,
        shadowColor: scheme.primary.withAlpha(140),
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_location_alt_rounded, color: scheme.onPrimary),
                  if (extended) ...[
                    const SizedBox(width: 10),
                    Text(
                      'Add dustbin',
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}