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
  String? _originalEmail;

  EditProfileController({
    required User user,
    UserService? userService,
  }) : _userService = userService ?? UserService() {
    nameController.text = user.name;
    emailController.text = user.email;
    phoneController.text = user.phoneNumber ?? '';
    addressController.text = user.address ?? '';
    _originalEmail = user.email;
  }

  String getPhotoUrl(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return '';
    if (photoUrl.startsWith('http')) return photoUrl;
    return '$baseUrl/storage/$photoUrl';
  }

  Future<Map<String, dynamic>> saveProfile(User user) async {
    if (!formKey.currentState!.validate()) {
      print('Form validation failed');
      throw Exception('Form validation failed');
    }

    // Print input values for debugging
    print('--- Profile Input Values ---');
    print('Name: ${nameController.text}');
    print('Email: ${emailController.text}');
    print(
        'Phone: ${phoneController.text.isEmpty ? "Not provided" : phoneController.text}');
    print(
        'Address: ${addressController.text.isEmpty ? "Not provided" : addressController.text}');
    print('User ID: ${user.id}');
    print('Photo URL: ${user.photoUrl ?? "Not provided"}');
    print('---------------------------');

    // Clean and validate phone input
    String? phoneInput;
    if (phoneController.text.isNotEmpty) {
      phoneInput = phoneController.text.trim();

      // Validate phone length
      final digitsOnly = phoneInput.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.length > 15) {
        print('Error: Phone number exceeds 15 digits: $phoneInput');
        throw Exception('Phone number exceeds 15 characters');
      }
    }

    // Create the updated user object for non-email fields
    final updatedUser = User(
      id: user.id,
      name: nameController.text.trim(),
      email: _originalEmail!, // Keep original email for updateUser
      phoneNumber: phoneInput,
      address:
          addressController.text.isEmpty ? null : addressController.text.trim(),
      photoUrl: user.photoUrl,
      roles: user.roles,
      createdAt: user.createdAt,
    );

    try {
      String? emailUpdateMessage;
      // Handle email update separately if changed
      if (emailController.text.trim() != _originalEmail) {
        emailUpdateMessage = await _userService.updateEmail(
          emailController.text.trim(),
        );
      }

      // Log the payload
      print('--- Sending User Payload (non-email) ---');
      print(jsonEncode(updatedUser.toJson()));
      print('---------------------------');

      // Update non-email fields
      final savedUser = await _userService.updateUser(user.id, updatedUser);

      // Validate returned phone number
      if (phoneInput != null && savedUser.phoneNumber != phoneInput) {
        print(
            'Warning: Returned phone number (${savedUser.phoneNumber}) does not match input ($phoneInput)');
        throw Exception(
            'Phone number update failed: server returned ${savedUser.phoneNumber} instead of $phoneInput');
      }

      print('Saved user phoneNumber: ${savedUser.phoneNumber}');
      print('Saved user photoUrl: ${savedUser.photoUrl}');
      return {
        'user': savedUser,
        'emailMessage': emailUpdateMessage,
      };
    } catch (e) {
      print('Error saving profile: $e');
      rethrow;
    }
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
    if (value == null || value.trim().isEmpty) return 'Please enter your name';
    if (value.trim().length > 255) return 'Name must not exceed 255 characters';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    print('Input phone number: $value');
    if (value != null && value.trim().isNotEmpty) {
      value = value.trim();
      print('Phone length: ${value.length}');

      // Remove any non-digit characters for validation
      final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
      print('Digits only: $digitsOnly');
      print('Digits length: ${digitsOnly.length}');

      // Validate length (10-15 digits)
      if (digitsOnly.length < 10 || digitsOnly.length > 15) {
        print('Validation error: Phone number must be 10-15 digits');
        return 'Phone number must be 10-15 digits';
      }

      // For Indonesian numbers, allow formats like:
      // 08xxxxxxxxxx (starts with 08)
      // 62xxxxxxxxxx (starts with 62)
      // +62xxxxxxxxx (starts with +62)
      if (value.startsWith('+')) {
        // Remove + and validate
        final withoutPlus = value.substring(1);
        if (!RegExp(r'^\d+$').hasMatch(withoutPlus)) {
          print('Validation error: Invalid characters in phone number');
          return 'Please enter a valid phone number';
        }
      } else {
        // Must be all digits
        if (!RegExp(r'^\d+$').hasMatch(value)) {
          print('Validation error: Please enter digits only');
          return 'Please enter a valid phone number (digits only)';
        }
      }
    }
    print('Phone validation passed');
    return null;
  }

  String? validateAddress(String? value) {
    if (value != null && value.trim().isNotEmpty && value.trim().length > 500) {
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