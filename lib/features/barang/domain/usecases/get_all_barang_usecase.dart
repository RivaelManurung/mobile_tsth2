import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';
import 'package:inventory_tsth2/features/barang/domain/entities/barang.dart';
import 'package:inventory_tsth2/features/barang/domain/repositories/barang_repository.dart';

class GetAllBarangUsecase implements Usecase<List<Barang>, NoParams> {
  final BarangRepository repository;

  GetAllBarangUsecase(this.repository);

  @override
  Future<Either<Failures, List<Barang>>> call(NoParams params) async {
    return await repository.getAllBarang();
  }
}