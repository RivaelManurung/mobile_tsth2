class BarangCategory {
  final int id;
  final String name;
  final String slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  BarangCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory BarangCategory.fromJson(Map<String, dynamic> json) {
    return BarangCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at']) ?? null
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at']) ?? null
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
