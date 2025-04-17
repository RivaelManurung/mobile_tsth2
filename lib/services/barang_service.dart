import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventory_tsth2/Model/barang_model.dart';
import 'package:inventory_tsth2/services/auth_service.dart';

class BarangService {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  final AuthService _authService;

  BarangService({
    Dio? dio,
    FlutterSecureStorage? storage,
    AuthService? authService,
  })  : _dio = dio ?? Dio(BaseOptions(
          baseUrl: 'http://127.0.0.1:8000/api',
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

  Future<Barang> createBarang(Barang barang) async {
    final token = await _getToken();
    try {
      final formData = FormData.fromMap(barang.toJson());
      
      if (barang.barangGambar != null) {
        formData.files.add(MapEntry(
          'barang_gambar',
          await MultipartFile.fromFile(barang.barangGambar!),
        ));
      }

      final response = await _dio.post(
        '/barangs',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'multipart/form-data',
        ),
      );
      return Barang.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Barang> updateBarang(int id, Barang barang) async {
    final token = await _getToken();
    try {
      final formData = FormData.fromMap(barang.toJson());
      
      if (barang.barangGambar != null) {
        formData.files.add(MapEntry(
          'barang_gambar',
          await MultipartFile.fromFile(barang.barangGambar!),
        ));
      }

      final response = await _dio.post(
        '/barangs/$id',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'multipart/form-data',
        ),
      );
      return Barang.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> deleteBarang(int id) async {
    final token = await _getToken();
    try {
      await _dio.delete(
        '/barangs/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  

  String _handleError(DioException e) {
    if (e.response?.data != null) {
      if (e.response?.data['errors'] != null) {
        final errors = e.response!.data['errors'] as Map<String, dynamic>;
        return errors.entries.map((e) => '${e.key}: ${e.value.join(', ')}').join('\n');
      }
      return e.response!.data['message'] ?? e.message ?? 'An error occurred';
    }
    return e.message ?? 'An error occurred';
  }
}