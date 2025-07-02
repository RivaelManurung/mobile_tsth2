import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventory_tsth2/Model/user_model.dart';
import 'package:inventory_tsth2/services/auth_service.dart';

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
              baseUrl: 'http://192.168.172.64:8000/api',
              headers: {'Accept': 'application/json'},
            )),
        _authService = authService ?? AuthService() {
    _storage = storage ?? const FlutterSecureStorage();
  }

  String get baseUrl => _dio.options.baseUrl;

  Future<String?> _getToken() async {
    final token = await _authService.getToken();
    print('Token retrieved in UserService: $token');
    return token;
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

  Future<List<User>> getAllUsers() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/auth/users',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Cache-Control': 'no-cache',
          },
        ),
      );

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

  Future<User> updateUser(int userId, User user) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      print('--- UserService updateUser Debug ---');
      print('User ID: $userId');
      print('Name: ${user.name}');
      print('Email: ${user.email}');
      print('Phone: ${user.phoneNumber}');
      print('Address: ${user.address}');
      print('-----------------------------------');

      Map<String, dynamic> requestData = {
        'name': user.name,
      };

      if (user.phoneNumber != null && user.phoneNumber!.trim().isNotEmpty) {
        requestData['phone_number'] = user.phoneNumber!.trim();
      }

      if (user.address != null && user.address!.trim().isNotEmpty) {
        requestData['address'] = user.address!.trim();
      }

      print('Request data: $requestData');

      final response = await _dio.put(
        '/users/$userId',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        final updatedUser = User.fromJson(response.data['data']);
        print('Updated user phone: ${updatedUser.phoneNumber}');
        return updatedUser;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update user');
      }
    } on DioException catch (e) {
      print('DioException in updateUser: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  Future<String> updateEmail(String newEmail) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.put(
        '/user/update-email',
        data: {'email': newEmail},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Update email response status: ${response.statusCode}');
      print('Update email response data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data['message'] ??
            'Link verifikasi telah dikirim ke email baru.';
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memperbarui email');
      }
    } on DioException catch (e) {
      print('DioException in updateEmail: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  Future<User> updateAvatar(String base64Image) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.put(
        '/user/avatar',
        data: {'avatar': 'data:image/png;base64,$base64Image'},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update avatar');
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      if (e.response != null) {
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      } else {
        print('No response received');
      }
      throw _handleError(e);
    }
  }

  Future<User> deleteAvatar() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.delete(
        '/user/avatar',
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

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      print('Sending change password request to: $baseUrl/users/change-password');
      print(
          'Request data: {current_password: $currentPassword, new_password: $newPassword}');
      final response = await _dio.post(
        '/users/change-password',
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
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to change password');
      }
    } on DioException catch (e) {
      print('DioException in changePassword: ${e.message}');
      if (e.response != null) {
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
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

  String getPhotoUrl(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return '';
    return '$baseUrl/storage/$photoUrl';
  }

  String _handleError(DioException e) {
    if (e.response?.statusCode == 401) {
      return 'No token found';
    }
    if (e.response?.statusCode == 422) {
      final errors = e.response?.data['errors'] as Map<String, dynamic>?;
      if (errors != null) {
        String errorMessage = '';
        errors.forEach((field, messages) {
          if (messages is List) {
            errorMessage += '${messages.join('\n')}\n';
          }
        });
        return errorMessage.trim().isNotEmpty
            ? errorMessage.trim()
            : 'Validasi gagal';
      }
    }
    return e.response?.data['message'] ?? e.message ?? 'An error occurred';
  }
}