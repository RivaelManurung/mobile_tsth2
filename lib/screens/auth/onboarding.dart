import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/screens/auth/login.dart';
import 'package:inventory_tsth2/styles/app_colors.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller for managing onboarding state
    final OnboardingController controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: AppColors.whiteshade,
      body: SafeArea(
        child: Stack(
          children: [
            // Gradient background
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

            // Decorative circles
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

            // Main content card
            Positioned(
              top: MediaQuery.of(context).size.height * 0.12,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.88,
                padding: const EdgeInsets.symmetric(horizontal: 28),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: controller.pageController,
                        itemCount: controller.onboardingPages.length,
                        onPageChanged: controller.onPageChanged,
                        itemBuilder: (context, index) {
                          final page = controller.onboardingPages[index];
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Image placeholder
                              Container(
                                height: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.blue.withOpacity(0.1),
                                ),
                                child: Icon(
                                  page['icon'] as IconData,
                                  size: 100,
                                  color: AppColors.blue,
                                ),
                              ),
                              const SizedBox(height: 30),
                              // Title
                              Text(
                                page['title'] as String,
                                style: TextStyle(
                                  color: AppColors.blue,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 15),
                              // Description
                              Text(
                                page['description'] as String,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    // Navigation dots
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            controller.onboardingPages.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: controller.currentPage.value == index
                                  ? 12
                                  : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: controller.currentPage.value == index
                                    ? AppColors.blue
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(height: 30),
                    // Skip and Next/Get Started buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Get.off(() => const LoginPage());
                          },
                          child: Text(
                            "Skip",
                            style: TextStyle(
                              color: AppColors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Obx(() => ElevatedButton(
                              onPressed: () {
                                if (controller.currentPage.value ==
                                    controller.onboardingPages.length - 1) {
                                  Get.off(() => const LoginPage());
                                } else {
                                  controller.nextPage();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor: AppColors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                controller.currentPage.value ==
                                        controller.onboardingPages.length - 1
                                    ? "Get Started"
                                    : "Next",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Header
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
          ],
        ),
      ),
    );
  }
}

class OnboardingController extends GetxController {
  final pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<Map<String, dynamic>> onboardingPages = [
    {
      'icon': Icons.inventory_2,
      'title': 'Welcome to Inventory TSTH2',
      'description':
          'Manage your warehouse efficiently with real-time inventory tracking and seamless operations.',
    },
    {
      'icon': Icons.warehouse,
      'title': 'Track Inventory Easily',
      'description':
          'Monitor stock levels, update quantities, and get insights into your warehouse inventory.',
    },
    {
      'icon': Icons.bar_chart,
      'title': 'Real-Time Updates',
      'description':
          'Stay informed with real-time data and analytics to make smarter decisions for your warehouse.',
    },
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
