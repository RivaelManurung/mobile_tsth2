import 'package:inventory_tsth2/features/jenis_barang/domain/entities/jenis_barang.dart';

class JenisBarangModel extends JenisBarang {
  const JenisBarangModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  factory JenisBarangModel.fromJson(Map<String, dynamic> json) {
    return JenisBarangModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }
}