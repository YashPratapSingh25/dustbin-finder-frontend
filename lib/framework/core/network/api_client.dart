import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../config/environment.dart';

@lazySingleton
class ApiClient {
  ApiClient() : dio = Dio(BaseOptions(
    baseUrl: EnvironmentConfig.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 25),
    sendTimeout: const Duration(seconds: 25),
    headers: {'Accept': 'application/json'},
  )) {
    dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (object) {},
    ));
  }

  final Dio dio;
}
