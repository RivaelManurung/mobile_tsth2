import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/exceptions.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/features/jenis_barang/data/datasources/jenis_barang_remote_data_source.dart';
import 'package:inventory_tsth2/features/jenis_barang/domain/entities/jenis_barang.dart';
import 'package:inventory_tsth2/features/jenis_barang/domain/repositories/jenis_barang_repository.dart';

class JenisBarangRepositoryImpl implements JenisBarangRepository {
  final JenisBarangRemoteDataSource remoteDataSource;

  JenisBarangRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failures, List<JenisBarang>>> getAllJenisBarang() async {
    try {
      final remoteData = await remoteDataSource.getAllJenisBarang();
      return Right(remoteData);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
  
  // Implement other repository methods (getById, create, update, delete) here...
  @override
  Future<Either<Failures, JenisBarang>> getJenisBarangById(int id) async {
    try {
      final remoteData = await remoteDataSource.getJenisBarangById(id);
      return Right(remoteData);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failures, JenisBarang>> createJenisBarang(String name, String? description) async {
    try {
      final remoteData = await remoteDataSource.createJenisBarang(name, description);
      return Right(remoteData);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failures, JenisBarang>> updateJenisBarang(int id, String name, String? description) async {
    try {
      final remoteData = await remoteDataSource.updateJenisBarang(id, name, description);
      return Right(remoteData);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failures, Unit>> deleteJenisBarang(int id) async {
    try {
      await remoteDataSource.deleteJenisBarang(id);
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}