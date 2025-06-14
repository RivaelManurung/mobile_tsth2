import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventory_tsth2/config/api.dart';

class AuthService {
  final Dio _dio;
  late final FlutterSecureStorage _storage;

  AuthService({
    Dio? dio,
    FlutterSecureStorage? storage,
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              headers: {'Accept': 'application/json'},
            )) {
    _storage = storage ?? FlutterSecureStorage();
  }

  // Login API call
  Future<Map<String, dynamic>> login(String name, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login', // Updated endpoint
        data: {
          'name': name, // Changed from 'email' to 'name'
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final token = response.data['data']['token'] as String?;
        final user = response.data['data']['user'] as Map<String, dynamic>?;

        if (token == null || user == null) {
          return {
            'success': false,
            'message': 'Token or user data not found in response',
          };
        }

        // Store token and user data securely
        await _storage.write(key: 'auth_token', value: token);
        await _storage.write(key: 'user', value: jsonEncode(user));

        return {
          'success': true,
          'message': response.data['message'],
          'token': token,
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Login failed',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ??
            'Error connecting to server: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unexpected error: $e',
      };
    }
  }

  // Verify token API call
  Future<bool> verifyToken(String token) async {
    try {
      final response = await _dio.get(
        '/auth/user', // Updated endpoint
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        // Update user data if returned
        if (response.data['data'] != null) {
          await _storage.write(
              key: 'user', value: jsonEncode(response.data['data']));
        }
        return true;
      } else {
        await _storage.delete(key: 'auth_token');
        await _storage.delete(key: 'user');
        return false;
      }
    } on DioException catch (e) {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user');
      return false;
    } catch (e) {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user');
      return false;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) return false;

    return await verifyToken(token);
  }

  // Logout API call
  Future<void> logout() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      try {
        await _dio.post(
          '/auth/logout', // Updated endpoint
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      } on DioException catch (e) {
        print('Logout error: ${e.response?.data['message'] ?? e.message}');
      }
    }
    // Clear stored data
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user');
  }

  // Get stored token
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Get stored user data
  Future<Map<String, dynamic>?> getUser() async {
    final userData = await _storage.read(key: 'user');
    if (userData != null) {
      try {
        return jsonDecode(userData) as Map<String, dynamic>;
      } catch (e) {
        print('Error deserializing user data: $e');
        return null;
      }
    }
    return null;
  }
}
