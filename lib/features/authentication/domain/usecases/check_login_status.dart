import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';
import 'package:inventory_tsth2/features/authentication/domain/entities/user.dart';
import 'package:inventory_tsth2/features/authentication/domain/repositories/auth_repositories.dart';


class CheckLoginStatus implements Usecase<User, NoParams> {
  final AuthRepository repository;

  CheckLoginStatus(this.repository);

  @override
  Future<Either<Failures, User>> call(NoParams params) async {
    return await repository.checkLoginStatus();
  }
}
