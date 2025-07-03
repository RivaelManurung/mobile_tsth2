import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:inventory_tsth2/core/error/exceptions.dart';
import 'package:inventory_tsth2/features/authentication/data/models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> login(String name, String password);
  Future<void> logout(String token);
}

const String baseUrl = "YOUR_API_BASE_URL"; // Replace with your actual base URL

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio client;

  AuthRemoteDatasourceImpl(this.client);

  @override
  Future<UserModel> login(String name, String password) async {
    try {
      final response = await client.post(
        '$baseUrl/auth/login',
        data: {'name': name, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw AuthException(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Server Error');
    }
  }

  @override
  Future<void> logout(String token) async {
    try {
      await client.post(
        '$baseUrl/auth/logout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Logout failed');
    }
  }
}
