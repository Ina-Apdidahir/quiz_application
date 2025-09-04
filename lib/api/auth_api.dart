// api/auth_api.dart
// Path: lib/api/auth_api.dart

// lib/api/auth_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart'; // Make sure you have your apiUrl here

class AuthApi {
  // Handles user registration.
  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$apiUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    return json.decode(response.body);
  }

  // Handles user login.
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    return json.decode(response.body);
  }

  // Fetches user data using an auth token.
  static Future<Map<String, dynamic>> getUserData(String token) async {
    final response = await http.get(
      Uri.parse('$apiUrl/auth/user-data'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return json.decode(response.body);
  }

  // UPDATED: Now includes the bio field.
  static Future<Map<String, dynamic>> updateProfile(
      {required String userId,
      required String token,
      required String name,
      required String email,
      String? bio}) async {
    final response = await http.put(
      Uri.parse('$apiUrl/auth/update-profile/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': name,
        'email': email,
        'bio': bio,
      }),
    );
    return json.decode(response.body);
  }

  // NEW: Sends a password reset OTP to the user's email.
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$apiUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );
    return json.decode(response.body);
  }

  // NEW: Verifies the OTP sent to the user.
  static Future<Map<String, dynamic>> verifyResetOTP(
      String email, String otp) async {
    final response = await http.post(
      Uri.parse('$apiUrl/auth/verify-reset-otp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'otp': otp}),
    );
    return json.decode(response.body);
  }

  // NEW: Sets a new password using a reset token.
  static Future<Map<String, dynamic>> setNewPassword(
      String email, String newPassword, String resetToken) async {
    final response = await http.post(
      Uri.parse('$apiUrl/auth/set-new-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'newPassword': newPassword,
        'resetToken': resetToken,
      }),
    );
    return json.decode(response.body);
  }
}