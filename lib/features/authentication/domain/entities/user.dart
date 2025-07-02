import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? token; // Token bisa null

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
  });

  @override
  List<Object?> get props => [id, name, email, role, token];
}