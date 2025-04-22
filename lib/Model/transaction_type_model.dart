class TransactionType {
  final int id;
  final String name;
  final String slug;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  TransactionType({
    required this.id,
    required this.name,
    required this.slug,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory TransactionType.fromJson(Map<String, dynamic> json) {
    print('Parsing TransactionType JSON: $json');
    return TransactionType(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? 'Unknown',
      slug: (json['slug'] as String?)?.toString() ?? 'unknown-slug', // Explicitly cast and provide fallback
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      deletedAt: json['deleted_at']?.toString(),
    );
  }
}