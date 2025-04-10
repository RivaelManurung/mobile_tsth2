import 'package:dio/dio.dart';
import 'package:inventory_tsth2/Model/jenis_barang_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JenisBarangService {
  final Dio _dio;
  final SharedPreferences _prefs;

  JenisBarangService({Dio? dio, SharedPreferences? prefs})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'http://127.0.0.1:8000/api',
              headers: {'Accept': 'application/json'},
            )),
        _prefs = prefs ?? (throw Exception('SharedPreferences not initialized'));

  Future<String?> _getToken() async {
    return _prefs.getString('auth_token');
  }

  Future<List<JenisBarang>> getAllJenisBarang() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/jenis-barangs',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'];
        return data.map((json) => JenisBarang.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load jenis barang');
      }
    } on DioException catch (e) {
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

      if (response.statusCode == 200) {
        return JenisBarang.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load jenis barang details');
      }
    } on DioException catch (e) {
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

      if (response.statusCode == 201) {
        return JenisBarang.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create jenis barang');
      }
    } on DioException catch (e) {
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

      if (response.statusCode == 200) {
        return JenisBarang.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update jenis barang');
      }
    } on DioException catch (e) {
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

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete jenis barang');
      }
    } on DioException catch (e) {
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

      if (response.statusCode == 200) {
        return JenisBarang.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to restore jenis barang');
      }
    } on DioException catch (e) {
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

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to force delete jenis barang');
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