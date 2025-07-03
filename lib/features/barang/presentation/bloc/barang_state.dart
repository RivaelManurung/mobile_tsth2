import 'package:equatable/equatable.dart';
import 'package:inventory_tsth2/features/barang/domain/entities/barang.dart';

abstract class BarangState extends Equatable {
  const BarangState();

  @override
  List<Object?> get props => [];
}

class BarangInitial extends BarangState {}

class BarangLoading extends BarangState {}

// Holds the main list, can be used to return from detail view
class BarangListLoaded extends BarangState {
  final List<Barang> barangList;
  const BarangListLoaded(this.barangList);
  @override
  List<Object> get props => [barangList];
}

// Specific state for when a single item detail is being viewed
class BarangDetailLoaded extends BarangState {
  final List<Barang> barangList; // Keep the original list for background state
  final Barang selectedBarang;
  const BarangDetailLoaded(this.barangList, this.selectedBarang);
  @override
  List<Object?> get props => [barangList, selectedBarang];
}

class BarangError extends BarangState {
  final String message;
  const BarangError(this.message);
  @override
  List<Object> get props => [message];
}