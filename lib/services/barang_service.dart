import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventory_tsth2/Model/barang_model.dart';
import 'package:inventory_tsth2/services/auth_service.dart';

class BarangService {
  final Dio _dio;
  late final FlutterSecureStorage _storage;
  final AuthService _authService;

  BarangService({
    Dio? dio,
    FlutterSecureStorage? storage,
    AuthService? authService,
  })  : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'http://127.0.0.1:8000/api',
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

  Future<List<Barang>> getAllBarang() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/barangs',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Cache-Control': 'no-cache',
          },
        ),
      );

      print('getAllBarang response: ${response.data}');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => Barang.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load barang');
      }
    } on DioException catch (e) {
      print('DioException in getAllBarang: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  Future<Barang> getBarangById(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/barangs/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return Barang.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load barang details');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Barang> createBarang(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.post(
        '/barangs',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201) {
        return Barang.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create barang');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Barang> updateBarang(int id, Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.put(
        '/barangs/$id',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return Barang.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update barang');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> deleteBarang(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.delete(
        '/barangs/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete barang');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Barang> restoreBarang(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.put(
        '/barangs/$id/restore',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return Barang.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to restore barang');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> forceDeleteBarang(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.delete(
        '/barangs/$id/force',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to force delete barang');
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