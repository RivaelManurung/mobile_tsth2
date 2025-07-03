import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';
import 'package:inventory_tsth2/features/transaksi_type/domain/entities/transaction_type.dart';
import 'package:inventory_tsth2/features/transaksi_type/domain/usecases/get_all_transaction_types_usecase.dart';
import 'package:inventory_tsth2/features/transaksi_type/presentation/bloc/transaction_type_event.dart';
import 'package:inventory_tsth2/features/transaksi_type/presentation/bloc/transaction_type_state.dart';

class TransactionTypeBloc extends Bloc<TransactionTypeEvent, TransactionTypeState> {
  final GetAllTransactionTypesUsecase getAllTransactionTypes;
  // Inject other usecases here as needed (getById, create, etc.)

  List<TransactionType> _masterList = [];

  TransactionTypeBloc({
    required this.getAllTransactionTypes,
  }) : super(TransactionTypeInitial()) {
    on<FetchAllTransactionTypesEvent>(_onFetchAll);
    on<SelectTransactionTypeEvent>(_onSelect);
    on<ClearSelectionEvent>(_onClearSelection);
  }

  Future<void> _onFetchAll(FetchAllTransactionTypesEvent event, Emitter<TransactionTypeState> emit) async {
    emit(TransactionTypeLoading());
    final failureOrData = await getAllTransactionTypes(NoParams());
    failureOrData.fold(
      (failure) => emit(TransactionTypeError(failure.message)),
      (data) {
        _masterList = data;
        emit(TransactionTypeLoaded(data));
      },
    );
  }
  
  void _onSelect(SelectTransactionTypeEvent event, Emitter<TransactionTypeState> emit) {
     final selected = _masterList.firstWhere((t) => t.id == event.id);
     emit(TransactionTypeDetailLoaded(selected));
  }

  void _onClearSelection(ClearSelectionEvent event, Emitter<TransactionTypeState> emit) {
      emit(TransactionTypeLoaded(_masterList));
  }
}