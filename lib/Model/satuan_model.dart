class Satuan {
  final int id;
  final String name;
  final String? description;
  final String slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;
    final DateTime? deletedAt;


  Satuan({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Satuan.fromJson(Map<String, dynamic> json) {
    print('Satuan: Parsing JSON: $json'); // Debug log
    return Satuan(
      id: json['id'] ?? (throw Exception('Missing id in Satuan JSON')),
      name: json['name'] ?? (throw Exception('Missing name in Satuan JSON')),
      description: json['description'],
      slug: json['slug'] ?? (throw Exception('Missing slug in Satuan JSON')),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? null
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
      'description': description,
      'slug': slug,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}