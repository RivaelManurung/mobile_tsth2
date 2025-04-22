// lib/services/gudang_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventory_tsth2/Model/gudang_model.dart';
import 'package:inventory_tsth2/Model/barang_gudang_model.dart';
import 'package:inventory_tsth2/config/api.dart';
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
              baseUrl: baseUrl,
              headers: {'Accept': 'application/json'},
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            )),
        _authService = authService ?? AuthService() {
    _storage = storage ?? const FlutterSecureStorage();
    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  Future<String?> _getToken() async {
    final token = await _authService.getToken();
    print('Token retrieved in GudangService: $token');
    return token;
  }

  Future<bool> _validateToken(String token) async {
    bool isValid = token.isNotEmpty;
    print('Token valid: $isValid');
    return isValid;
  }

  Future<List<Gudang>> getAllGudang({int retries = 3, Duration delay = const Duration(seconds: 2)}) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');
    if (!(await _validateToken(token))) throw Exception('Invalid token');

    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        print('Attempt $attempt of $retries: Fetching gudang from API...');
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
          List<dynamic> data = response.data['data'] ?? response.data;
          print('Parsing JSON for gudang list: $data');
          return data.map((json) => Gudang.fromJson(json)).toList();
        } else {
          throw Exception(response.data['message'] ?? 'Gagal memuat daftar gudang');
        }
      } on DioException catch (e) {
        print('DioException in getAllGudang (attempt $attempt): ${e.message}');
        print('Response data: ${e.response?.data}');
        print('Status code: ${e.response?.statusCode}');
        if (attempt == retries) {
          throw _handleError(e);
        }
        print('Retrying after $delay...');
        await Future.delayed(delay);
      } catch (e) {
        print('Unexpected error in getAllGudang (attempt $attempt): $e');
        if (attempt == retries) {
          rethrow;
        }
        print('Retrying after $delay...');
        await Future.delayed(delay);
      }
    }
    throw Exception('Gagal memuat daftar gudang setelah $retries percobaan');
  }

  Future<Gudang> createGudang(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');
    if (!(await _validateToken(token))) throw Exception('Invalid token');

    try {
      print('Creating gudang with data: $data');
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

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Gudang: Parsing JSON: ${response.data['data']}');
        return Gudang.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal membuat gudang');
      }
    } on DioException catch (e) {
      print('DioException in createGudang: ${e.message}');
      print('Response data: ${e.response?.data}');
      print('Status code: ${e.response?.statusCode}');
      throw _handleError(e);
    } catch (e) {
      print('Unexpected error in createGudang: $e');
      rethrow;
    }
  }

  Future<bool> updateGudang(int id, Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');
    if (!(await _validateToken(token))) throw Exception('Invalid token');

    try {
      print('Updating gudang with ID $id and data: $data');
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

      print('updateGudang response: ${response.data}');

      if (response.statusCode == 200) {
        print('Gudang updated successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memperbarui gudang');
      }
    } on DioException catch (e) {
      print('DioException in updateGudang: ${e.message}');
      print('Response data: ${e.response?.data}');
      print('Status code: ${e.response?.statusCode}');
      throw _handleError(e);
    } catch (e) {
      print('Unexpected error in updateGudang: $e');
      rethrow;
    }
  }

  Future<Gudang> getGudangById(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');
    if (!(await _validateToken(token))) throw Exception('Invalid token');

    try {
      print('Fetching gudang with ID $id');
      final response = await _dio.get(
        '/gudangs/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('getGudangById response: ${response.data}');

      if (response.statusCode == 200) {
        print('Gudang: Parsing JSON: ${response.data['data']}');
        return Gudang.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat detail gudang');
      }
    } on DioException catch (e) {
      print('DioException in getGudangById: ${e.message}');
      print('Response data: ${e.response?.data}');
      print('Status code: ${e.response?.statusCode}');
      throw _handleError(e);
    } catch (e) {
      print('Unexpected error in getGudangById: $e');
      rethrow;
    }
  }

  Future<bool> deleteGudang(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');
    if (!(await _validateToken(token))) throw Exception('Invalid token');

    try {
      print('Deleting gudang with ID $id');
      final response = await _dio.delete(
        '/gudangs/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('deleteGudang response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Gudang deleted successfully');
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal menghapus gudang');
      }
    } on DioException catch (e) {
      print('DioException in deleteGudang: ${e.message}');
      print('Response data: ${e.response?.data}');
      print('Status code: ${e.response?.statusCode}');
      throw _handleError(e);
    } catch (e) {
      print('Unexpected error in deleteGudang: $e');
      rethrow;
    }
  }

  Future<List<BarangGudang>> getStockByGudang(int gudangId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');
    if (!(await _validateToken(token))) throw Exception('Invalid token');

    try {
      print('Fetching stock for gudang ID $gudangId');
      final response = await _dio.get(
        '/gudangs',
        queryParameters: {'gudang_id': gudangId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('getStockByGudang response: ${response.data}');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => BarangGudang.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat data stok');
      }
    } on DioException catch (e) {
      print('DioException in getStockByGudang: ${e.message}');
      print('Response data: ${e.response?.data}');
      print('Status code: ${e.response?.statusCode}');
      throw _handleError(e);
    } catch (e) {
      print('Unexpected error in getStockByGudang: $e');
      rethrow;
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
    return e.message ?? 'Terjadi kesalahan jaringan. Pastikan server berjalan dan koneksi stabil.';
  }
}