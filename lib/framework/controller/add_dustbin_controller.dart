import 'dart:async';
import 'dart:io';
import 'package:dustbin_finder/framework/controller/dustbin_listing_controller.dart';
import 'package:dustbin_finder/framework/core/di/injection.dart';
import 'package:dustbin_finder/framework/core/network/network_exceptions.dart';
import 'package:dustbin_finder/framework/repository/dustbin/contract/dustbin_repository.dart';
import 'package:dustbin_finder/framework/repository/dustbin/model/request/add_dustbin_request_model.dart';
import 'package:dustbin_finder/framework/repository/dustbin/model/response/add_dustbin_response_model.dart';
import 'package:dustbin_finder/framework/utils/ui_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

final addDustbinControllerProvider =
    ChangeNotifierProvider<AddDustbinController>(
  (ref) => getIt<AddDustbinController>(),
);

@injectable
class AddDustbinController extends ChangeNotifier {
  AddDustbinController(this.dustbinRepository);
  final DustbinRepository dustbinRepository;

  final addDustbinState = UiState<AddDustbinResponseModel>();
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final addressController = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();
  final List<File> images = [];

  String? imageError;

  /// Map Variables
  Timer? dragTimer;
  bool dragging = false;
  bool hasMoved = false;

  /// Lifts the map pin while the user drags, drops it shortly after they stop.
  void onMapDrag() {
    dragTimer?.cancel();
    if (!dragging || !hasMoved) {
        dragging = true;
        hasMoved = true;

        notifyListeners();
    }
    dragTimer = Timer(const Duration(milliseconds: 280), () {
      dragging = false;
      notifyListeners();
    });
  }

  // Map controller and selected location
  final MapController addDustbinMapController = MapController();
  LatLng selectedLatLng = const LatLng(0, 0);

  void resetAddDustbinPage() {
    formKey.currentState?.reset();
    nameController.clear();
    addressController.clear();
    images.clear();
    imageError = null;
    addDustbinState.isLoading = false;
    addDustbinState.errorMessage = null;
    addDustbinState.success = null;
    notifyListeners();
  }

  void updateSelectedLatLng(double latitude, double longitude) {
    selectedLatLng = LatLng(latitude, longitude);
    notifyListeners();
  }

  Future<void> pickImage(BuildContext context, ImageSource source) async {
    if (images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can upload a maximum of 5 photos.')),
      );
      return;
    }

    try {
      if (source == ImageSource.camera) {
        final pickedFile = await imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        if (pickedFile != null) {
          images.add(File(pickedFile.path));
          imageError = null;
          notifyListeners();
        }
      } else {
        final remainingSlots = 5 - images.length;
        final pickedFiles = await imagePicker.pickMultiImage(
          imageQuality: 85,
        );
        if (pickedFiles.isNotEmpty) {
          final newFiles = pickedFiles
              .take(remainingSlots)
              .map((file) => File(file.path))
              .toList();
          images.addAll(newFiles);
          imageError = null;
          notifyListeners();
        }
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not select image: $error')),
      );
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < images.length) {
      images.removeAt(index);
      imageError = images.isEmpty ? 'At least one photo is required.' : null;
      notifyListeners();
    }
  }

  Future<void> addDustbin(BuildContext context, WidgetRef ref) async {
    addDustbinState
      ..isLoading = true
      ..errorMessage = null
      ..success = null;
    notifyListeners();

    try {
      final apiResult = await dustbinRepository.addDustbin(
          AddDustbinRequestModel(
              name: nameController.text.trim(),
              address: addressController.text.trim(),
              latitude: selectedLatLng.latitude,
              longitude: selectedLatLng.longitude,
              images: images));

      apiResult.when(
        success: (data) async {
          Navigator.of(context).pop(true);

          await ref
              .read(dustbinListingControllerProvider)
              .fetchNearbyDustbins();
        },
        failure: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Could not add dustbin: ${NetworkExceptions.getErrorMessage(error)}')),
          );
        },
      );
    } finally {
      addDustbinState.isLoading = false;
      notifyListeners();
    }
  }

  bool validateForm(
    BuildContext context,
  ) {
    FocusScope.of(context).unfocus();

    final isFormValid = formKey.currentState?.validate() ?? false;

    if (images.isEmpty) {
      imageError = 'Please select at least one dustbin photo.';
      notifyListeners();
    }

    if (!isFormValid || images.isEmpty || addDustbinState.isLoading)
      return false;

    return true;
  }
}
