import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory_tsth2/Model/user_model.dart';
import 'package:path/path.dart' as path;

class UserService {
  final Dio _dio;
  final SharedPreferences _prefs;

  UserService({Dio? dio, SharedPreferences? prefs})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'http://127.0.0.1:8000/api',
              headers: {'Accept': 'application/json'},
            )),
        _prefs = prefs ?? (throw Exception('SharedPreferences not initialized'));

  String get baseUrl => _dio.options.baseUrl.replaceFirst('/api', '');

  Future<String?> _getToken() async {
    return _prefs.getString('auth_token');
  }

  Future<User> getCurrentUser() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/auth/user', // Matches api/auth/user
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
        '/users/$userId', // Matches api/users/{user}
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['message'] == 'Profil berhasil diperbarui') {
        return User.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to update user');
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
        '/users/change-password', // Matches api/users/change-password
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword, // Backend expects confirmation
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode != 200 || response.data['message'] != 'Password berhasil diperbarui') {
        throw Exception(response.data['error'] ?? 'Failed to change password');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    final token = await _getToken();
    if (token == null) return;

    try {
      await _dio.post(
        '/auth/logout', // Matches api/auth/logout
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } finally {
      await _prefs.remove('auth_token');
      await _prefs.remove('user');
    }
  }

  String _handleError(DioException e) {
    if (e.response?.data != null) {
      if (e.response?.data['error'] != null) {
        return e.response!.data['error'];
      }
      if (e.response?.data['message'] != null) {
        return e.response!.data['message'];
      }
    }
    return e.message ?? 'An error occurred';
  }
}