import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({String baseUrl = 'http://localhost:5000/api'}) 
    : _dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token from secure storage here
          // final token = await secureStorage.read(key: 'jwt'); 
          // options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Global error handling, logging out on 401
          return handler.next(e);
        },
      ),
    );
  }

  Dio get client => _dio;
}

// Global provider for Riverpod
// final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
