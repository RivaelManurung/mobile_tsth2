import 'package:dio/dio.dart';
import 'package:inventory_tsth2/Model/satuan_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SatuanService {
  final Dio _dio;
  final SharedPreferences _prefs;

  SatuanService({Dio? dio, SharedPreferences? prefs})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'http://127.0.0.1:8000/api',
              headers: {'Accept': 'application/json'},
            )),
        _prefs = prefs ?? (throw Exception('SharedPreferences not initialized'));

  Future<String?> _getToken() async {
    return _prefs.getString('auth_token');
  }

  Future<List<Satuan>> getAllSatuan() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/satuans',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data']['data']; // Adjust for pagination
        return data.map((json) => Satuan.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load satuan');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Satuan> getSatuanById(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/satuans/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return Satuan.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load satuan details');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Satuan> createSatuan(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.post(
        '/satuans',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201) {
        return Satuan.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create satuan');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Satuan> updateSatuan(int id, Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.put(
        '/satuans/$id',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return Satuan.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update satuan');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> deleteSatuan(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.delete(
        '/satuans/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete satuan');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Satuan> restoreSatuan(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.put(
        '/satuans/$id/restore',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return Satuan.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to restore satuan');
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