import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:inventory_tsth2/core/constant/api_constant.dart';
import 'package:inventory_tsth2/core/error/exceptions.dart';
import 'package:inventory_tsth2/features/authentication/data/datasources/local_dataSource.dart';
import 'package:inventory_tsth2/features/authentication/data/models/user_model.dart';


abstract class ProfileRemoteDataSource {
  Future<UserModel> getCurrentUser();
  Future<UserModel> updateUserProfile(UserModel user);
  Future<UserModel> updateAvatar(File imageFile);
  Future<void> changePassword(String currentPassword, String newPassword);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;
  final LocalDatasource authLocalDataSource;

  ProfileRemoteDataSourceImpl({required this.dio, required this.authLocalDataSource});

  Future<Options> _getOptionsWithToken() async {
    final token = await authLocalDataSource.getAuthToken();
    if (token == null) throw AuthException('Sesi berakhir, silakan login kembali.');
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dio.get('$baseUrl/user/profile', options: await _getOptionsWithToken());
      return UserModel.fromUserJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(e.response?.data['message'] ?? 'Gagal memuat profil.');
    }
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    try {
      final response = await dio.put(
        '$baseUrl/user/profile/update',
        data: user.toJson(), // Assume UserModel has a toJson method
        options: await _getOptionsWithToken(),
      );
      return UserModel.fromUserJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(e.response?.data['message'] ?? 'Gagal memperbarui profil.');
    }
  }

  @override
  Future<UserModel> updateAvatar(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "photo": await MultipartFile.fromFile(imageFile.path, 
            filename: fileName, 
            contentType: MediaType("image", "jpeg")),
      });

      final response = await dio.post(
        '$baseUrl/user/profile/avatar',
        data: formData,
        options: await _getOptionsWithToken(),
      );
      return UserModel.fromUserJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(e.response?.data['message'] ?? 'Gagal memperbarui avatar.');
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
     try {
      await dio.put(
        '$baseUrl/user/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        },
        options: await _getOptionsWithToken(),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw AuthException('Unauthenticated');
      throw ServerException(e.response?.data['message'] ?? 'Gagal mengubah password.');
    }
  }
}