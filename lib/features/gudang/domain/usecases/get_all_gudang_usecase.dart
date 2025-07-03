import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';
import 'package:inventory_tsth2/features/gudang/domain/entities/gudang.dart';
import 'package:inventory_tsth2/features/gudang/domain/repositories/gudang_repository.dart';

class GetAllGudangUsecase implements Usecase<List<Gudang>, NoParams> {
  final GudangRepository repository;

  GetAllGudangUsecase(this.repository);

  @override
  Future<Either<Failures, List<Gudang>>> call(NoParams params) async {
    return await repository.getAllGudang();
  }
}