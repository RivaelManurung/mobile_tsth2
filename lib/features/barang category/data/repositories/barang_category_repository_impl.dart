import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/exceptions.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/features/barang%20category/data/datasources/barang_category_remote_data_source.dart';
import 'package:inventory_tsth2/features/barang%20category/domain/entities/barang_category.dart';
import 'package:inventory_tsth2/features/barang%20category/domain/repositories/barang_category_repository.dart';

class BarangCategoryRepositoryImpl implements BarangCategoryRepository {
  final BarangCategoryRemoteDataSource remoteDataSource;

  BarangCategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failures, List<BarangCategory>>> getAllBarangCategories() async {
    try {
      final remoteCategories = await remoteDataSource.getAllBarangCategories();
      return Right(remoteCategories);
    } on AuthException catch(e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failures, BarangCategory>> getBarangCategoryById(int id) async {
     try {
      final remoteCategory = await remoteDataSource.getBarangCategoryById(id);
      return Right(remoteCategory);
    } on AuthException catch(e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

   @override
  Future<Either<Failures, BarangCategory>> createBarangCategory(String name, String slug) async {
     try {
      final newCategory = await remoteDataSource.createBarangCategory(name, slug);
      return Right(newCategory);
    } on AuthException catch(e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failures, BarangCategory>> updateBarangCategory(int id, String name, String slug) async {
     try {
      final updatedCategory = await remoteDataSource.updateBarangCategory(id, name, slug);
      return Right(updatedCategory);
    } on AuthException catch(e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failures, Unit>> deleteBarangCategory(int id) async {
     try {
      await remoteDataSource.deleteBarangCategory(id);
      return const Right(unit);
    } on AuthException catch(e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}