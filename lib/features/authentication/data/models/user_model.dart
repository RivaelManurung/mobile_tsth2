import 'package:inventory_tsth2/features/authentication/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    super.email,
    required super.role,
    super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return UserModel(
      id: user['id'],
      name: user['name'],
      email: user['email'],
      role: user['role'],
      token: json['token'],
    );
  }

  factory UserModel.fromUserJson(Map<String, dynamic> user) {
    return UserModel(
      id: user['id'],
      name: user['name'],
      email: user['email'],
      role: user['role'],
    );
  }
   static UserModel fromEntity(User user) {
    return UserModel(
      // Map all required fields from User to UserModel here
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      // Add other fields as necessary
    );
  }
  
}
