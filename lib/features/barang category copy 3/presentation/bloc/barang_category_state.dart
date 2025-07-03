import 'package:equatable/equatable.dart';
import 'package:inventory_tsth2/features/barang_category/domain/entities/barang_category.dart';

abstract class BarangCategoryState extends Equatable {
  const BarangCategoryState();
  @override
  List<Object?> get props => [];
}

class BarangCategoryInitial extends BarangCategoryState {}

class BarangCategoryLoading extends BarangCategoryState {}

class BarangCategoryLoaded extends BarangCategoryState {
  final List<BarangCategory> categories;
  const BarangCategoryLoaded(this.categories);
  @override
  List<Object> get props => [categories];
}

class BarangCategoryDetailLoaded extends BarangCategoryState {
  final BarangCategory category;
  const BarangCategoryDetailLoaded(this.category);
  @override
  List<Object> get props => [category];
}

class BarangCategoryError extends BarangCategoryState {
  final String message;
  const BarangCategoryError(this.message);
  @override
  List<Object> get props => [message];
}