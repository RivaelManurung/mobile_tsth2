import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventory_tsth2/features/authentication/data/models/user_model.dart';

const String authTokenKey = "authToken";
const String userKey = "user";

abstract class LocalDatasource {
  Future<void> cacheAuthToken(String token);
  Future<void> cacheUser(UserModel user);
  Future<String?> getAuthToken();
  Future<UserModel?> getUser();
  Future<void> clearCache();
}

class LocalDatasourceImpl implements LocalDatasource {
  final FlutterSecureStorage secureStorage;

  LocalDatasourceImpl(this.secureStorage);

  @override
  Future<void> cacheAuthToken(String token) {
    return secureStorage.write(key: authTokenKey, value: token);
  }

  @override
  Future<void> cacheUser(UserModel user) {
     final userJson = {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'role': user.role,
    };
    return secureStorage.write(key: userKey, value: jsonEncode(userJson));
  }
  
  @override
  Future<String?> getAuthToken() {
    return secureStorage.read(key: authTokenKey);
  }

  @override
  Future<UserModel?> getUser() async {
    final userString = await secureStorage.read(key: userKey);
    if (userString != null) {
      return UserModel.fromUserJson(jsonDecode(userString));
    }
    return null;
  }
  
  @override
  Future<void> clearCache() async {
    await secureStorage.delete(key: authTokenKey);
    await secureStorage.delete(key: userKey);
  }
}