import 'package:dio/dio.dart';
import 'package:localstorage/localstorage.dart';

class DioService {
  late Dio _dio;

  DioService() {
    _dio = Dio(BaseOptions(
      baseUrl:
          'https://admin.kenoride.ca/api/', // Update this with your actual base URL
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = localStorage.getItem('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options); // continue
      },
    ));
  }

  Dio get dio => _dio;

  Future<Response> getRequest(String endpoint,
      {Map<String, dynamic>? queryParams}) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParams);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> postRequest(String endpoint, {required Map<String, dynamic> data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } catch (e) {
      rethrow;
    }
  }
}
