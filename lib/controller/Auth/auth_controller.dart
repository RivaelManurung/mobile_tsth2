// auth_controller.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  final String baseUrl = 'http://127.0.0.1:8000'; // Adjust to your API base URL

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', responseData['data']['token']);
        await prefs.setString('user', jsonEncode(responseData['data']['user']));
        
        return {
          'success': true,
          'message': responseData['message'],
          'token': responseData['data']['token'],
        };
      }
      return {
        'success': false,
        'message': responseData['message'] ?? 'Login failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error connecting to server: $e',
      };
    }
  }

  Future<bool> verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/api/auth/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
      } catch (e) {
        print('Logout error: $e');
      }
    }
    await prefs.clear();
  }
}
