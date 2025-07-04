import 'package:equatable/equatable.dart';
import 'package:inventory_tsth2/features/jenis_barang/domain/entities/jenis_barang.dart';

abstract class JenisBarangState extends Equatable {
  const JenisBarangState();
  @override
  List<Object?> get props => [];
}

class JenisBarangInitial extends JenisBarangState {}

class JenisBarangLoading extends JenisBarangState {}

class JenisBarangLoaded extends JenisBarangState {
  final List<JenisBarang> jenisBarangList;
  const JenisBarangLoaded(this.jenisBarangList);
  @override
  List<Object> get props => [jenisBarangList];
}

class JenisBarangDetailLoaded extends JenisBarangState {
  final JenisBarang jenisBarang;
  const JenisBarangDetailLoaded(this.jenisBarang);
  @override
  List<Object> get props => [jenisBarang];
}

class JenisBarangError extends JenisBarangState {
  final String message;
  const JenisBarangError(this.message);
  @override
  List<Object> get props => [message];
}