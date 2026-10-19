class Dustbin {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final List<String> photosKeys;
  final List<String> photoUrls;
  final int confidenceScore;
  final int reportCount;
  final DateTime? lastVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double distanceInM;

  const Dustbin({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.photosKeys,
    required this.photoUrls,
    required this.confidenceScore,
    required this.reportCount,
    this.lastVerifiedAt,
    this.createdAt,
    this.updatedAt,
    required this.distanceInM,
  });

  factory Dustbin.fromJson(Map<String, dynamic> json) {
    return Dustbin(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String? ?? '',
      photosKeys: List<String>.from(
        json['photos_keys'] as List<dynamic>? ?? [],
      ),
      photoUrls: List<String>.from(
        json['photo_urls'] as List<dynamic>? ?? [],
      ),
      confidenceScore: (json['confidence_score'] as num?)?.toInt() ?? 0,
      reportCount: (json['report_count'] as num?)?.toInt() ?? 0,
      lastVerifiedAt: _parseDate(json['last_verified_at']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      distanceInM: (json['distance_in_m'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value as String);
  }
}