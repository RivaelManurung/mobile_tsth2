import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoginUserEvent extends UserEvent {
  final String name;
  final String password;

  const LoginUserEvent({required this.name, required this.password});

  @override
  List<Object> get props => [name, password];
}

class UserLogoutEvent extends UserEvent {}