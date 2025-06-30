import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/services/auth_service.dart';
import 'package:inventory_tsth2/Model/user_model.dart'; // Import User model

class AuthController extends GetxController {
  final AuthService _authService;

  // Reactive state variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<Map<String, dynamic>?> user = Rx<Map<String, dynamic>?>(null);

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  AuthController({AuthService? authService})
      : _authService = authService ?? AuthService();

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final userData = await _authService.getUser();
      if (userData != null) {
        // Convert to User object and then to Map
        final userObj = User.fromJson(userData);
        user.value = userObj.toMap();
      } else {
        user.value = null;
      }
    } catch (e) {
      print('Error loading user: $e');
      user.value = null;
    }
  }

  Future<void> login() async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _authService.login(
        nameController.text.trim(),
        passwordController.text.trim(),
      );

      if (response['success'] == true) {
        final userObj = User.fromJson(response['user']);
        user.value = userObj.toMap(); // Update user with Map including 'avatar'
        Get.offAllNamed(RoutesName.dashboard);
      } else {
        errorMessage(response['message']);
        Get.snackbar('Error', response['message'],
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  // New method to update user data
  void updateUser(User updatedUser) {
    user.value = updatedUser.toMap(); // Update the observable user
  }

  Future<bool> verifyToken(String token) async {
    return await _authService.verifyToken(token);
  }

  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      user.value = null;
      clearForm();
      Get.offAllNamed(RoutesName.login);
    } catch (e) {
      Get.snackbar('Error', 'Logout failed: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void clearForm() {
    nameController.clear();
    passwordController.clear();
    errorMessage('');
  }

  @override
  void onClose() {
    nameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
