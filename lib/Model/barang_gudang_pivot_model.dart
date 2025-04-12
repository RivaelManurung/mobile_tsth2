class BarangGudangPivot {
  final int barangId;
  final int gudangId;
  final int stokTersedia;
  final int stokDipinjam;
  final int stokMaintenance;

  BarangGudangPivot({
    required this.barangId,
    required this.gudangId,
    required this.stokTersedia,
    required this.stokDipinjam,
    required this.stokMaintenance,
  });

  factory BarangGudangPivot.fromJson(Map<String, dynamic> json) {
    return BarangGudangPivot(
      barangId: json['barang_id'] is int ? json['barang_id'] as int : int.parse(json['barang_id'].toString()),
      gudangId: json['gudang_id'] is int ? json['gudang_id'] as int : int.parse(json['gudang_id'].toString()),
      stokTersedia: json['stok_tersedia'] is int ? json['stok_tersedia'] as int : int.parse(json['stok_tersedia'].toString()),
      stokDipinjam: json['stok_dipinjam'] is int ? json['stok_dipinjam'] as int : int.parse(json['stok_dipinjam'].toString()),
      stokMaintenance: json['stok_maintenance'] is int ? json['stok_maintenance'] as int : int.parse(json['stok_maintenance'].toString()),
    );
  }
}