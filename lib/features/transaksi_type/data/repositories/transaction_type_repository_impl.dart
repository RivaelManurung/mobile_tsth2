import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/exceptions.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/features/transaksi_type/data/datasources/transaction_type_remote_data_source.dart';
import 'package:inventory_tsth2/features/transaksi_type/domain/entities/transaction_type.dart';
import 'package:inventory_tsth2/features/transaksi_type/domain/repositories/transaction_type_repository.dart';

class TransactionTypeRepositoryImpl implements TransactionTypeRepository {
  final TransactionTypeRemoteDataSource remoteDataSource;

  TransactionTypeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failures, List<TransactionType>>> getAllTransactionTypes() async {
    try {
      final remoteData = await remoteDataSource.getAllTransactionTypes();
      return Right(remoteData);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failures, TransactionType>> getTransactionTypeById(int id) async {
    try {
      final remoteData = await remoteDataSource.getTransactionTypeById(id);
      return Right(remoteData);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failures, TransactionType>> createTransactionType(String name) async {
    try {
      final remoteData = await remoteDataSource.createTransactionType(name);
      return Right(remoteData);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failures, TransactionType>> updateTransactionType(int id, String name) async {
    try {
      final remoteData = await remoteDataSource.updateTransactionType(id, name);
      return Right(remoteData);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failures, Unit>> deleteTransactionType(int id) async {
    try {
      await remoteDataSource.deleteTransactionType(id);
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}