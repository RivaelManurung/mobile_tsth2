import 'package:inventory_tsth2/Model/gudang_model.dart';

class BarangGudang {
  final int barangId;
  final int gudangId;
  final int stokTersedia;
  final int stokDipinjam;
  final int stokMaintenance;
  final Gudang? gudang; // Tambahkan field gudang untuk menyimpan informasi lengkap
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  BarangGudang({
    required this.barangId,
    required this.gudangId,
    required this.stokTersedia,
    required this.stokDipinjam,
    required this.stokMaintenance,
    this.gudang,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory BarangGudang.fromJson(Map<String, dynamic> json) {
    return BarangGudang(
      barangId: json['barang_id'] ?? 0,
      gudangId: json['gudang_id'] ?? json['id'] ?? 0,
      stokTersedia: json['stok_tersedia'] ?? 0,
      stokDipinjam: json['stok_dipinjam'] ?? 0,
      stokMaintenance: json['stok_maintenance'] ?? 0,
      gudang: json.containsKey('id') ? Gudang.fromJson(json) : null, // Parse informasi gudang
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barang_id': barangId,
      'gudang_id': gudangId,
      'stok_tersedia': stokTersedia,
      'stok_dipinjam': stokDipinjam,
      'stok_maintenance': stokMaintenance,
      'gudang': gudang?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}