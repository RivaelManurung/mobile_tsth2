import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/features/jenis_barang/domain/entities/jenis_barang.dart';

abstract class JenisBarangRepository {
  Future<Either<Failures, List<JenisBarang>>> getAllJenisBarang();
  Future<Either<Failures, JenisBarang>> getJenisBarangById(int id);
  Future<Either<Failures, JenisBarang>> createJenisBarang(String name, String? description);
  Future<Either<Failures, JenisBarang>> updateJenisBarang(int id, String name, String? description);
  Future<Either<Failures, Unit>> deleteJenisBarang(int id);
}