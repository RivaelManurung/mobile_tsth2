import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/exceptions.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/features/satuan/data/datasources/satuan_remote_data_source.dart';
import 'package:inventory_tsth2/features/satuan/domain/entities/satuan.dart';
import 'package:inventory_tsth2/features/satuan/domain/repositories/satuan_repository.dart';

class SatuanRepositoryImpl implements SatuanRepository {
  final SatuanRemoteDataSource remoteDataSource;

  SatuanRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failures, List<Satuan>>> getAllSatuan() async {
    try {
      final remoteData = await remoteDataSource.getAllSatuan();
      return Right(remoteData);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
  
  @override
  Future<Either<Failures, Satuan>> createSatuan(String name, String? description) {
    // TODO: implement createSatuan
    throw UnimplementedError();
  }
  
  @override
  Future<Either<Failures, Unit>> deleteSatuan(int id) {
    // TODO: implement deleteSatuan
    throw UnimplementedError();
  }
  
  @override
  Future<Either<Failures, Satuan>> getSatuanById(int id) {
    // TODO: implement getSatuanById
    throw UnimplementedError();
  }
  
  @override
  Future<Either<Failures, Satuan>> updateSatuan(int id, String name, String? description) {
    // TODO: implement updateSatuan
    throw UnimplementedError();
  }
  
  // Implement other repository methods here...
}