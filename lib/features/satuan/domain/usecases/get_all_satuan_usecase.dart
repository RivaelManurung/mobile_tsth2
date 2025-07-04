import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';
import 'package:inventory_tsth2/features/satuan/domain/entities/satuan.dart';
import 'package:inventory_tsth2/features/satuan/domain/repositories/satuan_repository.dart';

class GetAllSatuanUsecase implements Usecase<List<Satuan>, NoParams> {
  final SatuanRepository repository;

  GetAllSatuanUsecase(this.repository);

  @override
  Future<Either<Failures, List<Satuan>>> call(NoParams params) async {
    return await repository.getAllSatuan();
  }
}