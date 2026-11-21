import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.baseUrl,
            connectTimeout: AppConstants.requestTimeout,
            receiveTimeout: AppConstants.requestTimeout,
            sendTimeout: AppConstants.requestTimeout,
            responseType: ResponseType.json,
            headers: {'Accept': 'application/json'},
          ),
        );

  final Dio _dio;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) return data;
      throw const ApiException('Unexpected response format.');
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        throw const ApiException('Request timed out. Please try again.');
      }
      if (error.type == DioExceptionType.connectionError) {
        throw const ApiException(
          'Unable to connect. Check your internet connection.',
        );
      }
      if (statusCode != null) {
        throw ApiException(
          'Server error ($statusCode). Please try again.',
          statusCode: statusCode,
        );
      }
      throw ApiException(error.message ?? 'Something went wrong.');
    } catch (error) {
      if (error is ApiException) rethrow;
      throw const ApiException('Something went wrong. Please try again.');
    }
  }
}
