import 'package:dio/dio.dart';
import 'package:inventory_tsth2/core/constant/api_constant.dart'; // Make sure you have this file
import 'package:inventory_tsth2/core/error/exceptions.dart';
import 'package:inventory_tsth2/features/authentication/data/datasources/local_dataSource.dart';
import 'package:inventory_tsth2/features/barang/data/models/barang_model.dart';

abstract class BarangRemoteDataSource {
  Future<List<BarangModel>> getAllBarang();
  Future<BarangModel> getBarangById(int id);
}

class BarangRemoteDataSourceImpl implements BarangRemoteDataSource {
  final Dio dio;
  final LocalDatasource authLocalDataSource;

  BarangRemoteDataSourceImpl({required this.dio, required this.authLocalDataSource});

  Future<Options> _getOptionsWithToken() async {
    final token = await authLocalDataSource.getAuthToken();
    if (token == null) throw AuthException('Unauthenticated');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<List<BarangModel>> getAllBarang() async {
    try {
      final response = await dio.get(
        '$baseUrl/barangs', // Ensure baseUrl is defined in your constants
        options: await _getOptionsWithToken(),
      );
      return (response.data['data'] as List)
          .map((json) => BarangModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(e.response?.data['message'] ?? 'Failed to load data');
    }
  }

  @override
  Future<BarangModel> getBarangById(int id) async {
     try {
      final response = await dio.get(
        '$baseUrl/barangs/$id',
        options: await _getOptionsWithToken(),
      );
      return BarangModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(e.response?.data['message'] ?? 'Failed to load data for item ID $id');
    }
  }
}