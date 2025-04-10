import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory_tsth2/Model/gudang_model.dart';

class GudangService {
  final Dio _dio;
  final SharedPreferences _prefs;

  GudangService({Dio? dio, SharedPreferences? prefs})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'http://127.0.0.1:8000/api',
              headers: {'Accept': 'application/json'},
            )),
        _prefs = prefs ?? (throw Exception('SharedPreferences not initialized'));

  Future<String?> _getToken() async {
    return _prefs.getString('auth_token');
  }

  Future<List<Gudang>> getAllGudang() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/gudangs',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'];
        return data.map((json) => Gudang.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load gudang');
      }
    } on DioException catch (e) {
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
        throw Exception(response.data['message'] ?? 'Failed to load gudang details');
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

      if (response.statusCode == 201) {
        return Gudang.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create gudang');
      }
    } on DioException catch (e) {
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
        throw Exception(response.data['message'] ?? 'Failed to update gudang');
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
        throw Exception(response.data['message'] ?? 'Failed to delete gudang');
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