import 'package:dio/dio.dart';
import 'package:inventory_tsth2/core/constant/api_constant.dart';
import 'package:inventory_tsth2/core/error/exceptions.dart';
import 'package:inventory_tsth2/features/authentication/data/datasources/local_dataSource.dart';
import 'package:inventory_tsth2/features/transaksi_type/data/models/transaction_type_model.dart';

abstract class TransactionTypeRemoteDataSource {
  Future<List<TransactionTypeModel>> getAllTransactionTypes();
  Future<TransactionTypeModel> getTransactionTypeById(int id);
  Future<TransactionTypeModel> createTransactionType(String name);
  Future<TransactionTypeModel> updateTransactionType(int id, String name);
  Future<void> deleteTransactionType(int id);
}

class TransactionTypeRemoteDataSourceImpl
    implements TransactionTypeRemoteDataSource {
  final Dio dio;
  final LocalDatasource authLocalDataSource;

  TransactionTypeRemoteDataSourceImpl(
      {required this.dio, required this.authLocalDataSource});

  Future<Options> _getOptionsWithToken() async {
    final token = await authLocalDataSource.getAuthToken();
    if (token == null)
      throw AuthException('Sesi berakhir, silakan login kembali.');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<List<TransactionTypeModel>> getAllTransactionTypes() async {
    try {
      final response = await dio.get('$baseUrl/transaction-types',
          options: await _getOptionsWithToken());
      List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => TransactionTypeModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(
          e.response?.data['message'] ?? 'Gagal memuat tipe transaksi.');
    }
  }

  @override
  Future<TransactionTypeModel> getTransactionTypeById(int id) async {
    try {
      final response = await dio.get('$baseUrl/transaction-types/$id',
          options: await _getOptionsWithToken());
      return TransactionTypeModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(
          e.response?.data['message'] ?? 'Gagal memuat detail.');
    }
  }

  @override
  Future<TransactionTypeModel> createTransactionType(String name) async {
    try {
      final response = await dio.post(
        '$baseUrl/transaction-types',
        data: {'name': name},
        options: await _getOptionsWithToken(),
      );
      return TransactionTypeModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(
          e.response?.data['message'] ?? 'Gagal membuat tipe transaksi.');
    }
  }

  @override
  Future<TransactionTypeModel> updateTransactionType(
      int id, String name) async {
    try {
      final response = await dio.put(
        '$baseUrl/transaction-types/$id',
        data: {'name': name},
        options: await _getOptionsWithToken(),
      );
      return TransactionTypeModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(
          e.response?.data['message'] ?? 'Gagal memperbarui tipe transaksi.');
    }
  }

  @override
  Future<void> deleteTransactionType(int id) async {
    try {
      await dio.delete('$baseUrl/transaction-types/$id',
          options: await _getOptionsWithToken());
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(
          e.response?.data['message'] ?? 'Gagal menghapus tipe transaksi.');
    }
  }
}
