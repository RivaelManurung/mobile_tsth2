import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/Auth/auth_controller.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/screens/auth/signup.dart';
import 'package:inventory_tsth2/styles/app_colors.dart';
import 'package:inventory_tsth2/widget/custom_button.dart';
import 'package:inventory_tsth2/widget/custom_formfield.dart';
import 'package:inventory_tsth2/widget/custom_header.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the AuthController instance using GetX
    final AuthController authController = Get.find<AuthController>();

    // Use the controllers from AuthController
    final TextEditingController emailController = authController.emailController;
    final TextEditingController passwordController = authController.passwordController;

    // State for obscuring password
    final RxBool obscureText = true.obs;

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
                Get.offAll(() => const SignupPage());
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
                        controller: emailController,
                        maxLines: 1,
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      Obx(() => CustomFormField(
                            headingText: "Password",
                            maxLines: 1,
                            textInputAction: TextInputAction.done,
                            textInputType: TextInputType.text,
                            hintText: "At least 8 Characters",
                            obsecureText: obscureText.value,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureText.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.blue,
                              ),
                              onPressed: () {
                                obscureText.value = !obscureText.value;
                              },
                            ),
                            controller: passwordController,
                          )),
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
                      Obx(() => AuthButton(
                            onTap: authController.isLoading.value
                                ? () {}
                                : () async {
                                    await authController.login();
                                  },
                            text: authController.isLoading.value
                                ? 'Signing In...'
                                : 'Sign In',
                          )),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Get.offAll(() => const SignupPage());
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
            Obx(() {
              if (authController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}