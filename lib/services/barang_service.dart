import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventory_tsth2/Model/barang_gudang_model.dart'; // Pastikan model ini ada
import 'package:inventory_tsth2/Model/barang_model.dart';
import 'package:inventory_tsth2/Model/gudang_model.dart';
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

  Future<List<BarangGudang>> getAllBarangWithGudangs() async {
    final token = await _getToken();
    try {
      final response = await _dio.get(
        '/barangs',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final List<dynamic> data = response.data['data'];
      print('API Response for getAllBarangWithGudangs: $data'); // Debug log
      return data.map((item) {
        // Ambil gudang pertama dari array gudangs (atau sesuaikan logika jika ada multiple gudangs)
        final gudang = (item['gudangs'] as List?)?.firstWhere(
          (g) => g != null,
          orElse: () => null,
        );
        return BarangGudang(
          barangId: item['id'] ?? 0,
          gudangId: gudang?['id'] ?? 0,
          stokTersedia: gudang?['stok_tersedia'] ?? 0,
          stokDipinjam: gudang?['stok_dipinjam'] ?? 0,
          stokMaintenance: gudang?['stok_maintenance'] ?? 0,
          gudang: gudang != null ? Gudang.fromJson(gudang) : null,
        );
      }).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<BarangGudang> getBarangByIdWithGudangs(int id) async {
    final token = await _getToken();
    try {
      final response = await _dio.get(
        '/barangs/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final item = response.data['data'];
      final gudang = (item['gudangs'] as List?)?.firstWhere(
        (g) => g != null,
        orElse: () => null,
      );
      return BarangGudang(
        barangId: item['id'] ?? 0,
        gudangId: gudang?['id'] ?? 0,
        stokTersedia: gudang?['stok_tersedia'] ?? 0,
        stokDipinjam: gudang?['stok_dipinjam'] ?? 0,
        stokMaintenance: gudang?['stok_maintenance'] ?? 0,
        gudang: gudang != null ? Gudang.fromJson(gudang) : null,
      );
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