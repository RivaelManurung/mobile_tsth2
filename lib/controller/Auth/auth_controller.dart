import 'package:get/get.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  final AuthService _authService;

  // Reactive state variables
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<Map<String, dynamic>?> user = Rx<Map<String, dynamic>?>(null);

  // Form controllers
  final TextEditingController nameController = TextEditingController(); // Changed from emailController
  final TextEditingController passwordController = TextEditingController();

  AuthController({AuthService? authService})
      : _authService = authService ?? AuthService();

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  Future<void> _loadUser() async {
    user.value = await _authService.getUser();
  }

  Future<void> login() async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _authService.login(
        nameController.text.trim(), // Changed from emailController
        passwordController.text.trim(),
      );

      if (response['success'] == true) {
        user.value = response['user'];
        Get.offAllNamed(RoutesName.dashboard);
      } else {
        errorMessage(response['message']);
        Get.snackbar('Error', response['message'], snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
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
      Get.snackbar('Error', 'Logout failed: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void clearForm() {
    nameController.clear(); // Changed from emailController
    passwordController.clear();
    errorMessage('');
  }

  @override
  void onClose() {
    nameController.dispose(); // Changed from emailController
    passwordController.dispose();
    super.onClose();
  }
}