import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';
import 'package:inventory_tsth2/features/authentication/domain/repositories/auth_repositories.dart';


class LogoutUser implements Usecase<void, NoParams> {
  final AuthRepository repository;

  LogoutUser(this.repository);

  @override
  Future<Either<Failures, void>> call(NoParams params) async {
    return await repository.logout();
  }
}