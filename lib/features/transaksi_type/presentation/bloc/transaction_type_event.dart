import 'package:equatable/equatable.dart';

abstract class TransactionTypeEvent extends Equatable {
  const TransactionTypeEvent();
  @override
  List<Object> get props => [];
}

class FetchAllTransactionTypesEvent extends TransactionTypeEvent {}

class SelectTransactionTypeEvent extends TransactionTypeEvent {
  final int id;
  const SelectTransactionTypeEvent(this.id);
  @override
  List<Object> get props => [id];
}

class ClearSelectionEvent extends TransactionTypeEvent {}