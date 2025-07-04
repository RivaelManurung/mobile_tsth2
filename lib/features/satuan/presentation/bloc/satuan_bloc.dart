import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';
import 'package:inventory_tsth2/features/satuan/domain/entities/satuan.dart';
import 'package:inventory_tsth2/features/satuan/domain/usecases/get_all_satuan_usecase.dart';
import 'package:inventory_tsth2/features/satuan/presentation/bloc/satuan_event.dart';
import 'package:inventory_tsth2/features/satuan/presentation/bloc/satuan_state.dart';

class SatuanBloc extends Bloc<SatuanEvent, SatuanState> {
  final GetAllSatuanUsecase getAllSatuan;
  // Inject other usecases here

  List<Satuan> _masterList = [];

  SatuanBloc({required this.getAllSatuan}) : super(SatuanInitial()) {
    on<FetchAllSatuanEvent>(_onFetchAll);
    on<SelectSatuanEvent>(_onSelect);
    on<ClearSatuanSelectionEvent>(_onClearSelection);
  }

  Future<void> _onFetchAll(FetchAllSatuanEvent event, Emitter<SatuanState> emit) async {
    emit(SatuanLoading());
    final failureOrData = await getAllSatuan(NoParams());
    failureOrData.fold(
      (failure) => emit(SatuanError(failure.message)),
      (data) {
        _masterList = data;
        emit(SatuanLoaded(data));
      },
    );
  }

  void _onSelect(SelectSatuanEvent event, Emitter<SatuanState> emit) {
    final selected = _masterList.firstWhere((s) => s.id == event.id);
    emit(SatuanDetailLoaded(selected));
  }

  void _onClearSelection(ClearSatuanSelectionEvent event, Emitter<SatuanState> emit) {
    emit(SatuanLoaded(_masterList));
  }
}