import 'dart:io';

class AddDustbinRequestModel {
  final String? name;
  final String? fillLevel;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<File>? images;

  AddDustbinRequestModel(
      {required this.name,
      required this.fillLevel,
      required this.address,
      required this.latitude,
      required this.longitude,
      required this.images});
}
