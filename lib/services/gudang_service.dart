// gudang_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventory_tsth2/Model/gudang_model.dart';
import 'package:inventory_tsth2/Model/barang_gudang_model.dart';
import 'package:inventory_tsth2/config/api.dart';
import 'package:inventory_tsth2/services/auth_service.dart';

class GudangService {
  final Dio _dio;
  final FlutterSecureStorage _storage;
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
        _storage = storage ?? const FlutterSecureStorage(),
        _authService = authService ?? AuthService() {
    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  Future<String?> _getToken() async {
    final token = await _authService.getToken();
    print('Token retrieved in GudangService: $token');
    return token;
  }

  Future<List<Gudang>> getAllGudang() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');
    try {
      print('Fetching gudang from API...');
      final response = await _dio.get(
        '/gudangs',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Cache-Control': 'no-cache',
          },
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? response.data;
        print('Parsing JSON for gudang list: $data');
        return data.map((json) => Gudang.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat daftar gudang');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Gudang> getGudangById(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');
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

      if (response.statusCode == 200) {
        print('Gudang: Parsing JSON: ${response.data['data']}');
        return Gudang.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat detail gudang');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response?.data != null) {
      if (e.response?.data['errors'] != null) {
        final errors = e.response!.data['errors'] as Map<String, dynamic>;
        return errors.entries
            .map((e) => '${e.key}: ${e.value.join(', ')}')
            .join('\n');
      }
      return e.response!.data['message'] ?? e.message ?? 'An error occurred';
    }
    return e.message ?? 'Terjadi kesalahan jaringan. Pastikan server berjalan dan koneksi stabil.';
  }
}