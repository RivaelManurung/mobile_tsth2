import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/features/authentication/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failures, User>> login(String name, String password);
  Future<Either<Failures, Unit>> logout();
  Future<Either<Failures, User>> getLoggedInUser();
}