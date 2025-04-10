class JenisBarang {
  final int id;
  final String name;
  final String? description;
  final String slug;
  final int userId;

  JenisBarang({
    required this.id,
    required this.name,
    this.description,
    required this.slug,
    required this.userId,
  });

  factory JenisBarang.fromJson(Map<String, dynamic> json) {
    return JenisBarang(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      slug: json['slug'] as String,
      userId: json['user_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'slug': slug,
      'user_id': userId,
    };
  }
}