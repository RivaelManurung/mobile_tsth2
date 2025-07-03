import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';
import 'package:inventory_tsth2/features/gudang/domain/entities/gudang.dart';
import 'package:inventory_tsth2/features/gudang/domain/usecases/get_all_gudang_usecase.dart';
import 'package:inventory_tsth2/features/gudang/domain/usecases/get_gudang_by_id_usecase.dart';
import 'package:inventory_tsth2/features/gudang/presentation/bloc/gudang_event.dart';
import 'package:inventory_tsth2/features/gudang/presentation/bloc/gudang_state.dart';
import 'package:stream_transform/stream_transform.dart';

const _duration = Duration(milliseconds: 300);

EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class GudangBloc extends Bloc<GudangEvent, GudangState> {
  final GetAllGudangUsecase getAllGudangUsecase;
  final GetGudangByIdUsecase getGudangByIdUsecase;

  List<Gudang> _masterGudangList = [];

  GudangBloc({
    required this.getAllGudangUsecase,
    required this.getGudangByIdUsecase,
  }) : super(GudangInitial()) {
    on<FetchAllGudangEvent>(_onFetchAllGudang);
    on<FetchGudangDetailEvent>(_onFetchGudangDetail);
    on<ClearGudangSelectionEvent>(_onClearSelection);
    on<SearchGudangEvent>(_onSearch, transformer: debounce(_duration));
  }

  Future<void> _onFetchAllGudang(
    FetchAllGudangEvent event,
    Emitter<GudangState> emit,
  ) async {
    emit(GudangLoading());
    final failureOrGudangList = await getAllGudangUsecase(NoParams());
    failureOrGudangList.fold(
      (failure) => emit(GudangError(failure.message)),
      (gudangList) {
        _masterGudangList = gudangList;
        emit(GudangLoaded(allGudang: gudangList, filteredGudang: gudangList));
      },
    );
  }

  Future<void> _onFetchGudangDetail(
    FetchGudangDetailEvent event,
    Emitter<GudangState> emit,
  ) async {
    emit(GudangLoading());
    final failureOrGudang = await getGudangByIdUsecase(GetGudangByIdParams(id: event.id));
    failureOrGudang.fold(
      (failure) => emit(GudangError(failure.message)),
      (gudang) => emit(GudangDetailLoaded(gudang)),
    );
  }
  
  void _onClearSelection(
    ClearGudangSelectionEvent event,
    Emitter<GudangState> emit,
  ) {
    emit(GudangLoaded(allGudang: _masterGudangList, filteredGudang: _masterGudangList));
  }
  
  void _onSearch(SearchGudangEvent event, Emitter<GudangState> emit) {
    final query = event.query.toLowerCase();
    if (query.isEmpty) {
      emit(GudangLoaded(allGudang: _masterGudangList, filteredGudang: _masterGudangList));
    } else {
      final filteredList = _masterGudangList.where((gudang) {
        return gudang.name.toLowerCase().contains(query) ||
            (gudang.description?.toLowerCase().contains(query) ?? false);
      }).toList();
      emit(GudangLoaded(allGudang: _masterGudangList, filteredGudang: filteredList));
    }
  }
}