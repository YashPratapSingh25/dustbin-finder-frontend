// To parse this JSON data, do
//
//     final addDustbinResponseModel = addDustbinResponseModelFromJson(jsonString);

import 'dart:convert';

AddDustbinResponseModel addDustbinResponseModelFromJson(String str) => AddDustbinResponseModel.fromJson(json.decode(str));

String addDustbinResponseModelToJson(AddDustbinResponseModel data) => json.encode(data.toJson());

class AddDustbinResponseModel {
    final String? message;
    final AddDustbinResult? result;

    AddDustbinResponseModel({
        this.message,
        this.result,
    });

    factory AddDustbinResponseModel.fromJson(Map<String, dynamic> json) => AddDustbinResponseModel(
        message: json["message"],
        result: json["result"] == null ? null : AddDustbinResult.fromJson(json["result"]),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "result": result?.toJson(),
    };
}

class AddDustbinResult {
    final String? name;
    final double? latitude;
    final double? longitude;
    final String? address;
    final String? id;
    final List<String>? photosKeys;
    final List<String>? photoUrls;
    final double? confidenceScore;
    final int? reportCount;
    final DateTime? lastVerifiedAt;
    final DateTime? createdAt;
    final DateTime? updatedAt;

    AddDustbinResult({
        this.name,
        this.latitude,
        this.longitude,
        this.address,
        this.id,
        this.photosKeys,
        this.photoUrls,
        this.confidenceScore,
        this.reportCount,
        this.lastVerifiedAt,
        this.createdAt,
        this.updatedAt,
    });

    factory AddDustbinResult.fromJson(Map<String, dynamic> json) => AddDustbinResult(
        name: json["name"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        address: json["address"],
        id: json["id"],
        photosKeys: json["photos_keys"] == null ? [] : List<String>.from(json["photos_keys"]!.map((x) => x)),
        photoUrls: json["photo_urls"] == null ? [] : List<String>.from(json["photo_urls"]!.map((x) => x)),
        confidenceScore: json["confidence_score"],
        reportCount: json["report_count"],
        lastVerifiedAt: json["last_verified_at"] == null ? null : DateTime.parse(json["last_verified_at"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "latitude": latitude,
        "longitude": longitude,
        "address": address,
        "id": id,
        "photos_keys": photosKeys == null ? [] : List<dynamic>.from(photosKeys!.map((x) => x)),
        "photo_urls": photoUrls == null ? [] : List<dynamic>.from(photoUrls!.map((x) => x)),
        "confidence_score": confidenceScore,
        "report_count": reportCount,
        "last_verified_at": lastVerifiedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
