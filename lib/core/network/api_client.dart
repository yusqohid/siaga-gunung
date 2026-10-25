import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';

class ApiClient {
  final Dio dio;

  ApiClient({String? baseUrl})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? ApiConstants.defaultBaseUrl,
            connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeoutMs),
            receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
            headers: {
              'Accept': 'application/json',
            },
          ),
        ) {
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          error: true,
        ),
      );
    }
  }
}
