// lib/models/barang_model.dart
class Barang {
  final int id;
  final String barangNama;
  final String barangSlug;
  final double barangHarga;
  final String? barangGambar;
  final String barangKode;
  final String? jenisbarangNama; // Menggunakan nama, bukan ID
  final String? satuanNama;     // Menggunakan nama, bukan ID
  final String? barangcategoryNama; // Menggunakan nama, bukan ID
  final DateTime createdAt;
  final DateTime updatedAt;

  Barang({
    required this.id,
    required this.barangNama,
    required this.barangSlug,
    required this.barangHarga,
    this.barangGambar,
    required this.barangKode,
    this.jenisbarangNama,
    this.satuanNama,
    this.barangcategoryNama,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    print('Parsing Barang JSON: $json'); // Debug log
    return Barang(
      id: json['id'] ?? 0,
      barangNama: json['barang_nama']?.toString() ?? json['nama']?.toString() ?? 'Unknown',
      barangSlug: json['barang_slug']?.toString() ?? 'unknown-slug',
      barangHarga: double.tryParse(json['barang_harga']?.toString() ?? '0.0') ?? 0.0,
      barangGambar: json['barang_gambar'],
      barangKode: json['barang_kode']?.toString() ?? json['kode']?.toString() ?? 'UNKNOWN',
      jenisbarangNama: json['jenisBarang']?.toString() ?? 'Tidak diketahui', // Ambil dari 'jenisBarang'
      satuanNama: json['satuan']?.toString() ?? 'Tidak diketahui',          // Ambil dari 'satuan'
      barangcategoryNama: json['category']?.toString() ?? 'Tidak diketahui', // Ambil dari 'category'
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barang_nama': barangNama,
      'barang_harga': barangHarga,
      'barang_kode': barangKode,
      'jenisbarang_nama': jenisbarangNama,
      'satuan_nama': satuanNama,
      'barangcategory_nama': barangcategoryNama,
      if (barangGambar != null) 'barang_gambar': barangGambar,
    };
  }
}