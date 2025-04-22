import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventory_tsth2/Model/transaction_model.dart';
import 'package:inventory_tsth2/config/api.dart';
import 'package:inventory_tsth2/services/auth_service.dart';

class TransactionService {
  final Dio _dio;
  late final FlutterSecureStorage _storage;
  final AuthService _authService;

  TransactionService({
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
    if (token == null) return null;
    final isValid = await _authService.verifyToken(token);
    if (!isValid) {
      await _authService.logout();
      return null;
    }
    return token;
  }

  Future<Map<String, dynamic>> checkBarcode(String kode) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/transactions/check-barcode/$kode',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data is Map && response.data.containsKey('data')
            ? response.data['data']
            : response.data;

        if (responseData['barang_kode'] == null) {
          throw Exception('Invalid barcode response format');
        }

        return responseData;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to check barcode');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> storeTransaction(
    int transactionTypeId,
    List<Map<String, dynamic>> items,
  ) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.post(
        '/transactions',
        data: {
          'transaction_type_id': transactionTypeId,
          'items': items.map((item) => {
                'barang_kode': item['barang_kode'],
                'quantity': item['quantity'],
              }).toList(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to save transaction');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<List<Transaction>> getAllTransactions({
    int? transactionTypeId,
    String? transactionCode,
    String? dateStart,
    String? dateEnd,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/transactions',
        queryParameters: {
          if (transactionTypeId != null) 'transaction_type_id': transactionTypeId,
          if (transactionCode != null) 'transaction_code': transactionCode,
          if (dateStart != null) 'date_start': dateStart,
          if (dateEnd != null) 'date_end': dateEnd,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? [];
        return data.map<Transaction>((json) => Transaction.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load transactions');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Transaction> getTransactionById(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.get(
        '/transactions/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return Transaction.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load transaction');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Transaction> updateTransaction(int id, Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.put(
        '/transactions/$id',
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return Transaction.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update transaction');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<bool> deleteTransaction(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');

    try {
      final response = await _dio.delete(
        '/transactions/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete transaction');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  String _handleError(DioException e) {
    if (e.response?.data != null) {
      return e.response?.data['message'] ??
             e.response?.data['error'] ??
             e.message ?? 'An error occurred';
    }
    return e.message ?? 'An error occurred';
  }
}