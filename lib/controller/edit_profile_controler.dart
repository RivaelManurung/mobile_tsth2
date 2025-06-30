// Mengelola pengeditan profil pengguna dan pembaruan avatar dalam aplikasi Flutter menggunakan GetX.
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/user_model.dart';
import 'package:inventory_tsth2/config/api.dart'; // Berisi konfigurasi API seperti baseUrl
import 'package:inventory_tsth2/services/user_services.dart'; // Layanan untuk operasi API pengguna

class EditProfileController extends GetxController {
  final UserService _userService;
  final formKey = GlobalKey<FormState>(); // Kunci untuk validasi form
  final TextEditingController nameController =
      TextEditingController(); // Input nama pengguna
  final TextEditingController emailController =
      TextEditingController(); // Input email pengguna
  final TextEditingController phoneController =
      TextEditingController(); // Input nomor telepon
  String? _originalEmail; // Menyimpan email asli untuk perbandingan

  // Konstruktor, inisialisasi controller dengan data pengguna
  EditProfileController({
    required User user,
    UserService? userService,
  }) : _userService = userService ?? UserService() {
    nameController.text = user.name;
    emailController.text = user.email;
    phoneController.text = user.phoneNumber ?? '';
    _originalEmail = user.email;
  }

  // Mengembalikan URL lengkap untuk foto profil
  String getPhotoUrl(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return '';
    if (photoUrl.startsWith('http')) return photoUrl;
    return '$baseUrl/storage/$photoUrl'; // Menambahkan baseUrl ke path foto
  }

  // Menyimpan perubahan profil pengguna
  Future<Map<String, dynamic>> saveProfile(User user) async {
    if (!formKey.currentState!.validate()) {
      print('Validasi form gagal');
      throw Exception('Validasi form gagal');
    }

    // Membersihkan input
    final String nameInput = nameController.text.trim();
    final String? phoneInput = phoneController.text.trim().isEmpty
        ? null
        : phoneController.text.trim();

    // Membuat objek User baru dengan data yang diperbarui
    final updatedUser = User(
      id: user.id,
      name: nameInput,
      email: _originalEmail!, // Menggunakan email asli untuk pembaruan
      phoneNumber: phoneInput,
      photoUrl: user.photoUrl,
      roles: user.roles,
      createdAt: user.createdAt,
    );

    try {
      String? emailUpdateMessage;
      // Memperbarui email secara terpisah jika berubah
      if (emailController.text.trim() != _originalEmail) {
        emailUpdateMessage = await _userService.updateEmail(
          emailController.text.trim(),
        );
      }

      // Memperbarui field non-email
      final savedUser = await _userService.updateUser(user.id, updatedUser);

      return {
        'user': savedUser,
        'emailMessage': emailUpdateMessage,
      };
    } catch (e) {
      print('Gagal menyimpan profil: $e');
      rethrow;
    }
  }

  // Memperbarui avatar pengguna
  Future<User> updateAvatar(File image) async {
    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes); // Mengonversi gambar ke base64
      final updatedUser = await _userService.updateAvatar(base64Image);
      return updatedUser;
    } catch (e) {
      print('Gagal memperbarui avatar: $e');
      rethrow;
    }
  }

  // Validasi nama
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nama tidak boleh kosong';
    if (value.trim().length > 255) return 'Nama maksimal 255 karakter';
    return null;
  }

  // Validasi email
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Email tidak boleh kosong';
    if (!GetUtils.isEmail(value.trim())) return 'Format email tidak valid';
    return null;
  }

  // Validasi nomor telepon
  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Telepon opsional
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Nomor telepon harus 10-15 digit';
    }
    if (!GetUtils.isPhoneNumber(value)) {
      return 'Format nomor telepon tidak valid';
    }
    return null;
  }

  @override
  void dispose() {
    // Membersihkan controller untuk mencegah kebocoran memori
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
