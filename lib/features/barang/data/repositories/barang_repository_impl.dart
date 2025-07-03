import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/exceptions.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/features/barang/data/datasources/barang_remote_data_source.dart';
import 'package:inventory_tsth2/features/barang/domain/entities/barang.dart';
import 'package:inventory_tsth2/features/barang/domain/repositories/barang_repository.dart';

class BarangRepositoryImpl implements BarangRepository {
  final BarangRemoteDataSource remoteDataSource;
  // final NetworkInfo networkInfo; // Optional: for checking connectivity

  BarangRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failures, List<Barang>>> getAllBarang() async {
    try {
      final remoteBarang = await remoteDataSource.getAllBarang();
      return Right(remoteBarang);
    } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failures, Barang>> getBarangById(int id) async {
    try {
      final remoteBarang = await remoteDataSource.getBarangById(id);
      return Right(remoteBarang);
    } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}