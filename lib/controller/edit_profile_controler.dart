import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/user_model.dart';
import 'package:inventory_tsth2/config/api.dart'; // Pastikan path ini benar
import 'package:inventory_tsth2/services/user_services.dart'; // Pastikan path ini benar

class EditProfileController extends GetxController {
  final UserService _userService;
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController(); // Sudah ada
  String? _originalEmail;

  EditProfileController({
    required User user,
    UserService? userService,
  }) : _userService = userService ?? UserService() {
    nameController.text = user.name;
    emailController.text = user.email;
    phoneController.text = user.phoneNumber ?? '';
    addressController.text = user.address ?? ''; // Sudah ada
    _originalEmail = user.email;
  }

  String getPhotoUrl(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return '';
    if (photoUrl.startsWith('http')) return photoUrl;
    return '$baseUrl/storage/$photoUrl'; // Pastikan baseUrl terdefinisi
  }

  Future<Map<String, dynamic>> saveProfile(User user) async {
    if (!formKey.currentState!.validate()) {
      print('Form validation failed');
      throw Exception('Form validation failed');
    }

    // Membersihkan input
    final String nameInput = nameController.text.trim();
    final String? phoneInput = phoneController.text.trim().isEmpty ? null : phoneController.text.trim();
    final String? addressInput = addressController.text.trim().isEmpty ? null : addressController.text.trim();
    
    final updatedUser = User(
      id: user.id,
      name: nameInput,
      email: _originalEmail!, // Gunakan email asli untuk update user
      phoneNumber: phoneInput,
      address: addressInput,
      photoUrl: user.photoUrl,
      roles: user.roles,
      createdAt: user.createdAt,
    );

    try {
      String? emailUpdateMessage;
      // Handle update email secara terpisah jika berubah
      if (emailController.text.trim() != _originalEmail) {
        emailUpdateMessage = await _userService.updateEmail(
          emailController.text.trim(),
        );
      }

      // Update field non-email
      final savedUser = await _userService.updateUser(user.id, updatedUser);

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
      final updatedUser = await _userService.updateAvatar(base64Image);
      return updatedUser;
    } catch (e) {
      print('Error updating avatar: $e');
      rethrow;
    }
  }

  Future<User> deleteAvatar() async {
    try {
      final updatedUser = await _userService.deleteAvatar();
      return updatedUser;
    } catch (e) {
      print('Error deleting avatar: $e');
      rethrow;
    }
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nama tidak boleh kosong';
    if (value.trim().length > 255) return 'Nama maksimal 255 karakter';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email tidak boleh kosong';
    if (!GetUtils.isEmail(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Telepon opsional

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Nomor telepon harus 10-15 digit';
    }
    if (!GetUtils.isPhoneNumber(value)) {
        // GetUtils.isPhoneNumber is quite basic, so a custom regex might be better
        // but it's a good starting point.
        return 'Format nomor telepon tidak valid';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value != null && value.trim().length > 500) {
      return 'Alamat maksimal 500 karakter';
    }
    return null; // Alamat opsional
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
