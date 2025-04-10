class BarangCategory {
  final int id;
  final String name;
  final String slug;

  BarangCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory BarangCategory.fromJson(Map<String, dynamic> json) {
    return BarangCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
    };
  }
}