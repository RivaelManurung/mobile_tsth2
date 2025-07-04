import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/features/satuan/domain/entities/satuan.dart';

abstract class SatuanRepository {
  Future<Either<Failures, List<Satuan>>> getAllSatuan();
  Future<Either<Failures, Satuan>> getSatuanById(int id);
  Future<Either<Failures, Satuan>> createSatuan(String name, String? description);
  Future<Either<Failures, Satuan>> updateSatuan(int id, String name, String? description);
  Future<Either<Failures, Unit>> deleteSatuan(int id);
}