  import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventory_tsth2/Model/satuan_model.dart';
import 'package:inventory_tsth2/config/api.dart';
import 'package:inventory_tsth2/services/auth_service.dart';

class SatuanService {
  final Dio _dio;
  late final FlutterSecureStorage _storage;
  final AuthService _authService;

  SatuanService({
    Dio? dio,
    FlutterSecureStorage? storage,
    AuthService? authService,
  })  : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              headers: {'Accept': 'application/json'},
            )),
        _authService = authService ?? AuthService() {
    _storage = storage ?? const FlutterSecureStorage();
  }

  Future<String?> _getToken() async {
    final token = await _authService.getToken();
    print('Token retrieved: $token'); // Debug log
    if (token == null) return null;

    // Verify the token before using it
    final isValid = await _authService.verifyToken(token);
    print('Token valid: $isValid'); // Debug log
    if (!isValid) {
      await _authService.logout(); // Clear invalid token
      return null;
    }
    return token;
  }

  Future<List<Satuan>> getAllSatuan() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/satuans',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Cache-Control': 'no-cache',
          },
        ),
      );

      print('getAllSatuan response: ${response.data}'); // Debug log

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => Satuan.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load units');
      }
    } on DioException catch (e) {
      print('DioException in getAllSatuan: ${e.response?.data}'); // Debug log
      throw _handleError(e);
    }
  }

  Future<Satuan> getSatuanById(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/satuans/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return Satuan.fromJson(response.data['data']);
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to load unit details');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Satuan> createSatuan(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.post(
        '/satuans',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201) {
        return Satuan.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create unit');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Satuan> updateSatuan(int id, Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.put(
        '/satuans/$id',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return Satuan.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update unit');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> deleteSatuan(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.delete(
        '/satuans/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete unit');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Satuan> restoreSatuan(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.put(
        '/satuans/$id/restore',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return Satuan.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to restore unit');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> forceDeleteSatuan(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.delete(
        '/satuans/$id/force',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to force delete unit');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        // Check for validation errors
        if (data['errors'] != null && data['errors'] is Map<String, dynamic>) {
          final errors = data['errors'] as Map<String, dynamic>;
          if (errors.containsKey('name') &&
              errors['name'] is List &&
              errors['name'].isNotEmpty) {
            return errors['name'][
                0]; // Return backend message, e.g., "Nama satuan sudah digunakan."
          }
        }
        // Fallback to generic message or error
        if (data['message'] != null) {
          return data['message'];
        }
        if (data['error'] != null) {
          return data['error'];
        }
      } 
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
