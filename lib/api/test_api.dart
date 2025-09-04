import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/test_model.dart';

class TestApi {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ==================== TEST API CALLS ====================

static Future<Map<String, dynamic>> createTest(String roomId, String testTitle, List<Question> questions) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'msg': 'Not authenticated'};

    final response = await http.post(
      Uri.parse('$apiUrl/tests/add-test/$roomId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // Send the questions in the body
      body: json.encode({
        'testTitle': testTitle,
        'questions': questions.map((q) => q.toJson()).toList(),
      }),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> updateTest(String testId, String testTitle, List<Question> questions) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'msg': 'Not authenticated'};

    final response = await http.put(
      Uri.parse('$apiUrl/tests/update-test/$testId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // Send the questions in the body
      body: json.encode({
        'testTitle': testTitle,
        'questions': questions.map((q) => q.toJson()).toList(),
      }),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTestsByRoom(String roomId) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'msg': 'Not authenticated'};

    // Using the corrected, non-conflicting route
    final response = await http.get(
      Uri.parse('$apiUrl/tests/tests-by-room/$roomId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> getTestById(String testId) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'msg': 'Not authenticated'};

    // Using the corrected, non-conflicting route
    final response = await http.get(
      Uri.parse('$apiUrl/tests/get-test/$testId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> deleteTest(String testId) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'msg': 'Not authenticated'};

    final response = await http.delete(
      Uri.parse('$apiUrl/tests/delete-test/$testId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return json.decode(response.body);
  }

  // ==================== QUESTION API CALLS ====================

  static Future<Map<String, dynamic>> addQuestionToTest(
      String testId, Question question) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'msg': 'Not authenticated'};

    final response = await http.post(
      Uri.parse('$apiUrl/tests/add-question/$testId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(question.toJson()),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> updateQuestionInTest(
      String testId, String questionId, Question question) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'msg': 'Not authenticated'};

    final response = await http.put(
      Uri.parse('$apiUrl/tests/$testId/update-question/$questionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(question.toJson()),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> deleteQuestionInTest(
      String testId, String questionId) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'msg': 'Not authenticated'};

    final response = await http.delete(
      Uri.parse('$apiUrl/tests/$testId/delete-question/$questionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> submitAnswer(
      String testId, String questionId, int selectedIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final res = await http.post(
      Uri.parse("$apiUrl/tests/$testId/submit-answer"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: json.encode({
        "questionId": questionId,
        "selectedAnswerIndex": selectedIndex,
        
      }),
    );
    return json.decode(res.body);
  }


  
  static Future<Map<String, dynamic>> getUnAnsweredQuestionsByTestId(String testId) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'msg': 'Not authenticated'};

    // Using the corrected, non-conflicting route
    final response = await http.get(
      Uri.parse('$apiUrl/tests/$testId/unanswered'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return json.decode(response.body);
  }


  
  static Future<Map<String, dynamic>> getTestResult(String testId) async {
    final prefs = await SharedPreferences.getInstance();
   final token = prefs.getString('token');
    final url = Uri.parse("$apiUrl/tests/$testId/result");

    final res = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      return {
        "error": jsonDecode(res.body)["error"] ?? "Failed to fetch result"
      };
    }
  }
}







// =========================================================================
// api/test_api.dart
// Path: lib/api/test_api.dart (New File)

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../utils/constants.dart';
// import '../models/test_model.dart';

// class TestApi {
//   static Future<String?> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }

//   static Future<Map<String, dynamic>> createTest(String roomId, String testTitle, List<Question> questions) async {
//     final token = await _getToken();
//     if (token == null) return {'success': false, 'msg': 'Not authenticated'};

//     final response = await http.post(
//       Uri.parse('$apiUrl/tests/add-test/$roomId'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: json.encode({
//         'testTitle': testTitle,
//         'questions': questions.map((q) => q.toJson()).toList(),
//       }),
//     );
//     return json.decode(response.body);
//   }

//   static Future<Map<String, dynamic>> getTestsByRoom(String roomId) async {
//     final token = await _getToken();
//     if (token == null) return {'success': false, 'msg': 'Not authenticated'};

//     final response = await http.get(
//       Uri.parse('$apiUrl/tests/get-test/$roomId'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );
//     return json.decode(response.body);
//   }

//   static Future<Map<String, dynamic>> deleteTest(String testId) async {
//     final token = await _getToken();
//     if (token == null) return {'success': false, 'msg': 'Not authenticated'};

//     final response = await http.delete(
//       Uri.parse('$apiUrl/tests/delete-test/$testId'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );
//     return json.decode(response.body);
//   }
// }