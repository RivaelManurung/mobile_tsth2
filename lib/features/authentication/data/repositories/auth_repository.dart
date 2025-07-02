import 'package:inventory_tsth2/core/error/exceptions.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/platform/network_info.dart';
import 'package:inventory_tsth2/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:inventory_tsth2/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:inventory_tsth2/features/auth/data/models/user_model.dart';
import 'package:inventory_tsth2/features/auth/domain/entities/user.dart';
import 'package:inventory_tsth2/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> login(String name, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.login(name, password);
        await localDataSource.cacheAuthToken(userModel.token!);
        await localDataSource.cacheUser(userModel.toJsonString());
        return Right(userModel);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(ConnectionFailure('No Internet Connection'));
    }
  }
  
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final token = await localDataSource.getAuthToken();
      if(token != null) {
         await remoteDataSource.logout(token);
      }
      await localDataSource.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Logout Failed'));
    }
  }

  @override
  Future<Either<Failure, User>> checkLoginStatus() async {
     try {
      final token = await localDataSource.getAuthToken();
      if (token == null) {
        return Left(AuthenticationFailure('Not Logged In'));
      }

      if (await networkInfo.isConnected) {
        try {
          final userModel = await remoteDataSource.verifyToken(token);
           await localDataSource.cacheUser(userModel.toJsonString());
          return Right(userModel);
        } on ServerException {
          // Jika token tidak valid di server, logout user
          await localDataSource.clearAll();
          return Left(AuthenticationFailure('Invalid Session, Please Login Again'));
        }
      } else {
        // Jika offline, gunakan data dari cache
        final userJson = await localDataSource.getUser();
        if(userJson != null) {
          return Right(UserModel.fromJsonString(userJson));
        } else {
          return Left(CacheFailure('No cached user found.'));
        }
      }
     } catch (e) {
        return Left(CacheFailure('Failed to check login status.'));
     }
  }
}