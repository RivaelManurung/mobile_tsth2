import 'package:equatable/equatable.dart';
import 'package:inventory_tsth2/Model/user_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

// States for fetching the user profile
class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;
  const ProfileLoaded(this.user);
  @override
  List<Object> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object> get props => [message];
}

// States for actions (Update, Change Password, etc.)
class ProfileActionInProgress extends ProfileState {}

class ProfileActionSuccess extends ProfileState {
  final String message;
  const ProfileActionSuccess(this.message);
    @override
  List<Object> get props => [message];
}

class ProfileActionFailure extends ProfileState {
  final String message;
  const ProfileActionFailure(this.message);
  @override
  List<Object> get props => [message];
}