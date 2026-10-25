import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/local_storage.dart';
import 'api_exceptions.dart';

class ApiClient {
  late final Dio dio;

  ApiClient({String? baseUrl}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: 2000),
        receiveTimeout: const Duration(milliseconds: 2000),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final instId = LocalStorage.getInstallationId();
          if (instId.isNotEmpty) {
            options.headers['x-installation-id'] = instId;
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          String message = 'A network error occurred. Please try again.';
          int? statusCode = error.response?.statusCode;

          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout) {
            message = 'Connection timed out. Checking local data...';
          } else if (error.type == DioExceptionType.connectionError) {
            message = 'Cannot connect to backend server. Running in offline-resilient mode.';
          } else if (error.response?.data is Map) {
            final data = error.response!.data as Map;
            if (data['message'] != null) {
              message = data['message'].toString();
            }
          }

          final customError = ApiException(
            message: message,
            statusCode: statusCode,
            details: error.response?.data,
          );

          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: customError,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: e.message ?? 'Unknown GET error');
    }
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: e.message ?? 'Unknown POST error');
    }
  }

  Future<dynamic> patch(String path, {dynamic data}) async {
    try {
      final response = await dio.patch(path, data: data);
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: e.message ?? 'Unknown PATCH error');
    }
  }

  Future<dynamic> delete(String path, {dynamic data}) async {
    try {
      final response = await dio.delete(path, data: data);
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(message: e.message ?? 'Unknown DELETE error');
    }
  }
}
