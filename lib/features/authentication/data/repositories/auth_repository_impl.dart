import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/exceptions.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:inventory_tsth2/features/authentication/data/datasources/local_dataSource.dart';
import 'package:inventory_tsth2/features/authentication/domain/entities/user.dart';
import 'package:inventory_tsth2/features/authentication/domain/repositories/auth_repositories.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource authRemoteDatasource;
  final LocalDatasource localDatasource;
  // final NetworkInfo networkInfo; // Assuming you have a network info utility

  AuthRepositoryImpl({
    required this.authRemoteDatasource,
    required this.localDatasource,
    // required this.networkInfo,
  });

  @override
  Future<Either<Failures, User>> login(String name, String password) async {
    // if (await networkInfo.isConnected) {
    try {
      final userModel = await authRemoteDatasource.login(name, password);
      await localDatasource.cacheAuthToken(userModel.token!);
      await localDatasource.cacheUser(userModel);
      return Right(userModel);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
    // } else {
    //   return const Left(NetworkFailure('No Internet Connection'));
    // }
  }

  @override
  Future<Either<Failures, Unit>> logout() async {
     try {
        final token = await localDatasource.getAuthToken();
        if (token != null) {
          await authRemoteDatasource.logout(token);
        }
        await localDatasource.clearCache();
        return const Right(unit);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
  }
  
  @override
  Future<Either<Failures, User>> getLoggedInUser() async {
    try {
      final user = await localDatasource.getUser();
      if (user != null) {
        return Right(user);
      } else {
        return const Left(CacheFailure('No user found'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}