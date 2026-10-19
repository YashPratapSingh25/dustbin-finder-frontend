import 'package:dio/dio.dart';
import 'package:dustbin_finder/framework/core/network/api_client.dart';
import 'package:dustbin_finder/framework/core/network/api_end_points.dart';
import 'package:dustbin_finder/framework/core/network/api_result.dart';
import 'package:dustbin_finder/framework/core/network/network_exceptions.dart';
import 'package:dustbin_finder/framework/repository/dustbin/contract/dustbin_repository.dart';
import 'package:dustbin_finder/framework/repository/dustbin/model/request/add_dustbin_request_model.dart';
import 'package:dustbin_finder/framework/repository/dustbin/model/request/nearby_dustbins_request_model.dart';
import 'package:dustbin_finder/framework/repository/dustbin/model/response/add_dustbin_response_model.dart';
import 'package:dustbin_finder/framework/repository/dustbin/model/response/nearby_dustbin_response_model.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: DustbinRepository)
class DustbinApiRepository implements DustbinRepository {
  final ApiClient apiClient;
  DustbinApiRepository(this.apiClient);

  @override
  Future<ApiResult<NearbyDustbinsResponseModel>> fetchNearbyDustbins(
      NearbyDustbinsRequestModel request) async {
    try {
      final response = await apiClient.dio.get(ApiEndPoints.fetchNearbyDustbins(
          latitude: request.latitude,
          longitude: request.longitude,
          pageNumber: request.pageNumber,
          pageSize: request.pageSize,
          radiusInMeters: request.radiusInMeters));

      final responseModel = NearbyDustbinsResponseModel.fromJson(response.data);

      return Success(responseModel);
    } catch (e) {
      return Failure(NetworkExceptions.getDioException(e));
    }
  }

  @override
  Future<ApiResult<AddDustbinResponseModel>> addDustbin(AddDustbinRequestModel request) async {
  try {
    final fields = <String, dynamic>{
      'name': request.name,
      'address': request.address,
      'latitude': request.latitude,
      'longitude': request.longitude,
    };

    if (request.images != null && request.images!.isNotEmpty) {
      final imageList = <MultipartFile>[];
      for (var image in request.images!) {
        imageList.add(
          await MultipartFile.fromFile(
            image.path,
            filename: image.uri.pathSegments.isNotEmpty
                ? image.uri.pathSegments.last
                : 'dustbin.jpg',
          ),
        );
      }
      fields['images'] = imageList;
    }

    final response = await apiClient.dio.post(
      ApiEndPoints.addDustbin,
      data: FormData.fromMap(fields),
    );

    final responseModel = AddDustbinResponseModel.fromJson(response.data);
    return Success(responseModel);
  } catch (e) {
    return Failure(NetworkExceptions.getDioException(e));
  }
}
}
