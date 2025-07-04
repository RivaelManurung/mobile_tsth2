import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';
import 'package:inventory_tsth2/features/jenis_barang/domain/entities/jenis_barang.dart';
import 'package:inventory_tsth2/features/jenis_barang/domain/usecases/get_all_jenis_barang_usecase.dart';
import 'package:inventory_tsth2/features/jenis_barang/presentation/bloc/jenis_barang_event.dart';
import 'package:inventory_tsth2/features/jenis_barang/presentation/bloc/jenis_barang_state.dart';

class JenisBarangBloc extends Bloc<JenisBarangEvent, JenisBarangState> {
  final GetAllJenisBarangUsecase getAllJenisBarang;
  // Inject other usecases here

  List<JenisBarang> _masterList = [];

  JenisBarangBloc({required this.getAllJenisBarang}) : super(JenisBarangInitial()) {
    on<FetchAllJenisBarangEvent>(_onFetchAll);
    on<SelectJenisBarangEvent>(_onSelect);
    on<ClearJenisBarangSelectionEvent>(_onClearSelection);
  }

  Future<void> _onFetchAll(FetchAllJenisBarangEvent event, Emitter<JenisBarangState> emit) async {
    emit(JenisBarangLoading());
    final failureOrData = await getAllJenisBarang(NoParams());
    failureOrData.fold(
      (failure) => emit(JenisBarangError(failure.message)),
      (data) {
        _masterList = data;
        emit(JenisBarangLoaded(data));
      },
    );
  }
  
  void _onSelect(SelectJenisBarangEvent event, Emitter<JenisBarangState> emit) {
     final selected = _masterList.firstWhere((t) => t.id == event.id);
     emit(JenisBarangDetailLoaded(selected));
  }

  void _onClearSelection(ClearJenisBarangSelectionEvent event, Emitter<JenisBarangState> emit) {
    emit(JenisBarangLoaded(_masterList));
  }
}