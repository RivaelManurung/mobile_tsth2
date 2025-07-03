import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';
import 'package:inventory_tsth2/features/barang/domain/entities/barang.dart';
import 'package:inventory_tsth2/features/barang/domain/repositories/barang_repository.dart';

class GetBarangByIdUsecase implements Usecase<Barang, GetBarangByIdParams> {
  final BarangRepository repository;

  GetBarangByIdUsecase(this.repository);

  @override
  Future<Either<Failures, Barang>> call(GetBarangByIdParams params) async {
    return await repository.getBarangById(params.id);
  }
}

class GetBarangByIdParams extends Equatable {
  final int id;

  const GetBarangByIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}