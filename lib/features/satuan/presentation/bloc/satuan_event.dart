import 'package:equatable/equatable.dart';

abstract class SatuanEvent extends Equatable {
  const SatuanEvent();
  @override
  List<Object> get props => [];
}

class FetchAllSatuanEvent extends SatuanEvent {}

class SelectSatuanEvent extends SatuanEvent {
  final int id;
  const SelectSatuanEvent(this.id);
  @override
  List<Object> get props => [id];
}

class ClearSatuanSelectionEvent extends SatuanEvent {}