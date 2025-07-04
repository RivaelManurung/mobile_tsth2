import 'package:dio/dio.dart';
import 'package:inventory_tsth2/core/constant/api_constant.dart';
import 'package:inventory_tsth2/core/error/exceptions.dart';
import 'package:inventory_tsth2/features/authentication/data/datasources/local_dataSource.dart';
import 'package:inventory_tsth2/features/jenis_barang/data/models/jenis_barang_model.dart';

abstract class JenisBarangRemoteDataSource {
  Future<List<JenisBarangModel>> getAllJenisBarang();
  Future<JenisBarangModel> getJenisBarangById(int id);
  Future<JenisBarangModel> createJenisBarang(String name, String? description);
  Future<JenisBarangModel> updateJenisBarang(int id, String name, String? description);
  Future<void> deleteJenisBarang(int id);
}

class JenisBarangRemoteDataSourceImpl implements JenisBarangRemoteDataSource {
  final Dio dio;
  final LocalDatasource authLocalDataSource;

  JenisBarangRemoteDataSourceImpl({required this.dio, required this.authLocalDataSource});

  Future<Options> _getOptionsWithToken() async {
    final token = await authLocalDataSource.getAuthToken();
    if (token == null) throw AuthException('Sesi berakhir, silakan login kembali.');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<List<JenisBarangModel>> getAllJenisBarang() async {
    try {
      final response = await dio.get('$baseUrl/jenis-barangs', options: await _getOptionsWithToken());
      List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => JenisBarangModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(e.response?.data['message'] ?? 'Gagal memuat jenis barang.');
    }
  }

  @override
  Future<JenisBarangModel> getJenisBarangById(int id) async {
    try {
      final response = await dio.get('$baseUrl/jenis-barangs/$id', options: await _getOptionsWithToken());
      return JenisBarangModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(e.response?.data['message'] ?? 'Gagal memuat detail.');
    }
  }

  @override
  Future<JenisBarangModel> createJenisBarang(String name, String? description) async {
    try {
      final response = await dio.post(
        '$baseUrl/jenis-barangs',
        data: {'name': name, 'description': description},
        options: await _getOptionsWithToken(),
      );
      return JenisBarangModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(e.response?.data['message'] ?? 'Gagal membuat jenis barang.');
    }
  }

  @override
  Future<JenisBarangModel> updateJenisBarang(int id, String name, String? description) async {
    try {
      final response = await dio.put(
        '$baseUrl/jenis-barangs/$id',
        data: {'name': name, 'description': description},
        options: await _getOptionsWithToken(),
      );
      return JenisBarangModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(e.response?.data['message'] ?? 'Gagal memperbarui jenis barang.');
    }
  }

  @override
  Future<void> deleteJenisBarang(int id) async {
    try {
      await dio.delete('$baseUrl/jenis-barangs/$id', options: await _getOptionsWithToken());
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(e.response?.data['message'] ?? 'Gagal menghapus jenis barang.');
    }
  }
}