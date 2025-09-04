import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// Import Room model for type safety
import '../utils/constants.dart';

class RoomApi {
  // Helper to get the auth token from shared preferences.
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Creates a new room.
  static Future<Map<String, dynamic>> addRoom(
      String roomName, String description) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'msg': 'Not authenticated'};

    final response = await http.post(
      Uri.parse('$apiUrl/rooms/add-room'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'roomName': roomName,
        'description': description,
      }),
    );
    return json.decode(response.body);
  }

  // Updates an existing room.
  static Future<Map<String, dynamic>> updateRoom(
      String roomId, String roomName, String description) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'msg': 'Not authenticated'};

    final response = await http.put(
      Uri.parse('$apiUrl/rooms/update-room/$roomId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'roomName': roomName,
        'description': description,
      }),
    );
    return json.decode(response.body);
  }

  // Fetches all rooms owned by the logged-in user.
  static Future<Map<String, dynamic>> getRoomsByOwner() async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'msg': 'Not authenticated'};

    final response = await http.get(
      Uri.parse('$apiUrl/rooms/owned-rooms'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return json.decode(response.body);
  }

  // Fetches all rooms that i am member of it .
static Future<Map<String, dynamic>> getMyRooms() async {
  final token = await _getToken();
  if (token == null) return {'success': false, 'msg': 'Not authenticated'};

  final response = await http.get(
    Uri.parse('$apiUrl/rooms/my-rooms'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  final data = json.decode(response.body);

  // normalize the response
  return {
    'success': true,
    'rooms': data['rooms'] ?? [],
  };
}

  // Fetches a single room by its ID.
  static Future<Map<String, dynamic>> getRoomById(String roomId) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'msg': 'Not authenticated'};

    final response = await http.get(
      Uri.parse('$apiUrl/rooms/get-room/$roomId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return json.decode(response.body);
  }

  // Deletes a room by its ID.
  static Future<Map<String, dynamic>> deleteRoom(String roomId) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'msg': 'Not authenticated'};

    final response = await http.delete(
      Uri.parse('$apiUrl/rooms/delete-room/$roomId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return json.decode(response.body);
  }

  // 🔍 Search room by code
  static Future<Map<String, dynamic>> searchRoomByCode(String code) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'msg': 'Not authenticated'};

    final response = await http.get(
      Uri.parse('$apiUrl/rooms/search-room/$code'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> joinRoom(String roomCode) async {
  final token = await _getToken();
  if (token == null) return {'success': false, 'msg': 'Not authenticated'};

  final response = await http.post(
    Uri.parse('$apiUrl/rooms/join-room'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: json.encode({'roomCode': roomCode}), // Make sure your backend can handle this
  );
  return json.decode(response.body);
}
}
