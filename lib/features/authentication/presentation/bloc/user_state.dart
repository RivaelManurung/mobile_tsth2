import 'package:equatable/equatable.dart';
import 'package:inventory_tsth2/features/authentication/domain/entities/user.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoggingIn extends UserState {}

class UserLoggedIn extends UserState {
  final User user;
  const UserLoggedIn({required this.user});
  @override
  List<Object> get props => [user];
}

class UserLoggedInError extends UserState {
  final String message;
  const UserLoggedInError(this.message);
  @override
  List<Object> get props => [message];
}

class UserLogoutLoading extends UserState {}

class UserLoggedOut extends UserState {
   final String message;
  const UserLoggedOut(this.message);
  @override
  List<Object> get props => [message];
}

class UserLoggedOutError extends UserState {
   final String message;
  const UserLoggedOutError(this.message);
  @override
  List<Object> get props => [message];
}