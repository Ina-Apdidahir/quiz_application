
// models/user_model.dart
// Path: lib/models/user_model.dart

class User {
  final String id;
  final String name;
  final String email;
  final String bio;
  final String role;

  User({required this.id, required this.name, required this.email, required this.bio, required this.role});

  // Factory constructor to create a User from a map (JSON).
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
