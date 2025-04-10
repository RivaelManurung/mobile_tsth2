// lib/models/barang_model.dart
class Barang {
  final int id;
  final String barangNama;
  final String barangSlug;
  final int barangHarga;
  final String barangGambar;
  final int stokTersedia;
  final int? jenisbarangId;
  final int? satuanId;
  final int? barangcategoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Barang({
    required this.id,
    required this.barangNama,
    required this.barangSlug,
    required this.barangHarga,
    required this.barangGambar,
    required this.stokTersedia,
    this.jenisbarangId,
    this.satuanId,
    this.barangcategoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'],
      barangNama: json['barang_nama'],
      barangSlug: json['barang_slug'],
      barangHarga: json['barang_harga'],
      barangGambar: json['barang_gambar'],
      stokTersedia: json['stok_tersedia'],
      jenisbarangId: json['jenisbarang_id'],
      satuanId: json['satuan_id'],
      barangcategoryId: json['barangcategory_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}