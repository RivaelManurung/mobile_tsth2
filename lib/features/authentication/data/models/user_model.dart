import 'dart:convert';
import 'package:inventory_tsth2/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.token, // Token kini menjadi bagian dari entitas/model
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      token: json['token'], // Ambil token jika ada
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'token': token,
    };
  }

  // Helper untuk mengubah objek menjadi string JSON
  String toJsonString() => jsonEncode(toJson());

  // Helper untuk membuat objek dari string JSON
  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString));
  }
}