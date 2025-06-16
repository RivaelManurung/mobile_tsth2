// lib/services/user_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventory_tsth2/Model/user_model.dart';
import 'package:inventory_tsth2/services/auth_service.dart';
import 'package:path/path.dart' as path;

class UserService {
  final Dio _dio;
  late final FlutterSecureStorage _storage;
  final AuthService _authService;

  UserService({
    Dio? dio,
    FlutterSecureStorage? storage,
    AuthService? authService,
  })  : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'http://172.26.42.227:8000/api',
              headers: {'Accept': 'application/json'},
            )),
        _authService = authService ?? AuthService() {
    _storage = storage ?? const FlutterSecureStorage();
  }

  String get baseUrl => _dio.options.baseUrl.replaceFirst('/api', '');

  Future<String?> _getToken() async {
    final token = await _authService.getToken();
    print('Token retrieved in UserService: $token'); // Debug log
    return token; // Langsung kembalikan token, tanpa verifikasi
  }

  Future<User> getCurrentUser() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/auth/user',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to fetch user');
      }
      return User.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Tambahkan metode untuk mengambil daftar semua pengguna
  Future<List<User>> getAllUsers() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/auth/users', // Sesuaikan dengan endpoint backend Anda untuk mengambil daftar pengguna
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Cache-Control': 'no-cache',
          },
        ),
      );

      print('getAllUsers response: ${response.data}');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception(
            response.data['message'] ?? 'Gagal memuat daftar pengguna');
      }
    } on DioException catch (e) {
      print('DioException in getAllUsers: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  Future<User> updateUser(int userId, User user, {File? image}) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      FormData formData = FormData.fromMap({
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'address': user.address,
        if (image != null)
          'photo': await MultipartFile.fromFile(
            image.path,
            filename: path.basename(image.path),
          ),
      });

      final response = await _dio.put(
        '/auth/users/$userId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update user');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.post(
        '/auth//users/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode != 200) {
        throw Exception(
            response.data['message'] ?? 'Failed to change password');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    final token = await _getToken();
    if (token == null) {
      await _authService.logout();
      return;
    }

    try {
      await _dio.post(
        '/auth/logout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } finally {
      await _authService.logout();
    }
  }

  String _handleError(DioException e) {
    if (e.response?.statusCode == 401) {
      return 'No token found';
    }
    if (e.response?.data != null) {
      if (e.response?.data['message'] != null) {
        return e.response!.data['message'];
      }
      if (e.response?.data['error'] != null) {
        return e.response!.data['error'];
      }
      // Tangani error validasi Laravel
      if (e.response?.data['errors'] != null) {
        final errors = e.response!.data['errors'] as Map<String, dynamic>;
        String errorMessage = '';
        for (var field in errors.keys) {
          if (errors[field] is List && errors[field].isNotEmpty) {
            errorMessage += '${errors[field][0]}\n';
          }
        }
        return errorMessage.trim();
      }
    }
    return e.message ?? 'An error occurred';
  }
  // Tambahkan di lib/services/user_service.dart, di dalam kelas UserService

// Method untuk menghapus avatar
  Future<User> deleteAvatar(int userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.delete(
        '/users/$userId/avatar',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete avatar');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

// Method untuk mendapatkan URL foto
  String getPhotoUrl(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return '';
    return '$baseUrl/storage/$photoUrl';
  }
}
