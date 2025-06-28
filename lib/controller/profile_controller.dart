import 'package:flutter/material.dart';
import 'package:inventory_tsth2/Model/user_model.dart';
import 'package:inventory_tsth2/config/api.dart';
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

  Future<User> updateAvatar(String base64Image) async {
    return await _userService.updateAvatar(base64Image);
  }

  Future<User> deleteAvatar() async {
    return await _userService.deleteAvatar();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _userService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      // Re-throw the exception to be handled by the caller
      rethrow;
    }
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

  String getPhotoUrl(String photoUrl) {
    if (photoUrl.startsWith('http')) return photoUrl;
    return '$baseUrl/storage/$photoUrl';
  }
}