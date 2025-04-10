class Gudang {
  final int id;
  final String name;
  final String? description;
  final String slug;

  Gudang({
    required this.id,
    required this.name,
    this.description,
    required this.slug,
  });

  factory Gudang.fromJson(Map<String, dynamic> json) {
    return Gudang(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      slug: json['slug'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'slug': slug,
    };
  }
}