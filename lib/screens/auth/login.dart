  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'package:inventory_tsth2/controller/Auth/auth_controller.dart';
  import 'package:inventory_tsth2/styles/app_colors.dart';

  class LoginPage extends StatelessWidget {
    const LoginPage({super.key});

    @override
    Widget build(BuildContext context) {
      // Mengambil instance AuthController menggunakan GetX
      final AuthController authController = Get.find<AuthController>();

      // Menggunakan controller dari AuthController
      final TextEditingController emailController = authController.emailController;
      final TextEditingController passwordController = authController.passwordController;

      // State untuk menyembunyikan/menampilkan kata sandi
      final RxBool obscureText = true.obs;

      return Scaffold(
        backgroundColor: AppColors.whiteshade,
        resizeToAvoidBottomInset: true, // Ensure content adjusts for keyboard
        body: SafeArea(
          child: Stack(
            children: [
              // Latar belakang gradien yang lebih halus
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.blue.withOpacity(0.9),
                      AppColors.blue.withOpacity(0.4),
                    ],
                  ),
                ),
              ),

              // Elemen desain lingkaran dekoratif
              Positioned(
                top: -120,
                right: -120,
                child: Container(
                  height: 240,
                  width: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),

              Positioned(
                top: 60,
                left: -60,
                child: Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),

              // Kartu konten utama (disesuaikan agar lebih tinggi)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.12, // Disederhanakan dari 0.15
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.88, // Dikurangi sedikit
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        // Logo atau ikon di atas judul
                        Center(
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.blue.withOpacity(0.1),
                            ),
                            child: Icon(
                              Icons.inventory_2,
                              size: 40,
                              color: AppColors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Judul dan subjudul dengan tipografi yang lebih baik
                        Text(
                          "Selamat Datang",
                          style: TextStyle(
                            color: AppColors.blue,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Masuk ke Inventory TSTH2",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        // Kolom email dengan desain lebih modern
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade100,
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: "Alamat Email",
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.blue,
                                size: 22,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Kolom kata sandi dengan toggle visibilitas
                        Obx(() => Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade100,
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: passwordController,
                                obscureText: obscureText.value,
                                decoration: InputDecoration(
                                  hintText: "Kata Sandi",
                                  hintStyle: TextStyle(color: Colors.grey.shade400),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: AppColors.blue,
                                    size: 22,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscureText.value
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: AppColors.blue.withOpacity(0.7),
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      obscureText.value = !obscureText.value;
                                    },
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                ),
                                textInputAction: TextInputAction.done,
                              ),
                            )),

                        const SizedBox(height: 30),

                        // Tombol masuk dengan gradien dan animasi
                        Obx(() => ElevatedButton(
                              onPressed: authController.isLoading.value
                                  ? null
                                  : () async {
                                      await authController.login();
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 8,
                                shadowColor: AppColors.blue.withOpacity(0.4),
                                minimumSize: Size(MediaQuery.of(context).size.width, 56),
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                              ).copyWith(
                                backgroundBuilder: (context, states, child) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.blue,
                                          AppColors.blue.withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: child,
                                  );
                                },
                              ),
                              child: authController.isLoading.value
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          "Sedang Masuk...",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      "Masuk",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            )),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),

              // Header dengan logo dan efek transparan
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.12,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "TSTH2",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Overlay saat sedang memuat
              Obx(() {
                if (authController.isLoading.value) {
                  return Container(
                    color: Colors.black.withOpacity(0.4),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      );
    }
  }