class NearbyDustbinsRequestModel  {
  final double latitude;
  final double longitude;
  final double radiusInMeters;
  final int pageNumber;
  final int pageSize;

  const NearbyDustbinsRequestModel ({
    required this.latitude,
    required this.longitude,
    this.radiusInMeters = 1000,
    this.pageNumber = 1,
    this.pageSize = 15,
  });
}