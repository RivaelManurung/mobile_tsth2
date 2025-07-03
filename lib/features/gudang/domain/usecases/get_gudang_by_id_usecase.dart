import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';
import 'package:inventory_tsth2/features/gudang/domain/entities/gudang.dart';
import 'package:inventory_tsth2/features/gudang/domain/repositories/gudang_repository.dart';

class GetGudangByIdUsecase implements Usecase<Gudang, GetGudangByIdParams> {
  final GudangRepository repository;

  GetGudangByIdUsecase(this.repository);

  @override
  Future<Either<Failures, Gudang>> call(GetGudangByIdParams params) async {
    return await repository.getGudangById(params.id);
  }
}

class GetGudangByIdParams extends Equatable {
  final int id;

  const GetGudangByIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}