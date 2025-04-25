import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventory_tsth2/Model/barang_model.dart';
import 'package:inventory_tsth2/config/api.dart';
import 'package:inventory_tsth2/services/auth_service.dart';

class BarangService {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  final AuthService _authService;

  BarangService({
    Dio? dio,
    FlutterSecureStorage? storage,
    AuthService? authService,
  })  : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              headers: {'Accept': 'application/json'},
            )),
        _storage = storage ?? const FlutterSecureStorage(),
        _authService = authService ?? AuthService();

  Future<String?> _getToken() async {
    return await _authService.getToken();
  }

  Future<List<Barang>> getAllBarang() async {
    final token = await _getToken();
    try {
      final response = await _dio.get(
        '/barangs',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return (response.data['data'] as List)
          .map((json) => Barang.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Barang> getBarangById(int id) async {
    final token = await _getToken();
    try {
      final response = await _dio.get(
        '/barangs/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Barang.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getAllBarangWithGudangs() async {
    final token = await _getToken();
    try {
      final response = await _dio.get(
        '/barangs',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return (response.data['data'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getBarangByIdWithGudangs(int id) async {
    final token = await _getToken();
    try {
      final response = await _dio.get(
        '/barangs/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['data'] as Map<String, dynamic>;
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
    return e.message ?? 'An error occurred';
  }
}
