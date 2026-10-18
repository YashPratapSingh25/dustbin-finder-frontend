import 'dart:io';
import 'package:dustbin_finder/framework/core/di/injection.dart';
import 'package:dustbin_finder/framework/repository/dustbin/contract/dustbin_repository.dart';
import 'package:dustbin_finder/framework/repository/dustbin/model/dustbin_model.dart';
import 'package:dustbin_finder/framework/repository/dustbin/model/request/add_dustbin_request_model.dart';
import 'package:dustbin_finder/framework/repository/dustbin/model/request/nearby_dustbins_request_model.dart';
import 'package:dustbin_finder/framework/repository/dustbin/model/response/add_dustbin_response_model.dart';
import 'package:dustbin_finder/framework/repository/dustbin/model/response/nearby_dustbin_response_model.dart';
import 'package:dustbin_finder/framework/utils/ui_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

final dustbinControllerProvider = ChangeNotifierProvider<DustbinController>(
  (ref) => getIt<DustbinController>(),
);

@injectable
class DustbinController extends ChangeNotifier {
  DustbinController(this.dustbinRepository);
  final DustbinRepository dustbinRepository;

  Position? position;
  bool permissionDenied = false;

  final MapController mapController = MapController();
  bool mapInitialized = false;
  Dustbin? selectedDustbin;

  void syncMapWithData() {
    if (position == null || mapInitialized) return;
    mapInitialized = true;

    notifyListeners();
  }

  void changeSelectedDustbinId(Dustbin? dustbin) {
    selectedDustbin = dustbin;
    notifyListeners();
  }

  void moveMap(double latitude, double longitude, {Dustbin? dustbin}) {
    selectedDustbin = dustbin;
    mapController.move(LatLng(latitude, longitude), 16);

    notifyListeners();
  }

  Future<void> openNavigation(BuildContext context, double latitude, double longitude) async {
    final googleMapsUri = Uri.parse(
      'google.navigation:q=$latitude,$longitude&mode=w',
    );

    try {
      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(
          googleMapsUri,
          mode: LaunchMode.externalApplication,
        );
        return;
      }

      final webUri = Uri.https(
        'www.google.com',
        '/maps/dir/',
        {
          'api': '1',
          'destination': '$latitude,$longitude',
          'travelmode': 'walking',
        },
      );

      await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open a maps application.'),
        ),
      );
    }
  }


  final fetchDustbinsState = UiState<NearbyDustbinsResponseModel>();
  final addDustbinState = UiState<AddDustbinResponseModel>();

  Future<void> initialize() async {
    notifyListeners();
    try {
      /// Location Permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permissionDenied = true;
        fetchDustbinsState.errorMessage = permission ==
                LocationPermission.deniedForever
            ? 'Location permission is permanently denied. Enable it in Settings.'
            : 'Location permission is required to find nearby dustbins.';
        notifyListeners();
        return;
      }
      permissionDenied = false;

      /// Fetch Current Location
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        fetchDustbinsState.errorMessage =
            'Turn on location services to find nearby dustbins.';
        notifyListeners();
        return;
      }
      position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      syncMapWithData();

      /// Fetching Nearby Dustbins
      await fetchNearbyDustbins();
    } catch (error) {
      fetchDustbinsState.errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> fetchNearbyDustbins() async {
    if (position == null) return;

    fetchDustbinsState
      ..isLoading = true
      ..errorMessage = null
      ..success = null;

    notifyListeners();

    try {
      final nearbyResponse = await dustbinRepository.fetchNearbyDustbins(
          NearbyDustbinsRequestModel(
              latitude: position?.latitude ?? 0,
              longitude: position?.longitude ?? 0));

      nearbyResponse.when(
        success: (data) {
          fetchDustbinsState.success = data;
        },
        failure: (error) {
          fetchDustbinsState.errorMessage = error.message;
        },
      );
    } catch (error) {
      fetchDustbinsState.errorMessage = error.toString();
    } finally {
      fetchDustbinsState.isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDustbin(
      {required String name,
      required String fillLevel,
      required String address,
      required double latitude,
      required double longitude,
      required List<File>? images}) async {
    addDustbinState
      ..isLoading = true
      ..errorMessage = null
      ..success = null;
    notifyListeners();

    try {
      await dustbinRepository.addDustbin(AddDustbinRequestModel(
          name: name,
          fillLevel: fillLevel,
          address: address,
          latitude: latitude,
          longitude: longitude,
          images: images));
      await fetchNearbyDustbins();
    } finally {
      addDustbinState.isLoading = false;
      notifyListeners();
    }
  }
}
