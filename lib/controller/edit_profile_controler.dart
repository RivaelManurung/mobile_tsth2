import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/user_model.dart';
import 'package:inventory_tsth2/config/api.dart';
import 'package:inventory_tsth2/services/user_services.dart';

class EditProfileController extends GetxController {
  final UserService _userService;
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  EditProfileController({
    required User user,
    UserService? userService,
  }) : _userService = userService ?? UserService() {
    nameController.text = user.name;
    emailController.text = user.email ?? '';
    phoneController.text = user.phoneNumber ?? '';
    addressController.text = user.address ?? '';
  }

  String getPhotoUrl(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return '';
    if (photoUrl.startsWith('http')) return photoUrl;
    return '$baseUrl/storage/$photoUrl';
  }

  Future<User> saveProfile(User user) async {
    if (!formKey.currentState!.validate()) {
      print('Form validation failed');
      throw Exception('Form validation failed');
    }

    // Print input values
    print('--- Profile Input Values ---');
    print('Name: ${nameController.text}');
    print('Email: ${emailController.text}');
    print('Phone: ${phoneController.text.isEmpty ? "Not provided" : phoneController.text}');
    print('Address: ${addressController.text.isEmpty ? "Not provided" : addressController.text}');
    print('User ID: ${user.id}');
    print('Roles: ${user.roles}');
    print('Created At: ${user.createdAt}');
    print('Photo URL: ${user.photoUrl ?? "Not provided"}');
    print('---------------------------');

    final phoneInput = phoneController.text.isEmpty ? null : phoneController.text;
    if (phoneInput != null && phoneInput.length > 15) {
      print('Error: Phone number exceeds 15 characters: $phoneInput');
      throw Exception('Phone number exceeds 15 characters');
    }

    final updatedUser = User(
      id: user.id,
      name: nameController.text,
      email: emailController.text,
      phoneNumber: phoneInput,
      address: addressController.text.isEmpty ? null : addressController.text,
      photoUrl: user.photoUrl,
      roles: user.roles,
      createdAt: user.createdAt,
    );

    // Log the payload
    print('--- Sending User Payload ---');
    print(jsonEncode(updatedUser.toJson()));
    print('---------------------------');

    final savedUser = await _userService.updateUser(user.id, updatedUser);

    // Validate returned phone number
    if (savedUser.phoneNumber != phoneInput) {
      print('Error: Returned phone number (${savedUser.phoneNumber}) does not match input ($phoneInput)');
      throw Exception('Phone number mismatch after save');
    }

    print('Saved user phoneNumber: ${savedUser.phoneNumber}');
    print('Saved user photoUrl: ${savedUser.photoUrl}');
    return savedUser;
  }

  Future<User> updateAvatar(File image) async {
    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      print('Generated Base64: $base64Image');
      final updatedUser = await _userService.updateAvatar(base64Image);
      print('Updated avatar photoUrl: ${updatedUser.photoUrl}');
      return updatedUser;
    } catch (e) {
      print('Error updating avatar: $e');
      rethrow;
    }
  }

  Future<User> deleteAvatar() async {
    try {
      final updatedUser = await _userService.deleteAvatar();
      print('Deleted avatar photoUrl: ${updatedUser.photoUrl}');
      return updatedUser;
    } catch (e) {
      print('Error deleting avatar: $e');
      rethrow;
    }
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your name';
    if (value.length > 255) return 'Name must not exceed 255 characters';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
  print('Input phone number: $value');
  if (value != null && value.isNotEmpty) {
    value = value.trim();
    print('Phone length: ${value.length}');
    // Enforce 10-15 digits, no leading '+' for local numbers
    final regex = RegExp(r'^\d{10,15}$');
    print('Regex check: ${regex.hasMatch(value)}');
    if (value.length < 10 || value.length > 15) {
      print('Validation error: Phone number must be 10-15 digits');
      return 'Phone number must be 10-15 digits';
    }
    if (!regex.hasMatch(value)) {
      print('Validation error: Please enter a valid phone number (digits only)');
      return 'Please enter a valid phone number (digits only)';
    }
  }
  print('Phone validation passed');
  return null;
}

  String? validateAddress(String? value) {
    if (value != null && value.isNotEmpty && value.length > 500) {
      return 'Address must not exceed 500 characters';
    }
    return null;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }
}