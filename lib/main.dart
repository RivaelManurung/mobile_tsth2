import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/core/routes/routes.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:shared_preferences/shared_preferences.dart';

// AuthController to manage authentication state
class AuthController extends GetxController {
  final RxBool isLoggedIn = false.obs;

  Future<void> checkLoginStatus() async {
    final prefs = Get.find<SharedPreferences>();
    final token = prefs.getString('auth_token');
    isLoggedIn.value = token != null;
  }
}

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Register SharedPreferences with GetX
  Get.put<SharedPreferences>(prefs, permanent: true);

  // Initialize AuthController and check login status
  final authController = Get.put(AuthController(), permanent: true);
  await authController.checkLoginStatus();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // Set initial route based on login status
      initialRoute: authController.isLoggedIn.value ? RoutesName.main : RoutesName.login,
      onGenerateRoute: Routes.onGenerateRoute,
      theme: ThemeData(
        canvasColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4E6AFF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFF),
      ),
    );
  }
}