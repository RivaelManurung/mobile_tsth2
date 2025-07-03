import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/features/barang/domain/entities/barang.dart';

abstract class BarangRepository {
  Future<Either<Failures, List<Barang>>> getAllBarang();
  Future<Either<Failures, Barang>> getBarangById(int id);
}