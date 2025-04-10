import 'package:dio/dio.dart';
import 'package:inventory_tsth2/Model/barang_category_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BarangCategoryService {
  final Dio _dio;
  final SharedPreferences _prefs;

  BarangCategoryService({Dio? dio, SharedPreferences? prefs})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'http://127.0.0.1:8000/api',
              headers: {'Accept': 'application/json'},
            )),
        _prefs = prefs ?? (throw Exception('SharedPreferences not initialized'));

  Future<String?> _getToken() async {
    return _prefs.getString('auth_token');
  }

  Future<List<BarangCategory>> getAllBarangCategory() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/barang-categories',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'];
        return data.map((json) => BarangCategory.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load barang categories');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<BarangCategory> getBarangCategoryById(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/barang-categories/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return BarangCategory.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load barang category details');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<BarangCategory> createBarangCategory(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.post(
        '/barang-categories',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201) {
        return BarangCategory.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create barang category');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<BarangCategory> updateBarangCategory(int id, Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.put(
        '/barang-categories/$id',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return BarangCategory.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update barang category');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> deleteBarangCategory(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.delete(
        '/barang-categories/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete barang category');
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