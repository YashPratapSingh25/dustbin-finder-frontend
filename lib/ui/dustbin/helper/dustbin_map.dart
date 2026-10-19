import 'package:dustbin_finder/framework/controller/dustbin_listing_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class DustbinMap extends ConsumerWidget {
  const DustbinMap({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(dustbinListingControllerProvider);
    final dustbins = controller.fetchDustbinsState.success?.result ?? [];

    final mapCenter = controller.position != null
        ? LatLng(controller.position!.latitude, controller.position!.longitude)
        : const LatLng(0, 0);

    return FlutterMap(
      mapController: controller.mapController,
      options: MapOptions(
        initialCenter: mapCenter,
        initialZoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.dustbin_finder',
        ),
        MarkerLayer(
          markers: [
            if (controller.position != null)
              Marker(
                point: LatLng(
                  controller.position!.latitude,
                  controller.position!.longitude,
                ),
                rotate: true,
                width: 48,
                height: 48,
                child: GestureDetector(
                  onTap: () => controller.moveMap(
                    controller.position!.latitude,
                    controller.position!.longitude,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ...dustbins.map(
              (dustbin) => Marker(
                point: LatLng(dustbin.latitude, dustbin.longitude),
                rotate: true,
                width: 50,
                height: 56,
                child: GestureDetector(
                  onTap: () => controller.moveMap(
                    dustbin.latitude,
                    dustbin.longitude,
                    dustbin: dustbin,
                  ),
                  child: Icon(
                    Icons.location_on,
                    size: 46,
                    color: controller.selectedDustbin == dustbin
                        ? Colors.orange
                        : Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
