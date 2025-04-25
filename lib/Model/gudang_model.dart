import 'package:inventory_tsth2/Model/user_model.dart';

class Gudang {
  final int id;
  final String name;
  final String? slug;
  final String? description;
  final int? userId;
  final User? user; // Tambahkan field user
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  Gudang({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.userId,
    this.user,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Gudang.fromJson(Map<String, dynamic> json) {
    print('Parsing Gudang JSON: $json');
    return Gudang(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      description: json['description']?.toString(),
      userId: json['user_id'] as int?,
      user: json['user'] != null ? User.fromJson(json['user']) : null, // Parse user
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'user_id': userId,
      'user': user?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}