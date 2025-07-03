import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/features/gudang/domain/entities/gudang.dart';

abstract class GudangRepository {
  Future<Either<Failures, List<Gudang>>> getAllGudang();
  Future<Either<Failures, Gudang>> getGudangById(int id);
}