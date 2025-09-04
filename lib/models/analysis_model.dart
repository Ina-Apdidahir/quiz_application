
// lib/models/analysis_model.dart
class Analysis {
  final int allTests;
  final int totalStudents;
  final int totalRooms;

  Analysis({
    required this.allTests,
    required this.totalStudents,
    required this.totalRooms,
  });

  factory Analysis.fromJson(Map<String, dynamic> json) {
    return Analysis(
      allTests: json['allTests'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      totalRooms: json['totalRooms'] ?? 0,
    );
  }
}
