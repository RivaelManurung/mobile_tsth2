import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/exceptions.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/features/gudang/data/datasources/gudang_remote_data_source.dart';
import 'package:inventory_tsth2/features/gudang/domain/entities/gudang.dart';
import 'package:inventory_tsth2/features/gudang/domain/repositories/gudang_repository.dart';

class GudangRepositoryImpl implements GudangRepository {
  final GudangRemoteDataSource remoteDataSource;
  // final NetworkInfo networkInfo; // Optional

  GudangRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failures, List<Gudang>>> getAllGudang() async {
    try {
      final remoteGudang = await remoteDataSource.getAllGudang();
      return Right(remoteGudang);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failures, Gudang>> getGudangById(int id) async {
     try {
      final remoteGudang = await remoteDataSource.getGudangById(id);
      return Right(remoteGudang);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}