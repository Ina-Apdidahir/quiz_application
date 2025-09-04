import 'package:flutter/material.dart';
import 'package:quiz_application/student/screens/student_dashboard.dart';
import 'package:quiz_application/teacher/screens/teacher_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/auth_api.dart';
import '../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<User>? _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUserData();
  }

  Future<User> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception("Not authenticated");

    final response = await AuthApi.getUserData(token);
    if (response['success']) {
      return User.fromJson(response['userData']);
    } else {
      throw Exception("Failed to load user data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }
        if (snapshot.hasData) {
          final user = snapshot.data!;
          if (user.role == 'teacher') {
            return const TeacherDashboard();
          } else {
            return const StudentDashboard();
          }
        }
        return const Scaffold(
          body: Center(child: Text("No user data")),
        );
      },
    );
  }
}
