
// lib/api/analysis_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/analysis_model.dart';
import '../utils/constants.dart'; // for apiUrl

class AnalysisApi {
  static Future<Analysis?> fetchTeacherAnalysis() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return null;

    try {
      final testsRes = await http.get(
        Uri.parse('$apiUrl/analysis/all-my-tests'),
        headers: {"Authorization": "Bearer $token"},
      );
      final studentsRes = await http.get(
        Uri.parse('$apiUrl/analysis/all-my-students'),
        headers: {"Authorization": "Bearer $token"},
      );
      final roomsRes = await http.get(
        Uri.parse('$apiUrl/analysis/my-total-rooms'),
        headers: {"Authorization": "Bearer $token"},
      );

      final allTests = json.decode(testsRes.body)['allTests'] ?? 0;
      final totalStudents = json.decode(studentsRes.body)['totalStudentCount'] ?? 0;
      final totalRooms = json.decode(roomsRes.body)['totalRooms'] ?? 0;

      return Analysis(
        allTests: allTests,
        totalStudents: totalStudents,
        totalRooms: totalRooms,
      );
    } catch (e) {
      return null;
    }
  }
}
