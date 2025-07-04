import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';
import 'package:inventory_tsth2/features/jenis_barang/domain/entities/jenis_barang.dart';
import 'package:inventory_tsth2/features/jenis_barang/domain/repositories/jenis_barang_repository.dart';

class GetAllJenisBarangUsecase implements Usecase<List<JenisBarang>, NoParams> {
  final JenisBarangRepository repository;

  GetAllJenisBarangUsecase(this.repository);

  @override
  Future<Either<Failures, List<JenisBarang>>> call(NoParams params) async {
    return await repository.getAllJenisBarang();
  }
}