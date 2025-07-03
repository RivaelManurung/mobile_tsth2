import 'package:equatable/equatable.dart';

abstract class GudangEvent extends Equatable {
  const GudangEvent();

  @override
  List<Object> get props => [];
}

class FetchAllGudangEvent extends GudangEvent {}

class FetchGudangDetailEvent extends GudangEvent {
  final int id;
  const FetchGudangDetailEvent(this.id);
  @override
  List<Object> get props => [id];
}

class SearchGudangEvent extends GudangEvent {
  final String query;
  const SearchGudangEvent(this.query);
   @override
  List<Object> get props => [query];
}

class ClearGudangSelectionEvent extends GudangEvent {}