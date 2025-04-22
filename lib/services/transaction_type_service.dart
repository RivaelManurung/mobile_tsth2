import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventory_tsth2/Model/transaction_type_model.dart';
import 'package:inventory_tsth2/config/api.dart';
import 'package:inventory_tsth2/services/auth_service.dart';

class TransactionTypeService {
  final Dio _dio;
  late final FlutterSecureStorage _storage;
  final AuthService _authService;

  TransactionTypeService({
    Dio? dio,
    FlutterSecureStorage? storage,
    AuthService? authService,
  })  : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              headers: {'Accept': 'application/json'},
            )),
        _authService = authService ?? AuthService() {
    _storage = storage ?? const FlutterSecureStorage();
  }

  Future<String?> _getToken() async {
    final token = await _authService.getToken();
    print('Token retrieved: $token');
    if (token == null) return null;

    final isValid = await _authService.verifyToken(token);
    print('Token valid: $isValid');
    if (!isValid) {
      await _authService.logout();
      return null;
    }
    return token;
  }

  Future<List<TransactionType>> getAllTransactionType() async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/transaction-types',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Cache-Control': 'no-cache',
          },
        ),
      );

      print('getAllTransactionType response: ${response.data}');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => TransactionType.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load transaction types');
      }
    } on DioException catch (e) {
      print('DioException in getAllTransactionType: ${e.response?.data}');
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

  Future<TransactionType> restoreTransactionType(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.put(
        '/transaction-types/$id/restore',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return TransactionType.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to restore transaction type');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> forceDeleteTransactionType(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.delete(
        '/transaction-types/$id/force',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to force delete transaction type');
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