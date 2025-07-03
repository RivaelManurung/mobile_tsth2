import 'package:dio/dio.dart';
import 'package:inventory_tsth2/core/constant/api_constant.dart';
import 'package:inventory_tsth2/core/error/exceptions.dart';
import 'package:inventory_tsth2/features/authentication/data/datasources/local_dataSource.dart';
import 'package:inventory_tsth2/features/barang_category/data/models/barang_category_model.dart';


abstract class BarangCategoryRemoteDataSource {
  Future<List<BarangCategoryModel>> getAllBarangCategories();
  Future<BarangCategoryModel> getBarangCategoryById(int id);
  Future<BarangCategoryModel> createBarangCategory(String name, String slug);
  Future<BarangCategoryModel> updateBarangCategory(int id, String name, String slug);
  Future<void> deleteBarangCategory(int id);
}

class BarangCategoryRemoteDataSourceImpl implements BarangCategoryRemoteDataSource {
  final Dio dio;
  final LocalDatasource authLocalDataSource;

  BarangCategoryRemoteDataSourceImpl({required this.dio, required this.authLocalDataSource});

  Future<Options> _getOptionsWithToken() async {
    final token = await authLocalDataSource.getAuthToken();
    if (token == null) throw AuthException('Sesi berakhir, silakan login kembali.');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<List<BarangCategoryModel>> getAllBarangCategories() async {
    try {
      final response = await dio.get('$baseUrl/barang-categories', options: await _getOptionsWithToken());
      List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => BarangCategoryModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(e.response?.data['message'] ?? 'Gagal memuat kategori.');
    }
  }

  @override
  Future<BarangCategoryModel> getBarangCategoryById(int id) async {
    try {
      final response = await dio.get('$baseUrl/barang-categories/$id', options: await _getOptionsWithToken());
      return BarangCategoryModel.fromJson(response.data['data']);
    } on DioException catch (e) {
        if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
        throw ServerException(e.response?.data['message'] ?? 'Gagal memuat detail kategori.');
    }
  }

  @override
  Future<BarangCategoryModel> createBarangCategory(String name, String slug) async {
    try {
      final response = await dio.post(
        '$baseUrl/barang-categories',
        data: {'name': name, 'slug': slug},
        options: await _getOptionsWithToken(),
      );
      return BarangCategoryModel.fromJson(response.data['data']);
    } on DioException catch (e) {
        if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
        throw ServerException(e.response?.data['message'] ?? 'Gagal membuat kategori.');
    }
  }

  @override
  Future<BarangCategoryModel> updateBarangCategory(int id, String name, String slug) async {
     try {
      final response = await dio.put(
        '$baseUrl/barang-categories/$id',
        data: {'name': name, 'slug': slug},
        options: await _getOptionsWithToken(),
      );
      return BarangCategoryModel.fromJson(response.data['data']);
    } on DioException catch (e) {
        if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
        throw ServerException(e.response?.data['message'] ?? 'Gagal memperbarui kategori.');
    }
  }

  @override
  Future<void> deleteBarangCategory(int id) async {
    try {
      await dio.delete('$baseUrl/barang-categories/$id', options: await _getOptionsWithToken());
    } on DioException catch (e) {
        if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
        throw ServerException(e.response?.data['message'] ?? 'Gagal menghapus kategori.');
    }
  }
}