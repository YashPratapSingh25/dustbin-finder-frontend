import 'package:dio/dio.dart';

class NetworkExceptions implements Exception {
  final String message;
  final int? statusCode;
  final Response? response;

  const NetworkExceptions(this.message, {this.statusCode, this.response});

  static NetworkExceptions getDioException(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return const NetworkExceptions('Connection timeout');
        case DioExceptionType.sendTimeout:
          return const NetworkExceptions('Send timeout');
        case DioExceptionType.receiveTimeout:
          return const NetworkExceptions('Receive timeout');
        case DioExceptionType.badCertificate:
          return const NetworkExceptions('Bad certificate');
        case DioExceptionType.cancel:
          return const NetworkExceptions('Request cancelled');
        case DioExceptionType.connectionError:
          return const NetworkExceptions('Connection error');
        case DioExceptionType.badResponse:
          final data = error.response?.data;
          String message = 'Server error';

          if (data is Map) {
            final detail = data['detail'] ?? data['message'] ?? data['error'];
            
            if (detail is String) {
              message = detail;
            } else if (detail is List) {
              message = detail.map((err) {
                if (err is Map) {
                  final field = err['loc'] is List ? (err['loc'] as List).last.toString() : '';
                  final msg = err['msg'] ?? '';
                  return field.isNotEmpty ? '$field: $msg' : msg.toString();
                }
                return err.toString();
              }).join(', ');
            }
          } else if (data is String && data.isNotEmpty) {
            message = data;
          } else {
            message = error.response?.statusMessage ?? 'Server error';
          }

          return NetworkExceptions(
            message,
            statusCode: error.response?.statusCode,
            response: error.response,
          );
        case DioExceptionType.unknown:
          return NetworkExceptions(error.message ?? 'Unexpected error');
        case DioExceptionType.transformTimeout:
          throw UnimplementedError();
      }
    }
    return NetworkExceptions(error is Map ? error["status"] : error.toString());
  }

  static String getErrorMessage(NetworkExceptions error) => error.message;
}