import 'package:inventory_tsth2/Model/barang_gudang_model.dart';
import 'package:inventory_tsth2/features/barang/data/models/barang_gudang_model.dart';
import 'package:inventory_tsth2/features/barang/domain/entities/barang.dart';

class BarangModel extends Barang {
  const BarangModel({
    required super.id,
    required super.barangNama,
    required super.barangKode,
    required super.barangHarga,
    super.barangGambar,
    super.jenisbarangNama,
    super.satuanNama,
    super.barangcategoryNama,
    super.gudangs,
  });

  factory BarangModel.fromJson(Map<String, dynamic> json) {
    var gudangsFromJson = json['gudangs'] as List?;
    List<BarangGudangModel> gudangList = gudangsFromJson?.isNotEmpty == true
        ? gudangsFromJson!.map((g) => BarangGudangModel.fromJson(g)).toList()
        : [];

    return BarangModel(
      id: json['id'] ?? 0,
      barangNama: json['barang_nama'] ?? 'Unknown',
      barangKode: json['barang_kode'] ?? 'UNKNOWN',
      barangHarga: double.tryParse(json['barang_harga']?.toString() ?? '0.0') ?? 0.0,
      barangGambar: json['barang_gambar'],
      jenisbarangNama: json['jenisBarang'],
      satuanNama: json['satuan'],
      barangcategoryNama: json['category'],
      gudangs: gudangList.cast<BarangGudang>(),
    );
  }
}