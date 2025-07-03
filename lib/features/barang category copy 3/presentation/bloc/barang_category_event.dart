import 'package:equatable/equatable.dart';

abstract class BarangCategoryEvent extends Equatable {
  const BarangCategoryEvent();
  @override
  List<Object> get props => [];
}

class FetchAllBarangCategoriesEvent extends BarangCategoryEvent {}

class SelectBarangCategoryEvent extends BarangCategoryEvent {
    final int id;
    const SelectBarangCategoryEvent(this.id);
    @override
    List<Object> get props => [id];
}

class ClearBarangCategorySelectionEvent extends BarangCategoryEvent {}