import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';
import 'package:inventory_tsth2/features/authentication/domain/repositories/auth_repositories.dart';

class LogoutUserUsecase implements Usecase<Unit, NoParams> {
  final AuthRepository authRepository;

  LogoutUserUsecase(this.authRepository);

  @override
  Future<Either<Failures, Unit>> call(NoParams params) async {
    return await authRepository.logout();
  }
}