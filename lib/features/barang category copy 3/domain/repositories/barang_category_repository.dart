import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/features/barang_category/domain/entities/barang_category.dart';

abstract class BarangCategoryRepository {
  Future<Either<Failures, List<BarangCategory>>> getAllBarangCategories();
  Future<Either<Failures, BarangCategory>> getBarangCategoryById(int id);
  Future<Either<Failures, BarangCategory>> createBarangCategory(String name, String slug);
  Future<Either<Failures, BarangCategory>> updateBarangCategory(int id, String name, String slug);
  Future<Either<Failures, Unit>> deleteBarangCategory(int id);
}