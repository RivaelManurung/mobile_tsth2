import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/Model/user_model.dart';
import 'package:inventory_tsth2/core/error/exceptions.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/features/authentication/data/models/user_model.dart';
import 'package:inventory_tsth2/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:inventory_tsth2/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failures, User>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failures, User>> updateUserProfile(User user) async {
    try {
       // Convert entity to model for sending to data source
      final userModel = UserModel.fromEntity(user); 
      final updatedUser = await remoteDataSource.updateUserProfile(userModel);
      return Right(updatedUser.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
  
  @override
  Future<Either<Failures, Unit>> changePassword(String currentPassword, String newPassword) {
    // TODO: implement changePassword
    throw UnimplementedError();
  }
  
  @override
  Future<Either<Failures, User>> updateAvatar(File imageFile) {
    // TODO: implement updateAvatar
    throw UnimplementedError();
  }
  
  // Implement other repository methods (updateAvatar, changePassword)...
}