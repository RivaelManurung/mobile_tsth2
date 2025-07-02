import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:inventory_tsth2/core/constants/api_constant.dart';
import 'package:inventory_tsth2/core/error/exceptions.dart';
import 'package:inventory_tsth2/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:inventory_tsth2/features/auth/data/models/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> login(String name, String password) async {
    try {
      final response = await client.post(
        '/auth/login',
        data: {'name': name, 'password': password},
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final token = response.data['data']['token'] as String;
        final user = response.data['data']['user'] as Map<String, dynamic>;
        
        // Menambahkan token ke dalam data user sebelum di-decode menjadi UserModel
        user['token'] = token;
        return UserModel.fromJson(user);
      } else {
        throw ServerException(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<void> logout(String token) async {
    try {
      await client.post(
        '/auth/logout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      // Gagal logout di server tidak menghentikan proses logout di client
      print('Logout error on server: ${e.message}');
    }
  }

  @override
  Future<UserModel> verifyToken(String token) async {
    try {
      final response = await client.get(
        '/auth/user',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
         final user = response.data['data'] as Map<String, dynamic>;
         user['token'] = token;
        return UserModel.fromJson(user);
      } else {
        throw ServerException('Invalid Token');
      }
    } on DioException {
      throw ServerException('Invalid Token');
    }
  }
}