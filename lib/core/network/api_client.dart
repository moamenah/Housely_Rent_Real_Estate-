import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_dimensions.dart';
import '../error/exceptions.dart';

/// Thin wrapper around [Dio] — the single HTTP entry point of the app.
///
/// Responsibilities:
/// * own base options (timeouts, base url, headers)
/// * normalise transport errors into the app's exception types
/// * hand plain `Map` payloads to the data sources (no DTO logic here)
class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? Dio(_baseOptions) {
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }
  }

  final Dio _dio;

  static final BaseOptions _baseOptions = BaseOptions(
    // Replace with the real Housely API host when the backend ships.
    baseUrl: 'https://api.housely.app/v1',
    connectTimeout: AppDimensions.networkTimeout,
    receiveTimeout: AppDimensions.networkTimeout,
    sendTimeout: AppDimensions.networkTimeout,
    headers: const {'Content-Type': 'application/json'},
  );

  Dio get dio => _dio;

  /// GET [path] and return the decoded JSON body.
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return response.data ?? const <String, dynamic>{};
    } on DioException catch (error) {
      throw _map(error);
    }
  }

  /// GET [path] and return a decoded JSON list.
  Future<List<dynamic>> getJsonList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return response.data ?? const <dynamic>[];
    } on DioException catch (error) {
      throw _map(error);
    }
  }

  AppException _map(DioException error) => switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.connectionError =>
          const NetworkException(),
        DioExceptionType.badResponse =>
          ServerException.fromStatus(
            error.response?.statusCode ?? 500,
          ),
        // cancel, badCertificate, unknown and any future type
        _ => const ServerException(),
      };
}
