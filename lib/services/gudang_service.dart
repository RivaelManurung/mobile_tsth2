import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventory_tsth2/Model/gudang_model.dart';
import 'package:inventory_tsth2/services/auth_service.dart';

class GudangService {
  final Dio _dio;
  late final FlutterSecureStorage _storage;
  final AuthService _authService;

  GudangService({
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

  Future<List<Gudang>> getAllGudang() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/gudangs',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Cache-Control': 'no-cache',
          },
        ),
      );

      print('getAllGudang response: ${response.data}');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => Gudang.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat daftar gudang');
      }
    } on DioException catch (e) {
      print('DioException in getAllGudang: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  Future<Gudang> getGudangById(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/gudangs/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return Gudang.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat detail gudang');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Gudang> createGudang(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.post(
        '/gudangs',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('createGudang response: ${response.data}');

      if (response.statusCode == 201) {
        return Gudang.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal membuat gudang');
      }
    } on DioException catch (e) {
      print('DioException in createGudang: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  Future<Gudang> updateGudang(int id, Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.put(
        '/gudangs/$id',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return Gudang.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memperbarui gudang');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> deleteGudang(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.delete(
        '/gudangs/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal menghapus gudang');
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
    return e.message ?? 'Terjadi kesalahan';
  }
}