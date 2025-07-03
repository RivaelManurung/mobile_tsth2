import 'package:equatable/equatable.dart';

class BarangGudang extends Equatable {
  final int gudangId;
  final String? gudangName;
  final String? operatorName;
  final int stokTersedia;
  final int stokDipinjam;
  final int stokMaintenance;

  const BarangGudang({
    required this.gudangId,
    this.gudangName,
    this.operatorName,
    required this.stokTersedia,
    required this.stokDipinjam,
    required this.stokMaintenance,
  });

  @override
  List<Object?> get props => [
        gudangId,
        gudangName,
        operatorName,
        stokTersedia,
        stokDipinjam,
        stokMaintenance
      ];
}