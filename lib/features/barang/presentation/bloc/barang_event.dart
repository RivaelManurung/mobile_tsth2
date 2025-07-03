import 'package:equatable/equatable.dart';

abstract class BarangEvent extends Equatable {
  const BarangEvent();

  @override
  List<Object> get props => [];
}

class FetchAllBarangEvent extends BarangEvent {}

class FetchBarangDetailEvent extends BarangEvent {
  final int id;
  const FetchBarangDetailEvent(this.id);
  @override
  List<Object> get props => [id];
}

class ClearBarangSelectionEvent extends BarangEvent {}