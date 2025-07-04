import 'package:inventory_tsth2/features/satuan/domain/entities/satuan.dart';

class SatuanModel extends Satuan {
  const SatuanModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  factory SatuanModel.fromJson(Map<String, dynamic> json) {
    return SatuanModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }
}