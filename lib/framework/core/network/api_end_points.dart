class ApiEndPoints {
  ApiEndPoints._();

  static String fetchNearbyDustbins({
    required double latitude,
    required double longitude,
    double radiusInMeters = 500,
    int pageNumber = 1,
    int pageSize = 50,
  }) =>
      "/dustbin/nearby?latitude=$latitude&longitude=$longitude&radius_in_m=$radiusInMeters&page_number=$pageNumber&page_size=$pageSize";

  static const String addDustbin = "/dustbin/"; 
}
