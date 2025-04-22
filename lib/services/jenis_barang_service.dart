import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventory_tsth2/Model/jenis_barang_model.dart';
import 'package:inventory_tsth2/config/api.dart';
import 'package:inventory_tsth2/services/auth_service.dart';

class JenisBarangService {
  final Dio _dio;
  late final FlutterSecureStorage _storage;
  final AuthService _authService;

  JenisBarangService({
    Dio? dio,
    FlutterSecureStorage? storage,
    AuthService? authService,
  })  : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              headers: {'Accept': 'application/json'},
            )),
        _authService = authService ?? AuthService() {
    _storage = storage ?? FlutterSecureStorage();
  }

  Future<String?> _getToken() async {
    final token = await _authService.getToken();
    // print('Token retrieved: $token'); // Debug log
    if (token == null) return null;

    // Verify the token before using it
    final isValid = await _authService.verifyToken(token);
    // print('Token valid: $isValid'); // Debug log
    if (!isValid) {
      await _authService.logout(); // Clear invalid token
      return null;
    }
    return token;
  }

  Future<List<JenisBarang>> getAllJenisBarang() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/jenis-barangs',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Cache-Control': 'no-cache', // Disable caching
          },
        ),
      );

      // print('getAllJenisBarang response: ${response.data}'); // Debug log

      if (response.statusCode == 200) {
        // Update to match the new API response structure
        List<dynamic> data = response.data['data'] ?? []; // Remove the extra ['data']
        // print('Parsed items: $data'); // Debug log
        return data.map((json) => JenisBarang.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load jenis barang');
      }
    } on DioException catch (e) {
      print('DioException in getAllJenisBarang: ${e.response?.data}'); // Debug log
      throw _handleError(e);
    }
  }

  Future<JenisBarang> getJenisBarangById(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/jenis-barangs/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('getJenisBarangById response: ${response.data}'); // Debug log

      if (response.statusCode == 200) {
        return JenisBarang.fromJson(response.data['data']);
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to load jenis barang details');
      }
    } on DioException catch (e) {
      print('DioException in getJenisBarangById: ${e.response?.data}'); // Debug log
      throw _handleError(e);
    }
  }

  Future<JenisBarang> createJenisBarang(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.post(
        '/jenis-barangs',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('createJenisBarang response: ${response.data}'); // Debug log

      if (response.statusCode == 201) {
        return JenisBarang.fromJson(response.data['data']);
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to create jenis barang');
      }
    } on DioException catch (e) {
      print('DioException in createJenisBarang: ${e.response?.data}'); // Debug log
      throw _handleError(e);
    }
  }

  Future<JenisBarang> updateJenisBarang(int id, Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.put(
        '/jenis-barangs/$id',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      // print('updateJenisBarang response: ${response.data}'); // Debug log

      if (response.statusCode == 200) {
        return JenisBarang.fromJson(response.data['data']);
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to update jenis barang');
      }
    } on DioException catch (e) {
      // print('DioException in updateJenisBarang: ${e.response?.data}'); // Debug log
      throw _handleError(e);
    }
  }

  Future<bool> deleteJenisBarang(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.delete(
        '/jenis-barangs/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('deleteJenisBarang response: ${response.data}'); // Debug log

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to delete jenis barang');
      }
    } on DioException catch (e) {
      print('DioException in deleteJenisBarang: ${e.response?.data}'); // Debug log
      throw _handleError(e);
    }
  }

  Future<JenisBarang> restoreJenisBarang(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.put(
        '/jenis-barangs/$id/restore',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('restoreJenisBarang response: ${response.data}'); // Debug log

      if (response.statusCode == 200) {
        return JenisBarang.fromJson(response.data['data']);
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to restore jenis barang');
      }
    } on DioException catch (e) {
      print('DioException in restoreJenisBarang: ${e.response?.data}'); // Debug log
      throw _handleError(e);
    }
  }

  Future<bool> forceDeleteJenisBarang(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.delete(
        '/jenis-barangs/$id/force',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('forceDeleteJenisBarang response: ${response.data}'); // Debug log

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to force delete jenis barang');
      }
    } on DioException catch (e) {
      print('DioException in forceDeleteJenisBarang: ${e.response?.data}'); // Debug log
      throw _handleError(e);
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