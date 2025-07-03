import 'package:equatable/equatable.dart';
import 'package:inventory_tsth2/Model/barang_gudang_model.dart';

class Barang extends Equatable {
  final int id;
  final String barangNama;
  final String barangKode;
  final double barangHarga;
  final String? barangGambar;
  final String? jenisbarangNama;
  final String? satuanNama;
  final String? barangcategoryNama;
  final List<BarangGudang> gudangs; // Embed warehouse stock info

  const Barang({
    required this.id,
    required this.barangNama,
    required this.barangKode,
    required this.barangHarga,
    this.barangGambar,
    this.jenisbarangNama,
    this.satuanNama,
    this.barangcategoryNama,
    this.gudangs = const [],
  });

  // Helper to calculate total stock
  int get totalStokTersedia =>
      gudangs.fold(0, (sum, gudang) => sum + gudang.stokTersedia);

  @override
  List<Object?> get props => [
        id,
        barangNama,
        barangKode,
        barangHarga,
        barangGambar,
        jenisbarangNama,
        satuanNama,
        barangcategoryNama,
        gudangs,
      ];
}
