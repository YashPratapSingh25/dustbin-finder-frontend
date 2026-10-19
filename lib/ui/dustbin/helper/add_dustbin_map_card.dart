import 'package:dustbin_finder/framework/controller/add_dustbin_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class AddDustbinMapCard extends StatelessWidget {
  final AddDustbinController controller;
  const AddDustbinMapCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final latLng = controller.selectedLatLng;

    return Container(
      height: 290,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: scheme.outlineVariant.withAlpha(110)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: controller.addDustbinMapController,
            options: MapOptions(
              initialCenter: controller.selectedLatLng,
              initialZoom: 18,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  controller.updateSelectedLatLng(
                    position.center.latitude,
                    position.center.longitude,
                  );
                  controller.onMapDrag();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.dustbin_finder',
              ),
            ],
          ),

          /// Pin: lifts off the ground while dragging, lands when you stop
          IgnorePointer(
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: controller.dragging ? 1.0 : 0.0),
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                builder: (context, v, _) => Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Transform.scale(
                      scale: (1 - 0.35 * v).clamp(0.4, 1.2),
                      child: Container(
                        width: 18,
                        height: 7,
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(
                            (80 - 35 * v).clamp(20, 80).round(),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, -18 - 16 * v),
                      child: const Icon(
                        Icons.location_pin,
                        size: 44,
                        color: Color(0xFFE5484D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Hint that fades away after the first drag
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: controller.hasMoved ? 0 : 1,
                duration: const Duration(milliseconds: 350),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(140),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pan_tool_alt_rounded,
                            size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Drag the map to move the pin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// Live coordinates
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surface.withAlpha(235),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.my_location_rounded,
                          size: 14, color: scheme.primary),
                      const SizedBox(width: 7),
                      Text(
                        '${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
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
