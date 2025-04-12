class Gudang {
  final int id;
  final String name;
  final String? slug;
  final String? description;
  final int stokTersedia;
  final int stokDipinjam;
  final int stokMaintenance;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  Gudang({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    required this.stokTersedia,
    required this.stokDipinjam,
    required this.stokMaintenance,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Gudang.fromJson(Map<String, dynamic> json) {
    return Gudang(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'],
      description: json['description'],
      stokTersedia: json['stok_tersedia'] ?? 0,
      stokDipinjam: json['stok_dipinjam'] ?? 0,
      stokMaintenance: json['stok_maintenance'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
    );
  }
}
