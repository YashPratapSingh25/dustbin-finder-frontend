import 'package:dustbin_finder/framework/utils/paginated_metadata.dart';
import 'package:dustbin_finder/framework/repository/dustbin/model/dustbin_model.dart';


class NearbyDustbinsResponseModel {
  final List<Dustbin> result;
  final String message;
  final PaginationMetadata metadata;

  const NearbyDustbinsResponseModel({
    required this.result,
    required this.message,
    required this.metadata,
  });

  factory NearbyDustbinsResponseModel.fromJson(Map<String, dynamic> json) {
    return NearbyDustbinsResponseModel(
      result: (json['result'] as List<dynamic>? ?? [])
          .map((item) => Dustbin.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList(),
      message: json['message'] as String? ?? '',
      metadata: PaginationMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}