import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';
import 'package:inventory_tsth2/features/barang%20category/domain/entities/barang_category.dart';
import 'package:inventory_tsth2/features/barang%20category/domain/repositories/barang_category_repository.dart';


class GetAllBarangCategoriesUsecase implements Usecase<List<BarangCategory>, NoParams> {
  final BarangCategoryRepository repository;

  GetAllBarangCategoriesUsecase(this.repository);

  @override
  Future<Either<Failures, List<BarangCategory>>> call(NoParams params) async {
    return await repository.getAllBarangCategories();
  }
}