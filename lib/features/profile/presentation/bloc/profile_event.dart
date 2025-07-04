import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:inventory_tsth2/Model/user_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object> get props => [];
}

class GetCurrentUserEvent extends ProfileEvent {}

class UpdateProfileDetailsEvent extends ProfileEvent {
  final User user;
  const UpdateProfileDetailsEvent(this.user);
  @override
  List<Object> get props => [user];
}

class UpdateProfileAvatarEvent extends ProfileEvent {
  final File imageFile;
  const UpdateProfileAvatarEvent(this.imageFile);
  @override
  List<Object> get props => [imageFile];
}

class ChangePasswordEvent extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  const ChangePasswordEvent({required this.currentPassword, required this.newPassword});
   @override
  List<Object> get props => [currentPassword, newPassword];
}