import 'package:dustbin_finder/framework/controller/dustbin_controller.dart';
import 'package:dustbin_finder/ui/dustbin/helper/dustbin_bottom_sheet.dart';
import 'package:dustbin_finder/ui/dustbin/helper/dustbin_header.dart';
import 'package:dustbin_finder/ui/dustbin/helper/dustbin_map.dart';
import 'package:dustbin_finder/ui/dustbin/helper/selected_dustbin_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DustbinHomePage extends ConsumerStatefulWidget {
  const DustbinHomePage({super.key});

  @override
  ConsumerState<DustbinHomePage> createState() => _DustbinHomePageState();
}

class _DustbinHomePageState extends ConsumerState<DustbinHomePage> {
  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(dustbinControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Map Background View
          const DustbinMap(),

          // Selected Pin Preview Floating Card
          if (controller.selectedDustbin != null)
            Positioned(
              top: MediaQuery.heightOf(context) * 0.3,
              left: 16,
              right: 16,
              child: const SelectedDustbinCard(),
            ),

          // Floating App Header
          const DustbinHeaderBar(),

          /// Resets the map to user
          Positioned(
              top: MediaQuery.heightOf(context) * 0.18,
              right: 16,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                shape: const CircleBorder(),
                elevation: 4,
                shadowColor: Colors.black38,
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  tooltip: 'Re-center map',
                  onPressed: () {
                    final pos = controller.position;
                    if (pos != null) {
                      controller.moveMap(pos.latitude, pos.longitude);
                    }
                  },
                  icon: Icon(
                    Icons.my_location,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
              )),

          // Expandable Draggable Sheet Listing
          const DustbinBottomSheet(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          
        },
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add dustbin'),
      ),
    );
  }
}
