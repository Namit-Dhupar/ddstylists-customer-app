import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiConfig {
  static const String serverBaseUrl = 'https://dnd-stylists-api.onrender.com';
  static const String baseUrl = '$serverBaseUrl/api';
  static const String tokenKey = 'jwt_token';
  
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  static Dio createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    // Add auth interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expired — clear and redirect to login
          _storage.delete(key: tokenKey);
        }
        handler.next(error);
      },
    ));

    return dio;
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: tokenKey);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: tokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: tokenKey);
    return token != null;
  }
}
