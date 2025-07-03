import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';
import 'package:inventory_tsth2/features/barang/domain/entities/barang.dart';
import 'package:inventory_tsth2/features/barang/domain/usecases/get_all_barang_usecase.dart';
import 'package:inventory_tsth2/features/barang/domain/usecases/get_barang_by_id_usecase.dart';
import 'package:inventory_tsth2/features/barang/presentation/bloc/barang_event.dart';
import 'package:inventory_tsth2/features/barang/presentation/bloc/barang_state.dart';

class BarangBloc extends Bloc<BarangEvent, BarangState> {
  final GetAllBarangUsecase getAllBarangUsecase;
  final GetBarangByIdUsecase getBarangByIdUsecase;

  List<Barang> _cachedBarangList = [];

  BarangBloc({
    required this.getAllBarangUsecase,
    required this.getBarangByIdUsecase,
  }) : super(BarangInitial()) {
    on<FetchAllBarangEvent>(_onFetchAllBarang);
    on<FetchBarangDetailEvent>(_onFetchBarangDetail);
    on<ClearBarangSelectionEvent>(_onClearSelection);
  }

  Future<void> _onFetchAllBarang(
    FetchAllBarangEvent event,
    Emitter<BarangState> emit,
  ) async {
    emit(BarangLoading());
    final failureOrBarangList = await getAllBarangUsecase(NoParams());
    failureOrBarangList.fold(
      (failure) => emit(BarangError(failure.message)),
      (barangList) {
        _cachedBarangList = barangList;
        emit(BarangListLoaded(barangList));
      },
    );
  }

  Future<void> _onFetchBarangDetail(
    FetchBarangDetailEvent event,
    Emitter<BarangState> emit,
  ) async {
    emit(BarangLoading());
    final failureOrBarang = await getBarangByIdUsecase(GetBarangByIdParams(id: event.id));
     failureOrBarang.fold(
      (failure) => emit(BarangError(failure.message)),
      (barang) => emit(BarangDetailLoaded(_cachedBarangList, barang)),
    );
  }

  void _onClearSelection(
    ClearBarangSelectionEvent event,
    Emitter<BarangState> emit,
  ) {
    emit(BarangListLoaded(_cachedBarangList));
  }
}