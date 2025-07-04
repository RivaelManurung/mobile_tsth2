import 'package:inventory_tsth2/features/barang_category/domain/entities/barang_category.dart';

class BarangCategoryModel extends BarangCategory {
  const BarangCategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  factory BarangCategoryModel.fromJson(Map<String, dynamic> json) {
    return BarangCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }
}