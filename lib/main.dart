import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_tsth2/controller/profile_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory_tsth2/controller/Auth/auth_controller.dart';
import 'package:inventory_tsth2/core/routes/routes.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/services/auth_service.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import for locale data

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for the 'id_ID' locale
  await initializeDateFormatting('id_ID', null);

  // Initialize SharedPreferences
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  // Register SharedPreferences with GetX
  Get.put<SharedPreferences>(sharedPreferences, permanent: true);

  // Initialize AuthService and AuthController
  Get.put(AuthService(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(ProfileController(), permanent: true); // Register ProfileController

  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return FutureBuilder<bool>(
      future: authController.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final bool isLoggedIn = snapshot.data ?? false;

        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: isLoggedIn ? RoutesName.main : RoutesName.onboarding,
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
      },
    );
  }
}
