import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';
import 'package:inventory_tsth2/features/transaksi_type/domain/entities/transaction_type.dart';
import 'package:inventory_tsth2/features/transaksi_type/domain/repositories/transaction_type_repository.dart';

class GetAllTransactionTypesUsecase implements Usecase<List<TransactionType>, NoParams> {
  final TransactionTypeRepository repository;

  GetAllTransactionTypesUsecase(this.repository);

  @override
  Future<Either<Failures, List<TransactionType>>> call(NoParams params) async {
    return await repository.getAllTransactionTypes();
  }
}