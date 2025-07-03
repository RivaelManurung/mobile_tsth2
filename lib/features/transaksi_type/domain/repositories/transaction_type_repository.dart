import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/features/transaksi_type/domain/entities/transaction_type.dart';

abstract class TransactionTypeRepository {
  Future<Either<Failures, List<TransactionType>>> getAllTransactionTypes();
  Future<Either<Failures, TransactionType>> getTransactionTypeById(int id);
  Future<Either<Failures, TransactionType>> createTransactionType(String name);
  Future<Either<Failures, TransactionType>> updateTransactionType(int id, String name);
  Future<Either<Failures, Unit>> deleteTransactionType(int id);
}