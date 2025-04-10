import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory_tsth2/Model/transaction_type_model.dart';

class TransactionTypeService {
  final Dio _dio;
  final SharedPreferences _prefs;

  TransactionTypeService({Dio? dio, SharedPreferences? prefs})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'http://127.0.0.1:8000/api',
              headers: {'Accept': 'application/json'},
            )),
        _prefs = prefs ?? (throw Exception('SharedPreferences not initialized'));

  Future<String?> _getToken() async {
    return _prefs.getString('auth_token');
  }

  Future<List<TransactionType>> getAllTransactionType() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/transaction-types',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'];
        return data.map((json) => TransactionType.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load transaction types');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TransactionType> getTransactionTypeById(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/transaction-types/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return TransactionType.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load transaction type details');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TransactionType> createTransactionType(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.post(
        '/transaction-types',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201) {
        return TransactionType.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create transaction type');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TransactionType> updateTransactionType(int id, Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.put(
        '/transaction-types/$id',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return TransactionType.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update transaction type');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> deleteTransactionType(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.delete(
        '/transaction-types/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete transaction type');
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