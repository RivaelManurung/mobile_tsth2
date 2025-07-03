import 'package:equatable/equatable.dart';
import 'package:inventory_tsth2/features/gudang/domain/entities/gudang.dart';

abstract class GudangState extends Equatable {
  const GudangState();

  @override
  List<Object?> get props => [];
}

class GudangInitial extends GudangState {}

class GudangLoading extends GudangState {}

class GudangLoaded extends GudangState {
  final List<Gudang> allGudang;
  final List<Gudang> filteredGudang;
  
  const GudangLoaded({required this.allGudang, required this.filteredGudang});
  
  @override
  List<Object> get props => [allGudang, filteredGudang];
}

class GudangDetailLoaded extends GudangState {
  final Gudang selectedGudang;
  
  const GudangDetailLoaded(this.selectedGudang);
  
  @override
  List<Object> get props => [selectedGudang];
}

class GudangError extends GudangState {
  final String message;
  const GudangError(this.message);
  @override
  List<Object> get props => [message];
}