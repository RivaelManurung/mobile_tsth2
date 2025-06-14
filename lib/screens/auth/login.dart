import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:inventory_tsth2/controller/Auth/auth_controller.dart';
import 'package:inventory_tsth2/styles/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final TextEditingController nameController =
        authController.nameController; // Changed from emailController
    final TextEditingController passwordController =
        authController.passwordController;
    final RxBool obscureText = true.obs;

    final Color neumorphicColor = Colors.grey.shade100;
    final Color shadowColor = Colors.grey.shade400;

    return Scaffold(
      backgroundColor: neumorphicColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  "Selamat Datang Kembali",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue,
                  ),
                ).animate().fade(duration: 500.ms).slideY(begin: -0.3),

                const SizedBox(height: 10),

                Text(
                  "Masuk untuk melanjutkan ke Inventory TSTH2",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ).animate().fade(duration: 500.ms, delay: 200.ms),

                const SizedBox(height: 60),

                // Name Text Field (Changed from Email)
                _buildNeumorphicTextField(
                  controller: nameController,
                  hintText: "Nama Pengguna", // Changed from "Alamat Email"
                  icon:
                      Icons.person_outline, // Changed from Icons.email_outlined
                  neumorphicColor: neumorphicColor,
                  shadowColor: shadowColor,
                )
                    .animate()
                    .fade(duration: 500.ms, delay: 400.ms)
                    .slideX(begin: -0.5),

                const SizedBox(height: 25),

                // Password Text Field
                Obx(() => _buildNeumorphicTextField(
                          controller: passwordController,
                          hintText: "Kata Sandi",
                          icon: Icons.lock_outline,
                          obscureText: obscureText.value,
                          neumorphicColor: neumorphicColor,
                          shadowColor: shadowColor,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureText.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey.shade500,
                            ),
                            onPressed: () =>
                                obscureText.value = !obscureText.value,
                          ),
                        ))
                    .animate()
                    .fade(duration: 500.ms, delay: 600.ms)
                    .slideX(begin: -0.5),

                const SizedBox(height: 40),

                // Login Button
                Obx(() => _buildLoginButton(
                        context, authController, neumorphicColor, shadowColor))
                    .animate()
                    .fade(duration: 500.ms, delay: 800.ms)
                    .slideY(begin: 0.5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget terpisah untuk Neumorphic TextField agar lebih rapi
  Widget _buildNeumorphicTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color neumorphicColor,
    required Color shadowColor,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: neumorphicColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          // Bayangan gelap di bawah kanan
          BoxShadow(
            color: shadowColor,
            offset: const Offset(4, 4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          // Bayangan terang di atas kiri
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
          prefixIcon: Icon(icon, color: AppColors.blue),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        ),
      ),
    );
  }

  // Widget terpisah untuk tombol login
  Widget _buildLoginButton(BuildContext context, AuthController authController,
      Color neumorphicColor, Color shadowColor) {
    bool isLoading = authController.isLoading.value;

    return GestureDetector(
      onTap: isLoading ? null : () async => await authController.login(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading
                ? [Colors.grey.shade400, Colors.grey.shade500]
                : [AppColors.blue, AppColors.blue.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.blue.withOpacity(0.4),
                    offset: const Offset(0, 10),
                    blurRadius: 20,
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 3),
                    ),
                    SizedBox(width: 16),
                    Text(
                      "Memproses...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Text(
                  "Masuk",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
        ),
      ),
    );
  }
}
