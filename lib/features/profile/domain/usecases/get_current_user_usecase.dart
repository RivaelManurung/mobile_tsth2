import 'package:dartz/dartz.dart';
import 'package:inventory_tsth2/Model/user_model.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';
import 'package:inventory_tsth2/features/profile/domain/repositories/profile_repository.dart';

class GetCurrentUserUsecase implements Usecase<User, NoParams> {
  final ProfileRepository repository;

  GetCurrentUserUsecase(this.repository);

  @override
  Future<Either<Failures, User>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}