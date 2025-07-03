import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';
import 'package:inventory_tsth2/features/barang%20category/domain/entities/barang_category.dart';
import 'package:inventory_tsth2/features/barang%20category/domain/usecases/get_all_barang_categories_usecase.dart';
import 'package:inventory_tsth2/features/barang%20category/presentation/bloc/barang_category_event.dart';
import 'package:inventory_tsth2/features/barang%20category/presentation/bloc/barang_category_state.dart';
import 'package:inventory_tsth2/features/barang/domain/usecases/get_barang_by_id_usecase.dart';

class BarangCategoryBloc extends Bloc<BarangCategoryEvent, BarangCategoryState> {
  final GetAllBarangCategoriesUsecase getAllCategories;
  final GetBarangByIdUsecase getCategoryById;
  // Inject other usecases (create, update, delete) here

  List<BarangCategory> _masterList = [];

  BarangCategoryBloc({
    required this.getAllCategories,
    required this.getCategoryById,
  }) : super(BarangCategoryInitial()) {
    on<FetchAllBarangCategoriesEvent>(_onFetchAll);
    on<SelectBarangCategoryEvent>(_onSelect);
    on<ClearBarangCategorySelectionEvent>(_onClearSelection);
  }

  Future<void> _onFetchAll(FetchAllBarangCategoriesEvent event, Emitter<BarangCategoryState> emit) async {
    emit(BarangCategoryLoading());
    final failureOrCategories = await getAllCategories(NoParams());
    failureOrCategories.fold(
      (failure) => emit(BarangCategoryError(failure.message)),
      (categories) {
        _masterList = categories;
        emit(BarangCategoryLoaded(categories));
      },
    );
  }
  
  Future<void> _onSelect(SelectBarangCategoryEvent event, Emitter<BarangCategoryState> emit) async {
     emit(BarangCategoryLoading());
     // For simplicity, we can just find it from the master list if already loaded.
     // For fresher data, call the usecase.
     final category = _masterList.firstWhere((cat) => cat.id == event.id, orElse: () => _masterList.first);
     emit(BarangCategoryDetailLoaded(category));
  }

  void _onClearSelection(ClearBarangCategorySelectionEvent event, Emitter<BarangCategoryState> emit) {
      emit(BarangCategoryLoaded(_masterList));
  }
}