import 'package:dio/dio.dart';
import 'package:inventory_tsth2/core/constant/api_constant.dart'; // Your API constants
import 'package:inventory_tsth2/core/error/exceptions.dart';
import 'package:inventory_tsth2/features/authentication/data/models/user_model.dart'; // Custom exceptions

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String name, String password);
  Future<void> logout(String token);
  Future<UserModel> getLoggedInUser(String token);
}

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
        return UserModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Network Error');
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
      // We can ignore logout errors on the server side as we clear local data anyway
      print('Logout error: ${e.response?.data['message'] ?? e.message}');
    }
  }
  
  @override
  Future<UserModel> getLoggedInUser(String token) async {
    try {
      final response = await client.get(
        '/auth/user',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw AuthException('Invalid or expired token.');
      }
    } on DioException {
      throw AuthException('Invalid or expired token.');
    }
  }
}