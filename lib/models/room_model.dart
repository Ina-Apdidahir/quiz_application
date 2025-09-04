
// Path: lib/models/room_model.dart (Corrected)

import 'user_model.dart';
import 'test_model.dart'; // Import the Test model

class Room {
  final String id;
  final String roomName;
  final String roomCode;
  final String description;
  final User owner;
  final List<User> users;
  final List<Test> tests; // This should be a list of Test objects

  Room({
    required this.id,
    required this.roomName,
    required this.roomCode,
    required this.description,
    required this.owner,
    required this.users,
    required this.tests,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    // Parse Users
    var userList = json['users'] as List;
    List<User> users = [];
    for (var item in userList) {
      if (item is Map<String, dynamic>) {
        users.add(User.fromJson(item));
      }
    }
    final ownerUser = User.fromJson(json['owner']);
    if (!users.any((user) => user.id == ownerUser.id)) {
      users.insert(0, ownerUser);
    }
    
    // Parse Tests
    var testList = json['tests'] as List? ?? []; // Handle if tests array is missing
    List<Test> tests = [];
    for (var item in testList) {
      if (item is Map<String, dynamic>) {
        // *** FIX WAS HERE: Add to the 'tests' list, not 'users' ***
        tests.add(Test.fromJson(item));
      }
    }

    return Room(
      id: json['_id'],
      roomName: json['roomName'],
      roomCode: json['roomCode'],
      description: json['description'] ?? '',
      owner: ownerUser,
      users: users,
      tests: tests, // Assign the parsed tests list
    );
  }
}