// lib/models/barang_model.dart
class Barang {
  final int id;
  final String barangNama;
  final String barangSlug;
  final double barangHarga;
  final String? barangGambar;
  final String barangKode;
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
    this.barangGambar,
    required this.barangKode,
    this.jenisbarangId,
    this.satuanId,
    this.barangcategoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    print('Parsing Barang JSON: $json'); // Debug log
    return Barang(
      id: json['id'] ?? 0,
      barangNama: json['nama']?.toString() ?? json['barang_nama']?.toString() ?? 'Unknown',
      barangSlug: json['barang_slug']?.toString() ?? 'unknown-slug',
      barangHarga: double.tryParse(json['barang_harga']?.toString() ?? '0.0') ?? 0.0,
      barangGambar: json['barang_gambar'],
      barangKode: json['kode']?.toString() ?? json['barang_kode']?.toString() ?? 'UNKNOWN',
      jenisbarangId: json['jenisbarang_id'],
      satuanId: json['satuan_id'],
      barangcategoryId: json['barangcategory_id'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barang_nama': barangNama,
      'barang_harga': barangHarga,
      'barang_kode': barangKode,
      'jenisbarang_id': jenisbarangId,
      'satuan_id': satuanId,
      'barangcategory_id': barangcategoryId,
      if (barangGambar != null) 'barang_gambar': barangGambar,
    };
  }
}