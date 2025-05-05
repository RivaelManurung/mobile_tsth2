class JenisBarang {
  final int id;
  final String name;
  final String? description;
  final String slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  JenisBarang({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory JenisBarang.fromJson(Map<String, dynamic> json) {
    return JenisBarang(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      slug: json['slug'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  get deletedAt => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'slug': slug,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}