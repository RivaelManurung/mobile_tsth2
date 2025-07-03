import 'package:dio/dio.dart';
import 'package:inventory_tsth2/core/constant/api_constant.dart';
import 'package:inventory_tsth2/core/error/exceptions.dart';
import 'package:inventory_tsth2/features/authentication/data/datasources/local_dataSource.dart';
import 'package:inventory_tsth2/features/gudang/data/models/gudang_model.dart';

abstract class GudangRemoteDataSource {
  Future<List<GudangModel>> getAllGudang();
  Future<GudangModel> getGudangById(int id);
}

class GudangRemoteDataSourceImpl implements GudangRemoteDataSource {
  final Dio dio;
  final LocalDatasource authLocalDataSource;

  GudangRemoteDataSourceImpl({required this.dio, required this.authLocalDataSource});

  Future<Options> _getOptionsWithToken() async {
    final token = await authLocalDataSource.getAuthToken();
    if (token == null) throw AuthException('Sesi berakhir, silakan login kembali.');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<List<GudangModel>> getAllGudang() async {
    try {
      final response = await dio.get(
        '$baseUrl/gudangs',
        options: await _getOptionsWithToken(),
      );
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => GudangModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(e.response?.data['message'] ?? 'Gagal memuat daftar gudang.');
    }
  }

  @override
  Future<GudangModel> getGudangById(int id) async {
    try {
      final response = await dio.get(
        '$baseUrl/gudangs/$id',
        options: await _getOptionsWithToken(),
      );
      return GudangModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(e.response?.data['message'] ?? 'Gagal memuat detail gudang.');
    }
  }
}