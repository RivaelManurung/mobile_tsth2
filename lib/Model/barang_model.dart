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
    return Barang(
      id: json['id'] ?? 0,
      barangNama: json['barang_nama'] ?? '',
      barangSlug: json['barang_slug'] ?? '',
      barangHarga: double.tryParse(json['barang_harga'].toString()) ?? 0.0,
      barangGambar: json['barang_gambar'],
      barangKode: json['barang_kode'] ?? '',
      jenisbarangId: json['jenisbarang_id'],
      satuanId: json['satuan_id'],
      barangcategoryId: json['barangcategory_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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