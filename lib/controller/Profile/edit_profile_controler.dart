// lib/controller/Profile/edit_profile_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:inventory_tsth2/Model/user_model.dart';
import 'package:inventory_tsth2/services/user_services.dart';

class EditProfileController {
  final UserService _userService;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  EditProfileController({
    UserService? userService,
    required User user,
  }) : _userService = userService ?? UserService() {
    nameController.text = user.name;
    emailController.text = user.email;
    phoneController.text = user.phone ?? '';
    addressController.text = user.address ?? '';
  }

  String getPhotoUrl(String photoUrl) {
    return '${_userService.baseUrl}/storage/$photoUrl';
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
  }

  Future<User> saveProfile(User user, {File? image}) async {
    if (!formKey.currentState!.validate()) {
      throw Exception('Form validation failed');
    }

    final updatedUser = User(
      id: user.id,
      name: nameController.text,
      email: emailController.text,
      phone: phoneController.text.isEmpty ? null : phoneController.text,
      address: addressController.text.isEmpty ? null : addressController.text,
      photoUrl: user.photoUrl,
      roles: user.roles,
      createdAt: user.createdAt,
    );

    return await _userService.updateUser(user.id, updatedUser, image: image);
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length > 255) {
      return 'Name must not exceed 255 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length > 15) {
        return 'Phone number must not exceed 15 characters';
      }
      if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
        return 'Please enter a valid phone number';
      }
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value != null && value.isNotEmpty && value.length > 500) {
      return 'Address must not exceed 500 characters';
    }
    return null;
  }
}