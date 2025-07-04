import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/Model/user_model.dart';
import 'package:inventory_tsth2/core/error/failures.dart';

abstract class ProfileRepository {
  Future<Either<Failures, User>> getCurrentUser();
  Future<Either<Failures, User>> updateUserProfile(User user);
  Future<Either<Failures, User>> updateAvatar(File imageFile);
  Future<Either<Failures, Unit>> changePassword(String currentPassword, String newPassword);
}