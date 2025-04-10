class TransactionType {
  final int id;
  final String name;
  final String slug;

  TransactionType({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory TransactionType.fromJson(Map<String, dynamic> json) {
    return TransactionType(
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