import 'package:inventory_tsth2/Model/barang_gudang_pivot_model.dart';
import 'package:inventory_tsth2/Model/gudang_model.dart';

class Barang {
  final int id;
  final String barangKode;
  final String barangNama;
  final String barangSlug;
  final double barangHarga;
  final String barangGambar;
  final int? jenisbarangId;
  final int? satuanId;
  final int? barangcategoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Gudang> gudangs;
  final List<BarangGudangPivot>? pivots;

  Barang({
    required this.id,
    required this.barangKode,
    required this.barangNama,
    required this.barangSlug,
    required this.barangHarga,
    required this.barangGambar,
    this.jenisbarangId,
    this.satuanId,
    this.barangcategoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.gudangs,
    this.pivots,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    final gudangList = (json['gudangs'] as List<dynamic>?) ?? [];
    return Barang(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      barangKode: json['barang_kode'] as String? ?? 'BRG-UNKNOWN',
      barangNama: json['barang_nama'] as String? ?? 'Unnamed',
      barangSlug: json['barang_slug'] as String? ?? 'unnamed',
      barangHarga: json['barang_harga'] is int
          ? (json['barang_harga'] as int).toDouble()
          : json['barang_harga'] is double
              ? (json['barang_harga'] as double)
              : double.tryParse(json['barang_harga'].toString()) ?? 0.0, // Handle String
      barangGambar: json['barang_gambar'] as String? ?? '',
      jenisbarangId: json['jenisbarang_id'] as int?,
      satuanId: json['satuan_id'] as int?,
      barangcategoryId: json['barangcategory_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String? ?? '1970-01-01'),
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? '1970-01-01'),
      gudangs: gudangList.map((g) => Gudang.fromJson(g as Map<String, dynamic>)).toList(),
      pivots: gudangList.map((g) => BarangGudangPivot.fromJson({
        'barang_id': json['id'],
        'gudang_id': g['id'],
        'stok_tersedia': g['stok_tersedia'],
        'stok_dipinjam': g['stok_dipinjam'],
        'stok_maintenance': g['stok_maintenance'],
      })).toList(),
    );
  }

  int get stokTersedia => pivots?.isNotEmpty ?? false ? pivots![0].stokTersedia : 0;
}