import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:inventory_tsth2/features/authentication/presentation/bloc/user_bloc.dart';
import 'package:inventory_tsth2/features/authentication/presentation/bloc/user_event.dart';
import 'package:inventory_tsth2/features/authentication/presentation/bloc/user_state.dart';

// Assuming you have a styles/app_colors.dart
// import 'package:inventory_tsth2/styles/app_colors.dart';
// Assuming you have a routes/routes_name.dart
// import 'package:inventory_tsth2/routes/routes_name.dart';

// Placeholder for AppColors
class AppColors {
  static const Color blue = Colors.blue;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _onLoginButtonPressed() {
    context.read<UserBloc>().add(
          LoginUserEvent(
            name: _nameController.text.trim(),
            password: _passwordController.text.trim(),
          ),
        );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color neumorphicColor = Colors.grey.shade100;
    final Color shadowColor = Colors.grey.shade400;

    return Scaffold(
      backgroundColor: neumorphicColor,
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserLoggedIn) {
            // Navigate to Dashboard
            // Navigator.of(context).pushReplacementNamed(RoutesName.dashboard);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Welcome ${state.user.name}!')),
            );
          } else if (state is UserLoggedInError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  backgroundColor: Colors.red, content: Text(state.message)),
            );
          }
        },
        child: SafeArea(
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
                        fontSize: 16, color: Colors.grey.shade600),
                  ).animate().fade(duration: 500.ms, delay: 200.ms),
                  const SizedBox(height: 60),

                  // Name Text Field
                  _buildNeumorphicTextField(
                    controller: _nameController,
                    hintText: "Nama Pengguna",
                    icon: Icons.person_outline,
                    neumorphicColor: neumorphicColor,
                    shadowColor: shadowColor,
                  )
                      .animate()
                      .fade(duration: 500.ms, delay: 400.ms)
                      .slideX(begin: -0.5),
                  const SizedBox(height: 25),

                  // Password Text Field
                  _buildNeumorphicTextField(
                    controller: _passwordController,
                    hintText: "Kata Sandi",
                    icon: Icons.lock_outline,
                    obscureText: !_isPasswordVisible,
                    neumorphicColor: neumorphicColor,
                    shadowColor: shadowColor,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey.shade500,
                      ),
                      onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  )
                      .animate()
                      .fade(duration: 500.ms, delay: 600.ms)
                      .slideX(begin: -0.5),

                  const SizedBox(height: 40),

                  // Login Button
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      final isLoading = state is UserLoggingIn;
                      return _buildLoginButton(
                        context,
                        isLoading: isLoading,
                        onTap: isLoading ? null : _onLoginButtonPressed,
                      );
                    },
                  )
                      .animate()
                      .fade(duration: 500.ms, delay: 800.ms)
                      .slideY(begin: 0.5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
              BoxShadow(
                  color: shadowColor,
                  offset: const Offset(4, 4),
                  blurRadius: 15,
                  spreadRadius: 1),
              const BoxShadow(
                  color: Colors.white,
                  offset: Offset(-4, -4),
                  blurRadius: 15,
                  spreadRadius: 1),
            ]),
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
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16))));
  }

  Widget _buildLoginButton(BuildContext context,
      {required bool isLoading, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
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
                    Text("Memproses...",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                )
              : Text("Masuk",
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
        ),
      ),
    );
  }
}
