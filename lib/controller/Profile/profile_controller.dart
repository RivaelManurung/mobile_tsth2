// lib/controller/Profile/profile_controller.dart
import 'package:flutter/material.dart';
import 'package:inventory_tsth2/Model/user_model.dart';
import 'package:inventory_tsth2/services/user_services.dart';

class ProfileController {
  final UserService _userService;

  ProfileController({UserService? userService})
      : _userService = userService ?? UserService();

  Future<User> getCurrentUser() async {
    return await _userService.getCurrentUser();
  }

  Future<User> updateUserProfile(User user) async {
    return await _userService.updateUser(user.id, user);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _userService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> logout() async {
    await _userService.logout();
  }

  String getInitials(String name) {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return '';
  }

  String getPhotoUrl(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return '';
    return '${_userService.baseUrl}/storage/$photoUrl';
  }
}