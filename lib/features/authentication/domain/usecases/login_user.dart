import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:inventory_tsth2/core/error/failures.dart';
import 'package:inventory_tsth2/core/usecase/usecase.dart';

import 'package:inventory_tsth2/features/authentication/domain/entities/user.dart';
import 'package:inventory_tsth2/features/authentication/domain/repositories/auth_repositories.dart';

class LoginUser implements Usecase<User, LoginParams> {
  final AuthRepository repository;

  LoginUser(this.repository);

  @override
  Future<Either<Failures, User>> call(LoginParams params) async {
    return await repository.login(params.name, params.password);
  }
}

class LoginParams extends Equatable {
  final String name;
  final String password;

  const LoginParams({required this.name, required this.password});

  @override
  List<Object> get props => [name, password];
}