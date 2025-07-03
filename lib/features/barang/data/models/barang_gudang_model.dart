import 'package:inventory_tsth2/features/barang/domain/entities/barang_gudang.dart';

class BarangGudangModel extends BarangGudang {
  const BarangGudangModel({
    required super.gudangId,
    super.gudangName,
    super.operatorName,
    required super.stokTersedia,
    required super.stokDipinjam,
    required super.stokMaintenance,
  });

  factory BarangGudangModel.fromJson(Map<String, dynamic> json) {
    return BarangGudangModel(
      gudangId: json['id'] ?? 0,
      gudangName: json['nama'],
      operatorName: json['user']?['name'],
      stokTersedia: json['pivot']?['stok_tersedia'] ?? 0,
      stokDipinjam: json['pivot']?['stok_dipinjam'] ?? 0,
      stokMaintenance: json['pivot']?['stok_maintenance'] ?? 0,
    );
  }
}