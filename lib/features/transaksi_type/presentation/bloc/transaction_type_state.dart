import 'package:equatable/equatable.dart';
import 'package:inventory_tsth2/features/transaksi_type/domain/entities/transaction_type.dart';

abstract class TransactionTypeState extends Equatable {
  const TransactionTypeState();
  @override
  List<Object?> get props => [];
}

class TransactionTypeInitial extends TransactionTypeState {}

class TransactionTypeLoading extends TransactionTypeState {}

class TransactionTypeLoaded extends TransactionTypeState {
  final List<TransactionType> transactionTypes;
  const TransactionTypeLoaded(this.transactionTypes);
  @override
  List<Object> get props => [transactionTypes];
}

class TransactionTypeDetailLoaded extends TransactionTypeState {
  final TransactionType transactionType;
  const TransactionTypeDetailLoaded(this.transactionType);
  @override
  List<Object> get props => [transactionType];
}

class TransactionTypeError extends TransactionTypeState {
  final String message;
  const TransactionTypeError(this.message);
  @override
  List<Object> get props => [message];
}