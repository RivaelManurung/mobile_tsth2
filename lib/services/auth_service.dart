import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8000/api',
    headers: {'Accept': 'application/json'},
  ));
  final _storage = const FlutterSecureStorage();

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) return false;
    
    try {
      final response = await _dio.get(
        '/auth/user',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      try {
        await _dio.post(
          '/auth/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      } catch (e) {
        // Ignore logout errors
      }
    }
    await _storage.delete(key: 'auth_token');
  }
}