import 'package:dustbin_finder/framework/core/network/api_result.dart';
import 'package:dustbin_finder/framework/repository/dustbin/model/request/add_dustbin_request_model.dart';
import 'package:dustbin_finder/framework/repository/dustbin/model/request/nearby_dustbins_request_model.dart';
import 'package:dustbin_finder/framework/repository/dustbin/model/response/add_dustbin_response_model.dart';
import 'package:dustbin_finder/framework/repository/dustbin/model/response/nearby_dustbin_response_model.dart';

abstract class DustbinRepository {
  Future <ApiResult<NearbyDustbinsResponseModel>> fetchNearbyDustbins(NearbyDustbinsRequestModel request);  
  Future <ApiResult<AddDustbinResponseModel>> addDustbin(AddDustbinRequestModel request);
}