import 'package:equatable/equatable.dart';

abstract class JenisBarangEvent extends Equatable {
  const JenisBarangEvent();
  @override
  List<Object> get props => [];
}

class FetchAllJenisBarangEvent extends JenisBarangEvent {}

class SelectJenisBarangEvent extends JenisBarangEvent {
  final int id;
  const SelectJenisBarangEvent(this.id);
  @override
  List<Object> get props => [id];
}

class ClearJenisBarangSelectionEvent extends JenisBarangEvent {}