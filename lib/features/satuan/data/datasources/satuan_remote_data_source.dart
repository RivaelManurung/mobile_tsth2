import 'package:dio/dio.dart';
import 'package:inventory_tsth2/core/constant/api_constant.dart';
import 'package:inventory_tsth2/core/error/exceptions.dart';
import 'package:inventory_tsth2/features/authentication/data/datasources/local_dataSource.dart';
import 'package:inventory_tsth2/features/satuan/data/models/satuan_model.dart';

abstract class SatuanRemoteDataSource {
  Future<List<SatuanModel>> getAllSatuan();
  Future<SatuanModel> getSatuanById(int id);
  Future<SatuanModel> createSatuan(String name, String? description);
  Future<SatuanModel> updateSatuan(int id, String name, String? description);
  Future<void> deleteSatuan(int id);
}

class SatuanRemoteDataSourceImpl implements SatuanRemoteDataSource {
  final Dio dio;
  final LocalDatasource authLocalDataSource;

  SatuanRemoteDataSourceImpl(
      {required this.dio, required this.authLocalDataSource});

  Future<Options> _getOptionsWithToken() async {
    final token = await authLocalDataSource.getAuthToken();
    if (token == null)
      throw AuthException('Sesi berakhir, silakan login kembali.');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<List<SatuanModel>> getAllSatuan() async {
    try {
      final response = await dio.get('$baseUrl/satuans',
          options: await _getOptionsWithToken());
      List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => SatuanModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(
          e.response?.data['message'] ?? 'Gagal memuat satuan.');
    }
  }

  @override
  Future<SatuanModel> getSatuanById(int id) async {
    try {
      final response = await dio.get('$baseUrl/satuans/$id',
          options: await _getOptionsWithToken());
      return SatuanModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(
          e.response?.data['message'] ?? 'Gagal memuat satuan dengan ID $id.');
    }
  }

  @override
  Future<SatuanModel> createSatuan(String name, String? description) async {
    try {
      final response = await dio.post(
        '$baseUrl/satuans',
        data: {
          'name': name,
          'description': description,
        },
        options: await _getOptionsWithToken(),
      );
      return SatuanModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(
          e.response?.data['message'] ?? 'Gagal membuat satuan.');
    }
  }

  @override
  Future<SatuanModel> updateSatuan(
      int id, String name, String? description) async {
    try {
      final response = await dio.put(
        '$baseUrl/satuans/$id',
        data: {
          'name': name,
          'description': description,
        },
        options: await _getOptionsWithToken(),
      );
      return SatuanModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(e.response?.data['message'] ??
          'Gagal memperbarui satuan dengan ID $id.');
    }
  }

  @override
  Future<void> deleteSatuan(int id) async {
    try {
      await dio.delete(
        '$baseUrl/satuans/$id',
        options: await _getOptionsWithToken(),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(e.response?.data['message'] ??
          'Gagal menghapus satuan dengan ID $id.');
    }
  }
  // Implement other remote data source methods here...
}
