import 'package:equatable/equatable.dart';
import 'package:inventory_tsth2/features/satuan/domain/entities/satuan.dart';

abstract class SatuanState extends Equatable {
  const SatuanState();
  @override
  List<Object?> get props => [];
}

class SatuanInitial extends SatuanState {}

class SatuanLoading extends SatuanState {}

class SatuanLoaded extends SatuanState {
  final List<Satuan> satuanList;
  const SatuanLoaded(this.satuanList);
  @override
  List<Object> get props => [satuanList];
}

class SatuanDetailLoaded extends SatuanState {
  final Satuan satuan;
  const SatuanDetailLoaded(this.satuan);
  @override
  List<Object> get props => [satuan];
}

class SatuanError extends SatuanState {
  final String message;
  const SatuanError(this.message);
  @override
  List<Object> get props => [message];
}