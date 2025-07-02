import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventory_tsth2/features/auth/data/datasources/auth_local_data_source.dart';

const CACHED_AUTH_TOKEN = 'CACHED_AUTH_TOKEN';
const CACHED_USER = 'CACHED_USER';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheAuthToken(String token) {
    return secureStorage.write(key: CACHED_AUTH_TOKEN, value: token);
  }

  @override
  Future<void> cacheUser(String userJson) {
     return secureStorage.write(key: CACHED_USER, value: userJson);
  }

  @override
  Future<String?> getAuthToken() {
    return secureStorage.read(key: CACHED_AUTH_TOKEN);
  }
   @override
  Future<String?> getUser() {
    return secureStorage.read(key: CACHED_USER);
  }

  @override
  Future<void> clearAll() async {
    await secureStorage.delete(key: CACHED_AUTH_TOKEN);
    await secureStorage.delete(key: CACHED_USER);
  }
}