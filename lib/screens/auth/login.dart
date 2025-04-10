// login_page.dart
import 'package:flutter/material.dart';
import 'package:inventory_tsth2/controller/Auth/auth_controller.dart';
import 'package:inventory_tsth2/screens/auth/signup.dart';
import 'package:inventory_tsth2/screens/dahsboard/dashboard.dart';
import 'package:inventory_tsth2/styles/app_colors.dart';
import 'package:inventory_tsth2/widget/custom_button.dart';
import 'package:inventory_tsth2/widget/custom_formfield.dart';
import 'package:inventory_tsth2/widget/custom_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = AuthController();
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        final isValid = await _authController.verifyToken(token);
        if (isValid && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        } else {
          await prefs.remove('auth_token');
          await prefs.remove('user');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please login again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Email and password cannot be empty");
      return;
    }

    if (!email.contains('@')) {
      _showError("Invalid email format");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authController.login(email, password);

      if (result['success'] && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      } else {
        _showError(result['message']);
      }
    } catch (e) {
      _showError("An error occurred. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: AppColors.blue,
            ),
            CustomHeader(
              text: 'Log In Inventory TSTH2',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupPage()),
                );
              },
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.08,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.9,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: AppColors.whiteshade,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width * 0.8,
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.09,
                        ),
                        child: Image.asset("assets/images/login.png"),
                      ),
                      const SizedBox(height: 24),
                      CustomFormField(
                        headingText: "Email",
                        hintText: "Email",
                        obsecureText: false,
                        suffixIcon: const SizedBox(),
                        controller: _emailController,
                        maxLines: 1,
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      CustomFormField(
                        headingText: "Password",
                        maxLines: 1,
                        textInputAction: TextInputAction.done,
                        textInputType: TextInputType.text,
                        hintText: "At least 8 Characters",
                        obsecureText: _obscureText,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.blue,
                          ),
                          onPressed: () {
                            setState(() => _obscureText = !_obscureText);
                          },
                        ),
                        controller: _passwordController,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24,
                            ),
                            child: InkWell(
                              onTap: () {
                                // Add forgot password functionality
                              },
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: AppColors.blue.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      AuthButton(
                        onTap: _isLoading ? () {} : _login,
                        text: _isLoading ? 'Signing In...' : 'Sign In',
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignupPage()),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: Colors.grey.shade600),
                              children: [
                                TextSpan(
                                  text: "Sign Up",
                                  style: TextStyle(
                                    color: AppColors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
