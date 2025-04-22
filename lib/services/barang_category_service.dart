import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventory_tsth2/Model/barang_category_model.dart';
import 'package:inventory_tsth2/config/api.dart';
import 'package:inventory_tsth2/services/auth_service.dart';

class BarangCategoryService {
  final Dio _dio;
  late final FlutterSecureStorage _storage;
  final AuthService _authService;

  BarangCategoryService({
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
    print('Token retrieved: $token');
    if (token == null) return null;

    final isValid = await _authService.verifyToken(token);
    print('Token valid: $isValid');
    if (!isValid) {
      await _authService.logout();
      return null;
    }
    return token;
  }

  Future<List<BarangCategory>> getAllBarangCategory() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/barang-categories',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Cache-Control': 'no-cache',
          },
        ),
      );

      print('getAllBarangCategory response: ${response.data}');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => BarangCategory.fromJson(json)).toList();
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to load barang categories');
      }
    } on DioException catch (e) {
      print('DioException in getAllBarangCategory: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  Future<BarangCategory> getBarangCategoryById(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/barang-categories/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return BarangCategory.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ??
            'Failed to load barang category details');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<BarangCategory> createBarangCategory(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.post(
        '/barang-categories',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201) {
        return BarangCategory.fromJson(response.data['data']);
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to create barang category');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<BarangCategory> updateBarangCategory(
      int id, Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.put(
        '/barang-categories/$id',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return BarangCategory.fromJson(response.data['data']);
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to update barang category');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> deleteBarangCategory(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.delete(
        '/barang-categories/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to delete barang category');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<BarangCategory> restoreBarangCategory(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.put(
        '/barang-categories/$id/restore',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return BarangCategory.fromJson(response.data['data']);
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to restore barang category');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> forceDeleteBarangCategory(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.delete(
        '/barang-categories/$id/force',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to force delete barang category');
      }
    } on DioException catch (e) {
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